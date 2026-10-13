# Azua: seleccion ambiental reproducible + NMDS, dbRDA y etiquetas de especies.
# Ejecutar despues del chunk 'procesamiento-azua' del Rmd (crea h3_sf, mat_com).
# install.packages(c('sf','dplyr','caret','vegan','ggplot2','ggrepel'))
library(sf); library(dplyr); library(caret); library(vegan)
library(ggplot2); library(ggrepel)
set.seed(2026)
stopifnot(exists('h3_sf'), exists('mat_com'))
stopifnot(!is.null(rownames(mat_com)), nrow(mat_com) >= 5)

# IMPORTANTE: leer la tabla ambiental COMPLETA desde h3_sf, no desde un
# subconjunto manual previo. Alinear exactamente con las filas de mat_com.
id_h3 <- if ('hex_id' %in% names(h3_sf)) 'hex_id' else {
  z <- grep('h3|hex', names(h3_sf), ignore.case=TRUE, value=TRUE)
  if (!length(z)) stop('No se encontro identificador H3'); z[1]
}
ids <- as.character(h3_sf[[id_h3]])
if (anyDuplicated(ids)) stop('Hay IDs H3 duplicados en h3_sf')
idx <- match(rownames(mat_com), ids)
if (anyNA(idx)) stop('Algunos hexagonos de mat_com faltan en h3_sf')
A <- sf::st_drop_geometry(h3_sf[idx, ])
stopifnot(identical(as.character(A[[id_h3]]), rownames(mat_com)))

# Seleccion de familias presentes en el GeoPackage real (espacios o puntos).
# Excluimos variables 'base' y codigos categoricos; las fracciones de cobertura
# pueden incorporarse pero se deben interpretar como composicionales.
patron <- '^(WCL[ ._]bio|G90[ ._]|GHH[ ._]|CGIAR[-._ ]|ESA[ ._]|OSM[-._ ]|CGL[ ._])'
candidatas <- grep(patron, names(A), value=TRUE, ignore.case=TRUE)
candidatas <- candidatas[!grepl('(^|[ ._])base$', candidatas, ignore.case=TRUE)]
X <- A[, candidatas, drop=FALSE]
X <- X[, vapply(X, is.numeric, logical(1)), drop=FALSE]
if (!ncol(X)) stop('No hay predictores numericos: inspeccione names(h3_sf)')
cat('Candidatas numericas:', ncol(X), '\n')
X[] <- lapply(X, function(z) { z[!is.finite(z)] <- NA_real_; z })
X <- X[, colMeans(!is.na(X)) >= 0.8, drop=FALSE]
X <- X[, vapply(X, function(z) length(unique(na.omit(z))) > 1, logical(1)), drop=FALSE]
if (!ncol(X)) stop('Sin variables tras filtros de datos faltantes/constancia')
for (nm in names(X)) X[[nm]][is.na(X[[nm]])] <- median(X[[nm]], na.rm=TRUE)
nz <- caret::nearZeroVar(X)
if (length(nz)) X <- X[, -nz, drop=FALSE]
if (!ncol(X)) stop('Sin variables tras nearZeroVar')

# caret::findCorrelation es un filtro heuristico, no una prueba ecologica.
# El orden de columnas no impone prioridad dentro de findCorrelation.
if (ncol(X)>1) {
  R <- suppressWarnings(cor(X))
  R[!is.finite(R)] <- 0
  diag(R) <- 1
  quitar <- caret::findCorrelation(R, cutoff=0.70, exact=TRUE)
  if (length(quitar)) X <- X[, -quitar, drop=FALSE]
}
if (!ncol(X)) stop('Sin variables tras filtro de correlacion')
cat('Variables despues de caret:', ncol(X), '\n')
print(names(X))

# dbRDA: limitar el conjunto de candidatos para evitar sobreajuste (n pequeno).
# Reglas ecologicas: representar clima, relieve, vegetacion y heterogeneidad.
# Si una familia no sobrevive al filtro, no se fuerza su inclusion.
familias <- list(
  clima='^(WCL[ ._]bio)',
  relieve='^(G90[ ._]|CGIAR[-._ ])',
  vegetacion='^(ESA[ ._]|CGL[ ._])',
  heterogeneidad='^(GHH[ ._])',
  accesibilidad='^(OSM[-._ ])'
)
# Elegir hasta dos representantes por familia, privilegiando primero
# nombres interpretables; esta es una preseleccion declarada, NO optimizacion.
preferidas <- c('WCL bio12','WCL bio01','G90 Slope','G90 Topographic Position Index',
                'ESA Trees','ESA Shrubland','GHH shannon','GHH entropy')
normalizar <- function(x) tolower(gsub('[^[:alnum:]]','',x))
prior <- match(normalizar(names(X)), normalizar(preferidas))
prior[is.na(prior)] <- length(preferidas) + seq_len(sum(is.na(prior)))
seleccion <- character()
for (fam in names(familias)) {
  posibles <- grep(familias[[fam]], names(X), value=TRUE, ignore.case=TRUE)
  if (length(posibles)) {
    posibles <- posibles[order(prior[match(posibles,names(X))])]
    seleccion <- c(seleccion, head(posibles, 2))
  }
}
seleccion <- unique(seleccion)
if (!length(seleccion)) stop('No se identificaron familias de variables')
X_modelo <- as.data.frame(scale(X[,seleccion,drop=FALSE]))
rownames(X_modelo) <- rownames(mat_com)
# Nombres sintacticos para formulas; guardar equivalencias.
diccionario <- data.frame(original=names(X_modelo), codigo=make.names(names(X_modelo), unique=TRUE))
names(X_modelo) <- diccionario$codigo
print(diccionario)

# Distancia binaria de Jaccard y dbRDA por seleccion progresiva.
D <- vegan::vegdist(mat_com, method='jaccard', binary=TRUE)
modelo0 <- vegan::dbrda(D ~ 1, data=X_modelo)
form_full <- reformulate(names(X_modelo), response='D')
modelo_full <- vegan::dbrda(form_full, data=X_modelo)
# R2scope protege frente a sobreajuste; limitar pasos a 3 predictores.
sel <- vegan::ordiR2step(modelo0, scope=formula(modelo_full),
                         direction='forward', R2scope=TRUE,
                         permutations=999, trace=FALSE, Pin=0.05, steps=3)
cat('\nModelo dbRDA seleccionado:\n'); print(formula(sel))
print(vegan::RsquareAdj(sel))
print(anova(sel, permutations=999))

# Usar para envfit las variables del modelo, o un conjunto descriptivo
# minimo cuando la seleccion progresiva no admite ninguna.
terminos <- attr(terms(sel), 'term.labels')
if (!length(terminos)) {
  message('dbRDA no selecciono predictores: envfit exploratorio con hasta 3 variables.')
  terminos <- head(names(X_modelo),3)
}
mat_amb_sel <- X_modelo[,terminos,drop=FALSE]
stopifnot(identical(rownames(mat_amb_sel),rownames(mat_com)))

# NMDS y ajuste ambiental
nmds_res <- vegan::metaMDS(mat_com, distance='jaccard', binary=TRUE,
                            k=2, autotransform=FALSE, trymax=100, trace=FALSE)
estres_valor <- round(nmds_res$stress,3)
fit_env <- vegan::envfit(nmds_res, mat_amb_sel, permutations=999)
res_envfit <- as.data.frame(fit_env$vectors$arrows)
res_envfit$r2 <- fit_env$vectors$r
res_envfit$p_val <- fit_env$vectors$pvals
res_envfit$Variable <- rownames(res_envfit)
print(res_envfit)

# NMDS con 20 especies mas frecuentes, abreviadas; coordenadas de especies
# son promedios ponderados, no puntos de observacion independientes.
sit <- as.data.frame(vegan::scores(nmds_res,display='sites'))
sp <- as.data.frame(vegan::scores(nmds_res,display='species'))
sp$especie <- rownames(sp)
frec <- sort(colSums(mat_com),decreasing=TRUE)
sp <- sp[match(head(names(frec),20),sp$especie),,drop=FALSE]
sp <- sp[complete.cases(sp[,c('NMDS1','NMDS2')]),,drop=FALSE]
sp$etiqueta <- vapply(strsplit(sp$especie,' +'),function(z)
  if(length(z)>=2) paste0(substr(z[1],1,1),'. ',z[2]) else z[1],character(1))
vec <- as.data.frame(vegan::scores(fit_env,display='vectors'))
vec$variable <- rownames(vec)
# vector scores ya pondera las flechas por la fuerza del ajuste.
if(nrow(vec)) {
  ext <- min(diff(range(sit$NMDS1)),diff(range(sit$NMDS2)))
  magn <- max(abs(as.matrix(vec[,c('NMDS1','NMDS2')])))
  if (is.finite(magn) && magn>0) {
    vec$NMDS1 <- vec$NMDS1*0.35*ext/magn
    vec$NMDS2 <- vec$NMDS2*0.35*ext/magn
  }
}
p_nmds <- ggplot(sit,aes(NMDS1,NMDS2)) +
  geom_point(size=2,alpha=.75) +
  geom_text_repel(data=sp,aes(NMDS1,NMDS2,label=etiqueta),
                  inherit.aes=FALSE,size=3,max.overlaps=Inf) +
  geom_segment(data=vec,aes(x=0,y=0,xend=NMDS1,yend=NMDS2),
               inherit.aes=FALSE,arrow=grid::arrow(length=grid::unit(.15,'cm'))) +
  geom_text_repel(data=vec,aes(NMDS1,NMDS2,label=variable),
                  inherit.aes=FALSE,size=3) +
  coord_equal() + theme_bw() +
  labs(title='NMDS Jaccard: flora de Azua',subtitle=paste('Stress =',estres_valor),
       caption='Etiquetas: 20 especies mas frecuentes; flechas: envfit')
print(p_nmds)
# ggsave('nmds_azua_especies.png',p_nmds,width=11,height=8,dpi=300)
