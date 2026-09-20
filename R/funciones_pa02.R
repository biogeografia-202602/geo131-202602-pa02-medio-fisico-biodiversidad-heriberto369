# Funciones de apoyo para PA02 de Biogeografía
# Estas funciones NO sustituyen la comprensión del flujo de trabajo.

suppressPackageStartupMessages({
  library(sf)
  library(dplyr)
  library(tidyr)
  library(tibble)
  library(stringr)
})

nombre_especie_preferido <- function(x) {
  candidatos <- c("acceptedScientificName", "species", "scientificName")
  disponibles <- candidatos[candidatos %in% names(x)]
  if (length(disponibles) == 0) {
    stop("No existe acceptedScientificName, species ni scientificName")
  }
  out <- rep(NA_character_, nrow(x))
  for (v in disponibles) {
    usar <- is.na(out) | trimws(out) == ""
    out[usar] <- as.character(x[[v]][usar])
  }
  trimws(out)
}

clasificar_habitat_esa <- function(h3) {
  vars <- grep("^ESA ", names(h3), value = TRUE)
  vars <- setdiff(vars, "ESA base")
  if (length(vars) < 2) stop("No se encontraron columnas ESA de cobertura")
  x <- st_drop_geometry(h3)[, vars, drop = FALSE]
  x[] <- lapply(x, as.numeric)
  x[is.na(x)] <- -Inf
  idx <- max.col(as.matrix(x), ties.method = "first")
  hab <- vars[idx]
  hab[apply(as.matrix(x), 1, function(z) all(!is.finite(z)))] <- NA_character_
  sub("^ESA ", "", hab)
}

generar_matriz_comunidad <- function(registros, min_hex_especie = 3,
                                      min_especies_hex = 5,
                                      col_hex = "hex_id",
                                      col_especie = "especie") {
  stopifnot(col_hex %in% names(registros), col_especie %in% names(registros))
  pa <- registros |>
    st_drop_geometry() |>
    filter(!is.na(.data[[col_hex]]), !is.na(.data[[col_especie]]), .data[[col_especie]] != "") |>
    distinct(.data[[col_hex]], .data[[col_especie]]) |>
    mutate(presencia = 1L) |>
    pivot_wider(names_from = all_of(col_especie), values_from = presencia, values_fill = 0L) |>
    column_to_rownames(col_hex)

  pa <- as.data.frame(pa)
  pa <- pa[, colSums(pa) >= min_hex_especie, drop = FALSE]
  pa <- pa[rowSums(pa) >= min_especies_hex, , drop = FALSE]
  pa
}

alinear_ambiente <- function(h3, mc, variables) {
  stopifnot("hex_id" %in% names(h3))
  faltan <- setdiff(variables, names(h3))
  if (length(faltan)) stop("Variables ausentes: ", paste(faltan, collapse = ", "))
  ma <- h3 |>
    st_drop_geometry() |>
    select(hex_id, all_of(variables)) |>
    distinct(hex_id, .keep_all = TRUE) |>
    column_to_rownames("hex_id")
  ma <- ma[rownames(mc), , drop = FALSE]
  if (!identical(rownames(mc), rownames(ma))) stop("No coinciden las filas de MC y MA")
  ma
}

normalizar_nombre <- function(x) {
  x |>
    trimws() |>
    tolower() |>
    iconv(from = "UTF-8", to = "ASCII//TRANSLIT") |>
    gsub("[^a-z0-9]+", "-", x = _) |>
    gsub("^-|-$", "", x = _)
}

verificar_nombre_carpeta <- function(nombre_mun, raiz = ".") {
  
  # Normalizar el nombre introducido
  nombre_limpio <- nombre_mun |>
    trimws() |>
    tolower() |>
    iconv(from = "UTF-8", to = "ASCII//TRANSLIT") |>
    gsub("[^a-z0-9]+", "-", x = _) |>
    gsub("^-|-$", "", x = _)
  
  dir_datos <- file.path(raiz, "datos_por_municipio")
  
  if (!dir.exists(dir_datos)) {
    stop(
      "No se encontró el directorio `datos_por_municipio`."
    )
  }
  
  # Buscar carpetas con estructura codigo_nombre
  carpetas <- list.files(
    dir_datos,
    pattern = paste0("_", nombre_limpio, "$")
  )
  
  if (length(carpetas) == 0) {
    stop(
      "No se encontró ningún municipio con el nombre `",
      nombre_limpio,
      "`.\n",
      "Comprueba el nombre del municipio."
    )
  }
  
  if (length(carpetas) > 1) {
    stop(
      "Se encontró más de una carpeta para `",
      nombre_limpio,
      "`: ",
      paste(carpetas, collapse = ", "),
      "."
    )
  }
  
  nombre_carpeta <- carpetas
  
  # El código es todo lo situado antes del primer "_"
  codigo_mun <- sub("_.*$", "", nombre_carpeta)
  
  # El nombre canónico es todo lo situado después del primer "_"
  nombre_mun <- sub("^[^_]+_", "", nombre_carpeta)
  
  list(
    codigo_mun = codigo_mun,
    nombre_mun = nombre_mun,
    nombre_carpeta = nombre_carpeta
  )
}

abreviar_especies <- function(x) {
  
  vapply(
    strsplit(trimws(x), "\\s+"),
    function(partes) {
      
      if (length(partes) >= 2) {
        paste0(
          substr(partes[1], 1, 1),
          ". ",
          partes[2]
        )
      } else {
        partes[1]
      }
    },
    character(1)
  )
}
