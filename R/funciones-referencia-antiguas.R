# Paquetes y funciones externas
library(kableExtra)
library(rgbif)
library(terra)
library(geodata)
library(sf)
library(h3jsr)
library(tidyverse)
library(units)
library(devtools)
library(CoordinateCleaner)
library(countrycode)
library(vegan)
options(stringsAsFactors = FALSE)
source_url('https://raw.githubusercontent.com/biogeografia-202202/material-de-apoyo/master/practicas/funciones.R')

# Función de ayuda para definir el área de interés, AOI
crear_ind_esp_aoi <- function(ruta_archivo_aoi = 'rd.gpkg',
                                         resolucion = 5, buffer_km = 2) {
  aoi <- st_read(ruta_archivo_aoi, quiet = T)
  aoi_extra <- st_buffer(aoi, dist = set_units(buffer_km, km))
  ind_esp <- polygon_to_cells(aoi_extra, res = resolucion, simple = FALSE)
  ind_esp <- cell_to_polygon(unlist(ind_esp$h3_addresses), simple = FALSE)
  ind_esp_centroides <- ind_esp %>%
  st_centroid() %>%
  mutate(lon = unlist(map(geometry, 1)), lat = unlist(map(geometry, 2)))
  return(list(
    aoi = aoi,
    aoi_extra = aoi_extra,
    ind_esp = ind_esp,
    ind_esp_centroides = ind_esp_centroides)
  )
}

# Función de ayuda para descargar reigstros de presencia desde GBIF por taxón
descargar_reg_pres_gbif <- function(taxon) {
  occ <- occ_data(scientificName = taxon,
           hasCoordinate = T,
           country = 'DO',
           limit = 100000)$data
  return(occ)
}

# Función de ayuda para limpiar registros de GBIF
limpiar_reg_pres <- function(obj_registros) {
  reg_pres_limpios <- obj_registros %>% 
  # Quitar registros en centroides de país y sus proximidades
  cc_cen(lon = 'decimalLongitude', lat = 'decimalLatitude', buffer = 2000) %>%
  # Quitar registros en colecciones y sus proximidades
  cc_inst(lon = 'decimalLongitude', lat = 'decimalLatitude', buffer = 2000) %>%
  # Quitar registros en mar/oceáno
  cc_sea(lon = 'decimalLongitude', lat = 'decimalLatitude')
  return(reg_pres_limpios)
}

# Función de ayuda para convertir registros de presencia a objeto geográfico (`sf`)
convertir_reg_pres_a_sf <- function(obj_registros) {
  reg_pres_sf <- st_as_sf(
    x = obj_registros,
    coords = c("decimalLongitude", "decimalLatitude"),
    crs = 4326)
  return(reg_pres_sf)
}

# Función de ayuda para intersectar registros de presencia con hexágonos de biblioteca H3
intersectar_reg_hex <- function(obj_registros, ind_esp) {
  reg_hex_inter <- obj_registros %>%
    st_intersection(st_union(ind_esp))
  return(reg_hex_inter)
}

# Función de ayuda para generar matriz de comunidad a partir de registros de presencia
generar_mc <- function(
    obj_reg_hex_inter,
    ind_esp,
    min_num_spp_hex, #Mínimo número de especies por hexágono
    min_num_hex_sp #Mínimo número de hexágonos donde cada especie debe estar presente
    ) {
  mc <- obj_reg_hex_inter %>%
    st_join(ind_esp) %>% 
    select(acceptedScientificName, h3_address) %>% 
    st_drop_geometry() %>% 
    mutate(n = 1) %>% 
    distinct() %>% 
    pivot_wider(names_from = acceptedScientificName, values_from = n, values_fill = 0) %>% 
    column_to_rownames('h3_address')
  col_antes <- ncol(mc)
  mc <- mc[, colSums(mc) >= min_num_hex_sp]
  col_despues <- ncol(mc)
  cat(
    'El número de especies quitadas de la matriz por estar en menos de',
    min_num_hex_sp, 'hexágonos fue de ',
    col_antes - col_despues, '\n'
  )
  # Explicación: "min_especies_por_hex <- Y", donde Y es el número mínimo (inclusive) de especies
  # que debe existir en cada hexágono. Por debajo de dicho valor, el hexágono es excluido.
  filas_antes <- nrow(mc)
  mc <- mc[rowSums(mc) >= min_num_spp_hex, ]
  filas_despues <- nrow(mc)
  cat(
    'El número de hexágonos quitados de la matriz por tener menos de',
    min_num_hex_sp, 'expecies representadas fue de',
    filas_antes - filas_despues, '\n'
  )
  mc_nc <- mc # Matriz de comunidad con nombres acortados
  nombres_largos <- colnames(mc)
  nombres_cortos <- make.cepnames(word(colnames(mc), 1, 2))
  colnames(mc_nc) <- nombres_cortos
  df_equivalencias <- data.frame(
    nombre_original = nombres_largos,
    abreviado = nombres_cortos)
  return(list(mc = mc, mc_nc = mc_nc))
}

# Función de ayuda para generar la matriz de ambiental
generar_ma <- function(
    obj_mc,
    resolucion
    ) {
  zs <- readRDS('zonal_statistics/list_with_all_sources_all_resolution.RDS')
  za <- zs[[paste0('H3 resolution: ', resolucion)]]
  za_intermedia <- za %>%
    st_drop_geometry() %>% 
    select(-matches(c(' base'))) %>% 
    column_to_rownames('hex_id')
  ma <- za_intermedia[match(rownames(obj_mc), rownames(za_intermedia)), ]
  if(all(rownames(obj_mc) == rownames(ma))) {
    cat('Hay consistencia de filas entre matrices de comunidad y ambiental\n')
  } else {
    cat('No hay consistencia de filas entre matrices de comunidad y ambiental\n')
  }
  return(ma)
}

# Función para generar las matrices de comunidad y ambiental a partir de las anteriores
generar_mc_ma <- function(
    taxon,
    archivo_reg_pres = F,
    ruta_archivo_reg_pres = NULL,
    resolucion = 5,
    exportar_sf = F,
    col_species_como_acceptedScientificName = F,
    dir_salidas_rds = 'salidas_RDS/',
    dir_salidas_sf = 'salidas_sf/',
    extension_sf = '.kml',
    exportar_mc = T,
    dir_salidas_mc = 'salidas_mc/',
    min_num_spp_hex = 3, #Mínimo número de especies por hexágono
    min_num_hex_sp = 3, #Mínimo número de hexágonos donde cada especie debe estar presente
    exportar_ma = T,
    dir_salidas_ma = 'salidas_ma/',
    espera = 10
    ) {
  cat('\n\n### CREANDO ÍNDICE ESPACIAL H3 EN EL ÁREA DE INTERES (AOI) ###\n')
  ind_esp_aoi <- crear_ind_esp_aoi(resolucion = resolucion)
  cat('\n\n### DESCARGANDO O IMPORTANDO REGISTROS DE PRESENCIA DEL TAXÓN', taxon, 'DESDE GBIF ###\n')
  if(archivo_reg_pres) {
    reg_pres <- read_delim(ruta_archivo_reg_pres)
  } else {
    reg_pres <- descargar_reg_pres_gbif(taxon = taxon)
  }
  Sys.sleep(espera)
  if(col_species_como_acceptedScientificName) {
    reg_pres <- reg_pres %>% rename(acceptedScientificName = species)
  }
  cat('\n\n### LIMPIANDO REGISTROS DE PRESENCIA DEL TAXÓN ###\n')
  reg_pres_limpios <- limpiar_reg_pres(reg_pres)
  cat('\n\n### CONVIRTIENDO REGISTROS DE PRESENCIA A OBJETO sf ###\n')
  reg_pres_sf <- convertir_reg_pres_a_sf(obj_registros = reg_pres_limpios)
  cat('\n\n### INTERSECTANDO REGISTROS DE PRESENCIA EN EL ÍNDICE ESPACIAL ###\n')
  reg_hex_inter <- intersectar_reg_hex(obj_registros = reg_pres_sf, ind_esp = ind_esp_aoi$ind_esp)
  cat('\n\n### CREANDO GRÁFICO ###\n')
  aoi_reg_hex_inter_g <- ggplot(data = ind_esp_aoi$aoi) +
    geom_sf(fill = 'antiquewhite1') +
    geom_sf(data = ind_esp_aoi$ind_esp, fill = 'transparent') +
    geom_text(data = ind_esp_aoi$ind_esp_centroides, aes(lon, lat, label = h3_address), size = 1) +
    geom_sf(data = reg_hex_inter, size = 1, fill = 'green', color = 'green', alpha = 0.5) +
    theme(legend.position = "none") +
    theme_bw()
  cat('\n\n### GENERANDO SALIDAS .RDS DE LOS REGISTROS INTERSECTADOS Y EL ÍNDICE ESPACIAL ###\n')
  if(!dir.exists(dir_salidas_rds)) dir.create(dir_salidas_rds)
  saveRDS(object = reg_hex_inter, file = paste0(dir_salidas_rds, 'reg_hex_inter_', taxon, '.RDS'))
  saveRDS(object = ind_esp_aoi$ind_esp, file = paste0(dir_salidas_rds, 'ind_esp_', taxon, '.RDS'))
  if(exportar_sf) {
    cat('\n\n### GENERANDO SALIDAS .RDS DE LOS REGISTROS INTERSECTADOS Y EL ÍNDICE ESPACIAL ###\n')
    if(!dir.exists(dir_salidas_sf)) dir.create(dir_salidas_sf)
    # Comprobando si la columna 'networkKeys' existe en el data.frame
    if("networkKeys" %in% names(reg_hex_inter)) {
      reg_hex_inter <- reg_hex_inter %>% select(-networkKeys)
    }
    # Ahora guardamos el objeto sin la columna 'networkKeys' (si existía)
    st_write(
      obj = reg_hex_inter,
      dsn = paste0(dir_salidas_sf, 'reg_hex_inter_', taxon, extension_sf),
      delete_dsn = T
    )
    st_write(
      obj = ind_esp_aoi$ind_esp,
      dsn = paste0(dir_salidas_sf, 'ind_esp_', taxon, extension_sf),
      delete_dsn = T)
  }
  cat('\n\n### GENERANDO MATRIZ DE COMUNIDAD ###\n')
  mc <- generar_mc(
    obj_reg_hex_inter = reg_hex_inter,
    ind_esp = ind_esp_aoi$ind_esp,
    min_num_spp_hex = min_num_spp_hex,
    min_num_hex_sp = min_num_hex_sp)
  if(exportar_mc) {
    cat('\n\n### EXPORTANDO MATRIZ DE COMUNIDAD DE NOMBRES LARGOS Y CORTOS EN FORMATO .RDS ###\n')
    if(!dir.exists(dir_salidas_mc)) dir.create(dir_salidas_mc)
    saveRDS(object = mc$mc, file = paste0(dir_salidas_mc, 'mc_nombres_largos_', taxon, '.RDS'))
    saveRDS(object = mc$mc_nc, file = paste0(dir_salidas_mc, 'mc_nombres_cortos_', taxon, '.RDS'))
  }
  cat('\n\n### GENERANDO MATRIZ AMBIENTAL ###\n')
  ma <- generar_ma(
    obj_mc = mc$mc,
    resolucion = resolucion
  )
  if(exportar_ma) {
    cat('\n\n### EXPORTANDO MATRIZ AMBIENTAL ###\n')
    if(!dir.exists(dir_salidas_ma)) dir.create(dir_salidas_ma)
    saveRDS(object = ma, file = paste0(dir_salidas_ma, 'ma_', taxon, '.RDS'))
  }
  cat('\n\n### GENERANDO LISTA EXHAUSTIVA DE OBJETOS ###\n')
  todos_los_objetos <- list(
    reg_pres = reg_pres,
    reg_pres_limpios = reg_pres_limpios,
    reg_pres_sf = reg_pres_sf,
    reg_hex_inter = reg_hex_inter,
    aoi_reg_hex_inter_g = aoi_reg_hex_inter_g,
    mc = mc$mc,
    mc_nc = mc$mc_nc,
    ma = ma
    )
  class(todos_los_objetos) <- "mc_ma"
  saveRDS(object = todos_los_objetos, file = paste0(dir_salidas_rds, 'todos_los_objetos_', taxon, '.RDS'))
  cat('\n\n### MATRICES DE COMUNIDAD Y AMBIENTAL GENERADAS CON ÉXITO ###\n')
  return(todos_los_objetos)
}

# Método resumen para objeto de clase `mc_ma`
summary.mc_ma <- function(
    x,
    nombres_cortos = F,
    tamano_rotulo = 4,
    ...) {
  if(nombres_cortos) x$mc <- x$mc_nc
  cat('- **Lista de especies en orden alfabético**')
  print(
    data.frame(Especies = sort(colnames(x$mc))) %>%
      kableExtra::kable()
  )
  cat('\n- **Las matrices de comunidad y ambiental abarcan**', nrow(x$mc), '**sitios (hexágonos)**\n')
  cat('\n- **La riqueza es', specnumber(colSums(x$mc)), 'especies**\n')
  cat('\n- **Riqueza de especies por sitios**')
  print(
    data.frame(`Riqueza de especies` = specnumber(x$mc), check.names = F) %>%
      rownames_to_column('Hexágono H3') %>%
      kableExtra::kable()
  )
  cat('\n- **Gráfico de mosaicos de presencia de especies por hexágonos H3**')
  grafico_mosaico <- crear_grafico_mosaico_de_mc(x$mc, tam_rotulo = tamano_rotulo) +
    xlab('Hexágono H3') + ylab('Especie')
  print(grafico_mosaico)
}
