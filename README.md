PA02 · Medio físico, ambiente y biodiversidad de un municipio
dominicano<small><br>Biogeografía<br>Universidad Autónoma de Santo
Domingo (UASD)</small>
================
José-Ramón Martínez-Batlle
2026-09-08

<!-- README.md y README.html se generan a partir de README.Rmd. Edita README.Rmd. -->

Versión HTML (quizá más legible),
[aquí](https://biogeografia-master.github.io/medio-fisico-ambiente-biodiversidad-municipio-dominicano/README.html)

# Fecha/hora de entrega

**VER PORTAL DE LA ASIGNATURA**

# Propósito de la práctica

En esta práctica estudiarás cómo cambia la **composición de la flora
registrada** dentro de un municipio de la República Dominicana elegido
por ti, y hasta qué punto esos patrones se asocian con el **medio
físico, el clima, la cobertura del suelo, la heterogeneidad del paisaje
y otras variables ambientales**. El trabajo combinará SIG, datos
abiertos de biodiversidad, estadística multivariada y regresión.

Dentro del municipio, la unidad espacial principal será el **hexágono H3
de resolución 7**. Cada hexágono tiene una superficie media (calculada a
nivel global) cercana a 5.16 km², aunque su superficie real varía con la
posición geográfica. Cada hexágono H3 dispone de más de 140 variables
ambientales calculadas para los fines; puedes obtener más información
sobre ese dataset [aquí](https://github.com/geofis/zonal-statistics)
(Martínez-Batlle, 2022). Los registros de GBIF no se interpretarán como
un censo exhaustivo ni como abundancias: son **registros de presencia
acumulados con intensidades de registro espacialmente desiguales**. Por
ello, el número de registros por hexágono debe describirse y
considerarse explícitamente al interpretar la riqueza observada. Por
ello, **no se puede asumir que la ausencia de un registro signifique
ausencia biológica, ni que un registro de presencia de una especie se
corresponda con las condiciones actuales del hábitat**. Por otra parte,
los registros de GBIF presentan otras limitaciones que debes reconocer:
fueron obtenidos en fechas distintas, por personas distintas, con
propósitos distintos y bajo criterios taxonómicos que pueden haber
cambiado. Además, con datos de GBIF no podemos hablar de esfuerzo de
muestreo, pero si podemos considerar los registros para realizar
análisis de intensidad de registro.

El producto principal **no es un conjunto de mapas ni una colección de
pruebas estadísticas aisladas: es un minimanuscrito científico** en el
que una pregunta biogeográfica se responde mediante evidencia
reproducible.

> **IMPORTANTE · IA bajo auditoría.** Puedes usar herramientas de
> inteligencia artificial como apoyo, tutor, depurador o interlocutor.
> Durante la defensa deberás identificar y demostrar **al menos un
> error, limitación, simplificación indebida o afirmación no verificada
> producida por una IA durante tu trabajo**. Conserva evidencia concreta
> y explica cómo verificaste o corregiste el problema. Si no utilizaste
> IA, decláralo explícitamente.

# Objetivos

Al finalizar la práctica deberás demostrar o mejorar tus capacidades
para:

- formular una pregunta biogeográfica concreta sobre diversidad,
  composición o asociación especie–ambiente;
- visualizar y auditar datos de ocurrencia de biodiversidad en QGIS;
- comprender las limitaciones de los datos oportunistas de GBIF y
  distinguir **registros**, **presencias**, **riqueza observada** y
  **abundancia**;
- construir una matriz de comunidad de presencia/ausencia por hexágonos
  H3;
- construir una matriz ambiental coherente con las mismas unidades
  espaciales;
- seleccionar variables ambientales con criterio ecológico y reducir
  redundancia/colinealidad;
- explorar composición florística mediante ordenación multivariada;
- evaluar asociaciones entre composición y ambiente;
- analizar diferencias entre hábitats cuando el municipio tenga
  replicación suficiente;
- modelar riqueza observada mediante regresión considerando
  explícitamente la intensidad de registro (`n_registros`);
- identificar especies asociadas a tipos de hábitat cuando los datos lo
  permitan;
- comunicar resultados mediante mapas, figuras, tablas y un manuscrito
  reproducible;
- reconocer limitaciones de escala, sesgo de muestreo, calidad de
  coordenadas y cobertura taxonómica;
- auditar críticamente el uso de inteligencia artificial.

# Datos que usarás

Elige un municipio y, IMPORTANTE, anúncialo en el foro. Cada estudiante
trabajará con **un municipio** asignado o elegido de los municipios
candidatos mostrados en la Figura
<a href="#fig:mapa-municipios-candidatos">1</a>. El código de seis
dígitos mostrado en el mapa corresponde al prefijo de la carpeta que
contiene los datos del municipio; por ejemplo, `010901_moca` corresponde
al municipio de Moca.

<div class="figure">

<img src="README_files/figure-gfm/mapa-municipios-candidatos-1.png" alt="Municipios disponibles para la práctica. Se muestran los municipios clasificados como aptos o condicionales y el código utilizado para identificar su carpeta de datos."  />
<p class="caption">
<span id="fig:mapa-municipios-candidatos"></span>Figure 1: Municipios
disponibles para la práctica. Se muestran los municipios clasificados
como aptos o condicionales y el código utilizado para identificar su
carpeta de datos.
</p>

</div>

## Municipios disponibles y características de los datos

La tabla siguiente resume algunas características de los municipios
disponibles. Estas cifras permiten comparar la cantidad y distribución
de la información antes de elegir. Las categorías **APTO** y
**CONDICIONAL** indican si los datos cumplen los criterios operativos
utilizados para recomendar el municipio; no constituyen una valoración
de su importancia biogeográfica.

| Código | Municipio                | Provincia | Registros | Especies | H3 con registros | H3 ≥5 spp. | Mediana registros/H3 | Especies en ≥3 H3 | Grupos de hábitat | Categoría   |
|:-------|:-------------------------|----------:|----------:|---------:|-----------------:|-----------:|---------------------:|------------------:|------------------:|:------------|
| 021302 | Constanza                |        13 |      5583 |     1715 |              154 |         98 |                 11.5 |               473 |                 3 | APTO        |
| 061601 | Pedernales               |        16 |      4124 |     1340 |              178 |        101 |                  8.0 |               308 |                 4 | APTO        |
| 021303 | Jarabacoa                |        13 |      3451 |     1236 |              109 |         73 |                 11.0 |               290 |                 1 | APTO        |
| 022801 | Bonao                    |        28 |      1873 |      972 |               90 |         40 |                  4.0 |                79 |                 1 | APTO        |
| 061002 | Duvergé                  |        10 |      2163 |      861 |               76 |         50 |                 11.5 |               142 |                 4 | APTO        |
| 053101 | San José De Ocoa         |        31 |      1963 |      843 |               86 |         52 |                  9.5 |               153 |                 2 | APTO        |
| 081101 | Higüey                   |        11 |      3316 |      774 |              175 |         86 |                  5.0 |               223 |                 5 | APTO        |
| 012501 | Santiago                 |        25 |      2051 |      755 |               78 |         42 |                  6.5 |               146 |                 3 | APTO        |
| 051701 | Baní                     |        17 |      1745 |      753 |              142 |         64 |                  5.0 |               115 |                 5 | APTO        |
| 093002 | Sabana De La Mar         |        30 |      1630 |      657 |               68 |         37 |                  8.0 |               114 |                 3 | APTO        |
| 081102 | San Rafael Del Yuma      |        11 |      1802 |      632 |               64 |         43 |                 11.0 |               124 |                 3 | APTO        |
| 011801 | Puerto Plata             |        18 |      1462 |      598 |               81 |         38 |                  5.0 |                91 |                 3 | APTO        |
| 060407 | La Ciénaga               |        04 |      1382 |      586 |               34 |         27 |                 18.5 |                80 |                 2 | APTO        |
| 012505 | San José De Las Matas    |        25 |      1071 |      583 |              154 |         57 |                  3.0 |                65 |                 2 | APTO        |
| 053102 | Sabana Larga             |        31 |      1408 |      568 |               32 |         21 |                 12.5 |                67 |                 1 | APTO        |
| 060404 | Paraíso                  |        04 |      1007 |      529 |               32 |         24 |                 14.0 |                50 |                 1 | APTO        |
| 032001 | Samaná                   |        20 |      1307 |      522 |              101 |         46 |                  4.0 |                98 |                 2 | APTO        |
| 050201 | Azua                     |        02 |       947 |      513 |               53 |         24 |                  3.0 |                48 |                 3 | APTO        |
| 060401 | Barahona                 |        04 |       729 |      491 |               38 |         22 |                 11.5 |                25 |                 2 | APTO        |
| 103203 | Santo Domingo Norte      |        32 |      1210 |      472 |               63 |         24 |                  4.0 |                67 |                 3 | APTO        |
| 072203 | El Cercado               |        22 |       808 |      456 |               29 |         20 |                 10.0 |                26 |                 2 | APTO        |
| 011807 | Sosúa                    |        18 |      1160 |      453 |               57 |         30 |                  5.0 |               102 |                 2 | APTO        |
| 042601 | San Ignacio De Sabaneta  |        26 |       795 |      435 |               83 |         29 |                  3.0 |                34 |                 2 | APTO        |
| 103201 | Santo Domingo Este       |        32 |       875 |      433 |               50 |         23 |                  5.0 |                47 |                 4 | APTO        |
| 060402 | Cabral                   |        04 |       702 |      423 |               23 |         16 |                 11.0 |                17 |                 1 | APTO        |
| 021301 | La Vega                  |        13 |       572 |      382 |               77 |         27 |                  2.0 |                17 |                 4 | APTO        |
| 060410 | Polo                     |        04 |       699 |      379 |               33 |         19 |                  7.0 |                10 |                 1 | APTO        |
| 081201 | La Romana                |        12 |       806 |      370 |               48 |         24 |                  5.5 |                56 |                 4 | APTO        |
| 052104 | Cambita Garabitos        |        21 |       650 |      370 |               36 |         20 |                  8.0 |                22 |                 1 | APTO        |
| 053103 | Rancho Arriba            |        31 |       675 |      366 |               39 |         20 |                  5.0 |                26 |                 1 | APTO        |
| 072202 | Bohechío                 |        22 |       526 |      349 |               33 |         17 |                  6.0 |                16 |                 1 | APTO        |
| 061602 | Oviedo                   |        16 |       765 |      322 |               83 |         33 |                  4.0 |                51 |                 5 | APTO        |
| 072201 | San Juan                 |        22 |       439 |      319 |               70 |         18 |                  2.0 |                 6 |                 4 | APTO        |
| 032003 | Las Terrenas             |        20 |       644 |      315 |               27 |         17 |                 10.0 |                35 |                 2 | APTO        |
| 022803 | Piedra Blanca            |        28 |       487 |      314 |               35 |         19 |                  6.0 |                10 |                 1 | APTO        |
| 092902 | Bayaguana                |        29 |       605 |      313 |               60 |         24 |                  4.0 |                34 |                 2 | APTO        |
| 010903 | Gaspar Hernández         |        09 |       610 |      313 |               39 |         18 |                  4.0 |                27 |                 3 | APTO        |
| 080802 | Miches                   |        08 |       563 |      310 |               58 |         22 |                  4.0 |                25 |                 3 | APTO        |
| 022401 | Cotuí                    |        24 |       477 |      301 |               46 |         17 |                  3.0 |                26 |                 2 | APTO        |
| 030601 | San Francisco De Macorís |        06 |       560 |      289 |               69 |         22 |                  3.0 |                35 |                 3 | APTO        |
| 052105 | Villa Altagracia         |        21 |       487 |      259 |               53 |         18 |                  4.0 |                15 |                 2 | APTO        |
| 041503 | Guayubín                 |        15 |       394 |      234 |               68 |         23 |                  2.0 |                25 |                 3 | APTO        |
| 070705 | Pedro Santana            |        07 |       335 |      233 |               34 |         16 |                  3.0 |                 6 |                 2 | APTO        |
| 060403 | Enriquillo               |        04 |       317 |      229 |               35 |         15 |                  4.0 |                 5 |                 1 | APTO        |
| 080801 | El Seibo                 |        08 |       361 |      228 |               45 |         17 |                  3.0 |                 4 |                 2 | APTO        |
| 041501 | Monte Cristi             |        15 |       456 |      213 |               50 |         17 |                  3.0 |                24 |                 6 | APTO        |
| 100101 | Santo Domingo De Guzmán  |        01 |       847 |      414 |               21 |         14 |                 28.0 |                53 |                 2 | CONDICIONAL |
| 061003 | La Descubierta           |        10 |       650 |      385 |               25 |         14 |                  9.0 |                 7 |                 3 | CONDICIONAL |
| 042702 | Esperanza                |        27 |       646 |      377 |               26 |          9 |                  2.0 |                 8 |                 2 | CONDICIONAL |
| 070704 | Hondo Valle              |        07 |       739 |      362 |               21 |         12 |                  8.0 |                18 |                 2 | CONDICIONAL |
| 010901 | Moca                     |        09 |       411 |      243 |               54 |         14 |                  2.0 |                17 |                 1 | CONDICIONAL |
| 042603 | Monción                  |        26 |       374 |      233 |               24 |         12 |                  7.0 |                 9 |                 1 | CONDICIONAL |
| 050204 | Padre Las Casas          |        02 |       303 |      233 |               39 |         12 |                  3.0 |                 4 |                 2 | CONDICIONAL |
| 050209 | Guayabal                 |        02 |       335 |      231 |               30 |          9 |                  2.0 |                 4 |                 2 | CONDICIONAL |
| 060405 | Vicente Noble            |        04 |       464 |      229 |               37 |         14 |                  3.0 |                12 |                 2 | CONDICIONAL |
| 103207 | Pedro Brand              |        32 |       382 |      225 |               33 |         12 |                  3.0 |                12 |                 1 | CONDICIONAL |
| 092303 | Ramón Santana            |        23 |       358 |      205 |               25 |          9 |                  2.0 |                 6 |                 2 | CONDICIONAL |
| 103204 | Boca Chica               |        32 |       341 |      200 |               22 |         10 |                  6.0 |                 6 |                 3 | CONDICIONAL |
| 052101 | San Cristóbal            |        21 |       289 |      195 |               37 |         12 |                  3.0 |                 6 |                 2 | CONDICIONAL |
| 032002 | Sánchez                  |        20 |       282 |      194 |               36 |         14 |                  3.5 |                 8 |                 3 | CONDICIONAL |
| 040502 | Loma De Cabrera          |        05 |       262 |      186 |               28 |         11 |                  2.5 |                 3 |                 2 | CONDICIONAL |
| 103205 | San Antonio De Guerra    |        32 |       324 |      175 |               40 |         15 |                  3.5 |                17 |                 1 | CONDICIONAL |
| 012507 | Villa González           |        25 |       232 |      173 |               13 |          9 |                  8.0 |                 1 |                 1 | CONDICIONAL |
| 022802 | Maimón                   |        28 |       234 |      167 |               17 |         11 |                  7.0 |                 2 |                 2 | CONDICIONAL |
| 061001 | Jimaní                   |        10 |       310 |      165 |               31 |         10 |                  4.0 |                 6 |                 3 | CONDICIONAL |
| 092904 | Yamasá                   |        29 |       253 |      163 |               35 |         13 |                  3.0 |                 4 |                 1 | CONDICIONAL |
| 050210 | Estebanía                |        02 |       274 |      162 |               22 |         10 |                  3.0 |                 6 |                 1 | CONDICIONAL |
| 031402 | Cabrera                  |        14 |       235 |      160 |               32 |         11 |                  3.0 |                 6 |                 3 | CONDICIONAL |
| 050202 | Las Charcas              |        02 |       281 |      155 |               37 |         13 |                  3.0 |                10 |                 3 | CONDICIONAL |
| 092901 | Monte Plata              |        29 |       266 |      148 |               34 |          9 |                  2.0 |                 9 |                 2 | CONDICIONAL |
| 092301 | San Pedro De Macorís     |        23 |       240 |      144 |               22 |         11 |                  4.5 |                 7 |                 4 | CONDICIONAL |
| 052108 | Los Cacaos               |        21 |       249 |      141 |               21 |         10 |                  4.0 |                 4 |                 1 | CONDICIONAL |
| 042701 | Mao                      |        27 |       172 |      140 |               33 |         10 |                  2.0 |                 3 |                 1 | CONDICIONAL |
| 092306 | Guayacanes               |        23 |       236 |      133 |               18 |          8 |                  5.5 |                 9 |                 2 | CONDICIONAL |
| 061006 | Mella                    |        10 |       167 |      125 |               25 |          9 |                  2.0 |                 0 |                 2 | CONDICIONAL |

<span id="tab:tabla-municipios-candidatos"></span>Table 1: Municipios
disponibles y características generales de los datos de biodiversidad
utilizados para evaluar su elegibilidad.

Las columnas significan:

- **Registros:** número de registros de GBIF conservados para el
  municipio.
- **Especies:** riqueza total observada en los registros disponibles.
- **H3 con registros:** número de hexágonos H3 con al menos un registro.
- **H3 ≥5 spp.:** número de hexágonos con cinco o más especies
  registradas.
- **Mediana registros/H3:** mediana de la intensidad de registro entre
  los H3 con registros.
- **Especies en ≥3 H3:** especies registradas en al menos tres
  hexágonos.
- **Grupos de hábitat:** número de clases de hábitat con representación
  suficiente según el diagnóstico de elegibilidad.

Utiliza estas cifras para valorar qué municipio ofrece condiciones
razonables para responder tu pregunta. **Un número mayor de registros o
especies no implica automáticamente que un municipio sea mejor para
cualquier pregunta biogeográfica.**

La lista de la tabla <a href="#tab:tabla-municipios-candidatos">1</a>,
que muestra los municipios elegibles y sus características de datos de
diversidad de plantas, también la puedes ver directamente abriendo el
archivo `00_resumen_elegibilidad_municipios.csv` del directorio
mencionado (fíjate sólo en aquellos que tengan “APTO” o “CONDICIONAL” en
la columna `categoria`).

Dentro del directorio `datos_por_municipio` del repo, fíjate en la lista
de directorios, cada uno es un paquete de datos utilizable. El paquete
de datos del municipio contendrá, como mínimo:

1.  un polígono del municipio (formato GeoPackage);
2.  registros de flora de GBIF ya sometidos a una limpieza espacial
    inicial (formato CSV);
3.  hexágonos H3 de resolución 7 que intersectan el municipio, con unas
    140 variables ambientales (formato GeoPackage);
4.  un resumen de elegibilidad y cobertura de muestreo (formato CSV).

La limpieza inicial elimina o marca coordenadas inválidas, coordenadas
problemáticas, registros próximos a centroides administrativos o
instituciones de biodiversidad y puntos que no pueden asignarse
espacialmente a un municipio dominicano, incluidos los situados fuera
del territorio municipal o en el mar. Este proceso **no garantiza que
todos los registros restantes sean correctos**. Debes continuar
auditando visualmente tus datos.

Sólo para fines de registro y para tu conocimiento, el archivo fuente de
GBIF que empleé para preparar los paquetes de datos por municipio que se
encuentran en `datos_por_municipio/`, se llama
`0003509-260715120105164.csv` (GBIF.org User, 2026). Dicho archivo, por
su gran tamaño, **no se distribuyó en este repositorio**. Sin embargo,
en tu manuscrito, debes referir dicha fuente GBIF usando la entrada
BibTeX correspondiente.

# Entregables

Debes generar **tres productos obligatorios**.

## 1. Manuscrito reproducible

Entrega un manuscrito breve generado desde **RMarkdown**, usando como
punto de partida `plantilla.Rmd`. El archivo fuente `.Rmd`, el PDF
final, `bibliografia.bib` y el código necesario deben encontrarse en tu
repositorio.

**Extensión sugerida:** 6–10 páginas, sin contar referencias ni material
suplementario.

El manuscrito debe contener, como mínimo:

- título y título corto;
- autor/a;
- resumen y palabras clave;
- introducción;
- materiales y métodos;
- resultados;
- discusión;
- conclusiones;
- referencias;
- declaración breve de reproducibilidad;
- nota breve de auditoría de IA.

Puedes desarrollar los análisis en
`analisis/00_cuaderno_trabajo_estudiante.Rmd`, ampliándolo,
modificándolo o adaptándolo a tus necesidades, aunque dicho cuaderno no
es un producto entregable. No olvides que el manuscrito final se
redactará a partir de `plantilla.Rmd`, el cual sí es un producto
entregable. Esto debo remarcarlo: **no uses el cuaderno de análisis como
referente, porque no contiene todos los análisis que se pueden hacer en
ecología numérica; es sólo un punto de partida para que desarrolles tus
ideas y experimentes con los datos**.

## 2. Diapositivas

Prepara una presentación breve, preferentemente de **8–10
diapositivas**, centrada en la pregunta, los datos, el flujo de
análisis, la evidencia principal, las limitaciones y la interpretación
biogeográfica.

## 3. Defensa oral

Realizarás una defensa oral de **7 minutos**. Debes poder explicar qué
representan tus datos, cómo construiste las matrices, por qué elegiste
tus variables, qué significa tu ordenación, cómo trataste la intensidad
de registro y qué limitaciones impiden interpretar los resultados como
un inventario completo de la flora municipal.

# Mandato

## 1. Formula una pregunta biogeográfica

No basta con “hacer un NMDS” o “hacer mapas de GBIF”. Debes formular
preguntas que puedan responderse con evidencia. Te incluyo algunas
preguntas de **ejemplo**; podrás escoger todas las que quieras, pero
debes incluir un mínimo de dos interrelacionadas entre sí.

1.  **¿Qué gradientes ambientales se asocian con las principales
    diferencias de composición florística entre los H3 del municipio?**
    Es probablemente la pregunta más general para NMDS + `envfit`.

2.  **¿La composición florística cambia a lo largo de un gradiente
    altitudinal dentro del municipio?** Muy apropiada para municipios
    con relieve suficiente.

3.  **¿La composición florística se relaciona más estrechamente con
    variables climáticas o con variables del relieve?** Permite comparar
    grupos de predictores sin necesidad de meter las ~140 variables.

4.  **¿Qué variables ambientales se asocian más fuertemente con la
    riqueza observada de plantas entre H3?**

5.  **¿Se mantiene la asociación entre riqueza observada y ambiente
    después de considerar la intensidad de registro de GBIF?** Esta me
    gusta especialmente porque obliga a comprender el problema de
    `n_registros`.

6.  **¿Cómo varían conjuntamente la riqueza observada y la intensidad de
    registro a través del municipio, y qué parte del patrón espacial de
    riqueza podría estar condicionada por esta última?** Más enfocada en
    sesgo espacial.

7.  **¿La cobertura arbórea se asocia con diferencias en riqueza y
    composición florística entre H3?**

8.  **¿Los H3 con mayor presencia de superficies agrícolas o construidas
    presentan una composición florística diferente de los H3 menos
    transformados?**

9.  **¿La distancia a infraestructuras se relaciona con la riqueza
    observada o con la composición de las especies registradas?**
    Interesante aprovechando `OSM-DIST`, aunque requiere mucha cautela
    interpretativa porque también puede reflejar accesibilidad y, por
    tanto, intensidad de registro.

10. **¿La heterogeneidad ambiental o del paisaje se asocia con una mayor
    riqueza observada de plantas?**

11. **¿La composición florística difiere entre los principales tipos de
    cobertura o hábitat representados en el municipio?** Sólo si hay
    replicación suficiente.

12. **¿Qué especies presentan asociaciones estadísticas con los
    principales tipos de hábitat del municipio?** Igualmente
    condicionada a que existan grupos adecuados.

13. **¿Los sectores ambientalmente extremos del municipio albergan
    conjuntos de especies diferentes de los sectores con condiciones
    ambientales intermedias?** Requiere que el estudiante defina qué
    entiende por extremo de manera reproducible.

14. **¿Existen sectores del municipio que sean florísticamente
    semejantes pese a encontrarse espacialmente separados, y qué
    condiciones ambientales comparten?** Esta aprovecha muy bien el NMDS
    y obliga a pensar biogeográficamente.

15. **¿Coinciden los principales gradientes de variación florística con
    los principales gradientes ambientales del municipio?** Es sencilla
    de formular pero permite una discusión bastante rica.

Las preguntas anteriores son sólo **ejemplos o puntos de partida**.
Puedes modificarlas o formular otras que sean compatibles con los datos
disponibles en tu municipio. Igualmente, las preguntas deben ser
concretas, responderse mediante las unidades H3 disponibles y conducir a
objetivos e hipótesis o expectativas razonadas coherentes. Por otra
parte, las hipótesis, el objetivo general y los específicos, deben ser
coherentes y deben abarcar todas las preguntas formuladas, pero evita
convertir la práctica en un proyecto de investigación semestral.

Te incluyo a continuación un **ejemplo de coherencia entre preguntas,
objetivo e hipótesis**. Supongamos que se plantean las preguntas «¿La
composición florística cambia a lo largo de un gradiente altitudinal
dentro del municipio?» y «¿Qué variables ambientales se asocian con las
principales diferencias de composición florística entre los H3 del
municipio?». Un objetivo general coherente podría ser «Evaluar la
asociación entre la variación ambiental, particularmente el gradiente
altitudinal, y la composición florística registrada entre los H3 del
municipio». Como hipótesis, podría plantearse que los H3 situados a
elevaciones y bajo condiciones ambientales semejantes presentarán
composiciones florísticas más similares entre sí que aquellos sometidos
a condiciones contrastantes.

**Comprueba primero que tu municipio permite responder la pregunta.**
Las preguntas sobre gradientes altitudinales requieren variación
altitudinal suficiente; una comparación entre hábitats requiere varios
hábitats con replicación; y una pregunta sobre urbanización, agricultura
o cobertura arbórea requiere que esas variables presenten variación
dentro del municipio. La disponibilidad de una variable en el GeoPackage
no garantiza que sea informativa dentro de tu área de estudio.

Reitero que las preguntas elegidas deben estar relacionadas entre sí y
contribuir a un planteamiento común; **no deben convertirse en dos
investigaciones independientes reunidas artificialmente en un mismo
manuscrito**. A partir de ellas, formula un objetivo general y, cuando
sea necesario, objetivos específicos e hipótesis o expectativas
razonadas que mantengan una correspondencia clara con las preguntas.
**No copies este ejemplo como planteamiento de tu estudio:** formula los
tuyos de acuerdo con el municipio, los datos disponibles y la literatura
que consultes.

## 2. Reconoce la unidad de análisis

El registro individual de GBIF **no será la unidad estadística
principal**. La unidad será el **hexágono H3 res. 7**. Para cada
hexágono construirás:

- una fila de la matriz de comunidad;
- una fila de la matriz ambiental;
- una estimación de riqueza observada;
- una medida de intensidad de registro (`n_registros`);
- una clase de hábitat/cobertura cuando proceda.

No interpretes el número de registros de una especie como abundancia
biológica. Para los análisis de composición usarás principalmente
**presencia/ausencia**.

## 3. Primera etapa obligatoria: exploración en QGIS

Antes de entrar a R, crea un proyecto de QGIS y representa:

- el límite municipal;
- los registros de GBIF;
- la malla H3;
- la riqueza observada y/o número de registros por H3, cuando ya la
  hayas calculado;
- **al menos tres variables ambientales** de familias distintas: una
  climática, una de relieve y una de cobertura/uso o influencia humana.

Comprueba visualmente puntos en la costa, límites municipales,
concentraciones anómalas y zonas sin registros. Los mapas que se
incluyan en el manuscrito deben ser **composiciones cartográficas
exportadas**, no capturas de pantalla de la interfaz de QGIS.

## 4. Construye y depura la matriz de comunidad

A partir de los registros limpios del municipio:

1.  identifica la columna taxonómica que representa la especie aceptada;
2.  elimina registros que no puedan asignarse a especie;
3.  asigna cada registro a un `hex_id`;
4.  reduce duplicados a **presencia/ausencia especie × hexágono**;
5.  construye una matriz con hexágonos en filas y especies en columnas;
6.  elimina especies excesivamente raras y hexágonos demasiado pobres
    sólo mediante un criterio declarado y justificado.

Como punto de partida puedes usar **especies presentes en ≥3 hexágonos**
y **hexágonos con ≥5 especies**, pero esos valores no son una ley.
Informa cuántos hexágonos y especies se pierden con el filtro y evalúa
si sigue existiendo información suficiente.

## 5. Construye una matriz ambiental manejable

El GeoPackage H3 contiene unas 140 variables. **No debes introducirlas
todas en un análisis sólo porque están disponibles.** Selecciona
inicialmente entre **6 y 12 variables** que representen procesos o
dimensiones ambientales distintas, por ejemplo:

- temperatura;
- precipitación;
- elevación;
- pendiente/rugosidad/posición topográfica;
- porcentaje de cobertura arbórea;
- agricultura o superficie construida;
- heterogeneidad del paisaje;
- distancia a infraestructura o presión humana, si su significado está
  documentado.

Después:

- elimina variables constantes o casi constantes dentro de tu municipio;
- inspecciona distribuciones y valores ausentes;
- revisa correlaciones entre variables;
- evita mantener predictores fuertemente redundantes en un mismo modelo;
- estandariza variables continuas antes de ordenaciones o comparaciones
  multivariadas cuando sea necesario.

**Debes documentar el significado y las unidades de cada variable
elegida.** Los prefijos del GeoPackage orientan sobre la fuente, pero no
sustituyen la consulta de los metadatos de la fuente original.

## 6. Describe el sesgo y la intensidad de registro

Genera, como mínimo:

- número de registros limpios;
- riqueza total observada;
- número de hexágonos con registros;
- distribución de registros por hexágono;
- distribución de riqueza por hexágono;
- relación entre riqueza observada y número de registros.

Si riqueza e intensidad de registro están fuertemente asociados, esto
**no invalida** automáticamente el análisis, pero limita la
interpretación y obliga a incorporar la intensidad de registro en la
regresión y en la discusión.

## 7. Ordenación multivariada de la composición

Realiza una ordenación **NMDS** usando la matriz de presencia/ausencia y
una disimilitud apropiada para datos binarios, por ejemplo Jaccard.
Debes:

- informar la dimensión (`k`), el número de intentos y el estrés;
- examinar el gráfico de estrés/convergencia;
- representar los hexágonos en el espacio de ordenación;
- ajustar las variables ambientales seleccionadas mediante `envfit` u
  otra técnica equivalente;
- interpretar direcciones y asociaciones sin convertir correlación en
  causalidad.

Si el NMDS es inestable o tiene estrés inaceptable, debes diagnosticar
el problema: pocos sitios, demasiados ceros compartidos, especies
excesivamente raras o estructura insuficiente.

## 8. Diferencias de composición entre hábitats

Define una variable de hábitat a partir de la cobertura dominante u otra
clasificación ecológicamente defendible. Si existen **al menos dos
grupos con replicación suficiente**, evalúa si la composición difiere
entre hábitats mediante PERMANOVA (`adonis2`) o método equivalente.

Antes de interpretar una PERMANOVA, evalúa la dispersión multivariada
(`betadisper`). Una diferencia significativa entre grupos puede reflejar
diferencias de centroides, diferencias de dispersión o ambas.

Si tu municipio no contiene suficientes tipos de hábitat o alguno tiene
muy pocos hexágonos, **no fuerces la prueba**. Puedes justificar una
reclasificación más gruesa o reportar que el diseño no permite esa
comparación.

## 9. Regresión: riqueza observada y ambiente

Construye al menos **un modelo de regresión** en el que la respuesta sea
la riqueza observada por H3. El modelo debe considerar explícitamente
`n_registros` como intensidad de registro o, a lo sumo, como proxy del
esfuerzo de muestreo —con mucha cautela en esta interpretación—,
mediante una transformación, término funcional o estrategia estadística
que puedas justificar. No asumas automáticamente que la relación entre
número de registros y riqueza observada es lineal. El modelo debe
incluir:

- `log1p(n_registros)` o una medida equivalente de la “intensidad de
  registro” o “proxy del esfuerzo de muestreo”;
- un conjunto pequeño de predictores ambientales no redundantes;
- una familia/distribución coherente con la respuesta y los residuos.

Una opción sencilla es comenzar con Poisson, evaluar sobredispersión y,
si existe, utilizar un modelo binomial negativo o cuasi-Poisson. No
selecciones variables únicamente por su valor *p*. La interpretación
debe apoyarse en el signo, magnitud, incertidumbre y plausibilidad
ecológica del efecto.

## 10. Asociación de especies con hábitat

Cuando existan grupos de hábitat adecuados, utiliza un análisis de
especies indicadoras, por ejemplo `indicspecies::multipatt`, para
evaluar qué especies muestran asociación con uno o varios tipos de
hábitat.

Debes distinguir entre:

- una especie frecuente;
- una especie exclusiva;
- una especie indicadora;
- una asociación estadística con el agrupamiento usado.

No presentes como “indicadora ecológica” una especie sólo porque
apareció una vez en un hábitat.

## 11. Integra los resultados

La ordenación, la regresión y la asociación con hábitat **no son tres
tareas independientes**. En el manuscrito debes integrarlas para
responder una misma pregunta o conjunto pequeño de preguntas
relacionadas. Si realizaste otros análisis además de los mencionados,
este es el lugar para incluir sus resultados, sin olvidar detallarlos en
la sección “Materiales y métodos”.

# Reglas mínimas del análisis

1.  pregunta explícita e hipótesis/expectativa razonada;
2.  proyecto QGIS con exploración espacial documentada;
3.  matriz de comunidad reproducible;
4.  matriz ambiental con selección de variables justificada;
5.  descripción de la intensidad de registro (número de puntos de
    registros de GBIF, traducido a veces, con “licencia”, como
    “ocurrencias”);
6.  NMDS + ajuste ambiental;
7.  regresión de riqueza con control de intensidad de registro;
8.  evaluación explícita de si los datos permiten comparar hábitats y,
    cuando exista replicación suficiente, PERMANOVA + diagnóstico de
    dispersión;
9.  evaluación explícita de si los datos permiten analizar asociaciones
    de especies con hábitats y, cuando proceda, análisis de especies
    indicadoras;
10. **mínimo 3 figuras científicas**, al menos una cartográfica y una
    multivariada;
11. **mínimo 2 tablas** generadas reproduciblemente;
12. al menos **4 resultados cuantitativos** escritos en el texto;
13. rutas relativas y código ejecutable;
14. CRS, escala H3, filtros y criterios documentados;
15. discusión explícita del sesgo de GBIF y de las limitaciones de
    inferencia.

# Flujo de trabajo recomendado

Antes de comenzar, ten en cuenta que el repositorio contiene dos
archivos con funciones diferentes:

- `analisis/00_cuaderno_trabajo_estudiante.Rmd`: úsalo como **cuaderno
  de trabajo** para explorar los datos, construir matrices, probar
  análisis, generar diagnósticos y desarrollar el código. Puedes
  modificarlo libremente y añadir tantos bloques como necesites.
- `plantilla.Rmd`: úsala para redactar el **manuscrito científico
  final**. No conviertas el manuscrito en una transcripción del cuaderno
  de trabajo: selecciona e integra en él únicamente el código, las
  figuras, las tablas y los resultados necesarios para responder tu(s)
  pregunta(s).

El cuaderno de trabajo puede ser extenso y contener ensayos,
comprobaciones y resultados intermedios. El manuscrito, en cambio, debe
ser una narración científica concisa.

## Etapa 1 — Explorar y formular

- abre el paquete municipal en QGIS;
- inspecciona distribución de registros y variables;
- busca bibliografía sobre flora, ambientes y biogeografía de la región;
- formula pregunta e hipótesis.

## Etapa 2 — Preparar matrices

- importa registros y H3 en R;
- genera tabla especie–H3;
- genera matriz de presencia/ausencia;
- genera matriz ambiental en el mismo orden de H3;
- calcula riqueza e intensidad de registro;
- verifica que las filas de ambas matrices coincidan exactamente.

## Etapa 3 — Explorar y reducir variables

- estadísticas descriptivas;
- histogramas/densidades;
- mapa de variables clave;
- matriz de correlación;
- selección final de predictores.

## Etapa 4 — Analizar

- NMDS de composición;
- `envfit`;
- PERMANOVA y `betadisper`, si procede;
- regresión de riqueza;
- especies indicadoras, si procede.

## Etapa 5 — Verificar e interpretar

- comprueba supuestos y diagnósticos;
- vuelve al mapa para interpretar valores extremos;
- evalúa sensibilidad a filtros de especies/hexágonos;
- distingue señal ecológica de señal de muestreo.

## Etapa 6 — Redactar

Redacta el minimanuscrito usando `plantilla.Rmd`. El texto debe poder
leerse sin necesidad de abrir la consola de R.

# Estructura del manuscrito

## Introducción

Extensión orientativa: **3–5 párrafos**. Debe presentar el problema,
justificar por qué el ambiente puede estructurar la biodiversidad a
escala intramunicipal, reconocer el carácter oportunista de GBIF y
terminar con pregunta, objetivo e hipótesis.

## Materiales y métodos

Debe incluir:

- municipio y contexto espacial;
- procedencia y limpieza de GBIF;
- H3 resolución 7 como unidad espacial;
- fuentes/familias de variables ambientales;
- construcción y filtrado de la matriz de comunidad;
- selección y estandarización de variables;
- NMDS y disimilitud usada;
- `envfit`;
- PERMANOVA/dispersiones si procede;
- modelo de riqueza y tratamiento de la intensidad de registro;
- análisis de especies indicadoras si procede;
- software y versiones.

## Resultados

Presenta evidencia, no salidas crudas. Incluye como mínimo:

- un mapa analítico;
- un gráfico de ordenación;
- una figura de riqueza frente a intensidad de registro o una figura
  derivada de la regresión;
- dos tablas de resultados.

Las tablas deben generarse reproduciblemente a partir de objetos de
datos. Según los análisis realizados, pueden presentar, entre otros:

- el resumen de registros, especies y H3;
- las variables ambientales seleccionadas, sus unidades y fuentes;
- los resultados de `envfit`;
- los resultados de PERMANOVA y de la prueba de dispersión, cuando
  procedan;
- los coeficientes del modelo de riqueza;
- las especies indicadoras significativas, cuando procedan.

Selecciona las tablas que aporten evidencia necesaria para responder tu
pregunta; no es obligatorio producir todas las anteriores.

## Discusión

Debes responder explícitamente la pregunta y discutir:

- qué gradientes ambientales parecen estar asociados con composición o
  riqueza;
- qué parte del patrón puede deberse a la intensidad de registro
  desigual de GBIF;
- si la clasificación de hábitat fue suficiente para detectar
  diferencias;
- qué especies mostraron asociaciones y con qué cautelas;
- limitaciones de la resolución H3 y del uso de variables agregadas;
- problemas taxonómicos y geográficos de datos secundarios;
- qué mejoraría con inventarios de campo estandarizados.

## Conclusiones

Entre **1 y 3 párrafos breves**, directamente respaldados por
resultados.

## Declaración de reproducibilidad

Indica dónde está el código, cuáles datos fueron proporcionados, qué
archivos grandes no se incluyen, las versiones de software y cualquier
paso manual.

## Auditoría de IA

Incluye **100–200 palabras** con herramienta, tarea, error/limitación
concreta, método de verificación y corrección.

# Requisitos formales del manuscrito

El producto entregado debe funcionar como un **manuscrito científico
completo**, no como un informe de ejercicios ni como una sucesión de
salidas de R. El texto, las figuras, las tablas, las referencias
cruzadas, las citas y la lista de referencias, deben estar integrados en
una narración científica coherente, usando las herramientas que ofrece
RMarkdown para ello.

## Nomenclatura biológica

Los nombres científicos de géneros y especies deben escribirse en
cursiva y con la capitalización taxonómica correspondiente. Utiliza de
manera consistente los nombres taxonómicos adoptados durante la
depuración de los datos y documenta cualquier corrección o decisión
taxonómica adicional.

## Citas y referencias bibliográficas

- Utiliza **citas parentéticas y narrativas** según corresponda al
  sentido de la oración.
- Las citas deben insertarse mediante las claves de `bibliografia.bib`;
  no escribas manualmente autores, años ni la lista final de
  referencias.
- Toda afirmación procedente de la literatura, así como las decisiones
  metodológicas que requieran respaldo, debe estar adecuadamente citada.
- La sección de referencias debe generarse automáticamente a partir de
  las obras realmente citadas en el manuscrito.
- Busca y utiliza bibliografía científica específica sobre el municipio,
  la flora, los gradientes ambientales o los métodos empleados; no
  dependas únicamente de las referencias proporcionadas en esta
  práctica.
- Evita tanto los párrafos sin respaldo bibliográfico cuando éste sea
  necesario como la acumulación de citas que no se discuten ni se
  relacionan con el argumento.

En RMarkdown, por ejemplo:

`[@zizka2019coordinatecleaner]`

produce una cita parentética, mientras que:

`@zizka2019coordinatecleaner`

puede utilizarse para integrar narrativamente al autor en la oración.

## Figuras, tablas y referencias cruzadas

Todas las figuras y tablas deben:

1.  tener numeración y un *caption* informativo;
2.  poder comprenderse razonablemente sin consultar el código que las
    generó;
3.  estar mencionadas e interpretadas explícitamente en el texto;
4.  aparecer después de haber sido introducidas o tan cerca como sea
    razonable de su primera mención;
5.  utilizar **referencias cruzadas automáticas de RMarkdown/bookdown**,
    no números escritos manualmente.

Por ejemplo, una figura con etiqueta `fig:mapa-riqueza` debe mencionarse
mediante `\@ref(fig:mapa-riqueza)`, y una tabla con etiqueta
`tab:variables-ambientales` mediante `\@ref(tab:variables-ambientales)`.

No escribas manualmente expresiones como “véase la Figura 2” si el
número `2` ha sido introducido a mano, porque la numeración puede
cambiar al regenerar el manuscrito.

## Resultados en el texto

Las figuras y tablas **no sustituyen la redacción de resultados**. El
texto debe señalar los patrones importantes y aportar evidencia
cuantitativa concreta.

Incluye al menos **cuatro resultados cuantitativos** dentro de la prosa
del apartado de Resultados. Siempre que sea razonable, esos valores
deben proceder directamente de objetos de R mediante código en línea, en
lugar de ser copiados manualmente.

No pegues salidas completas de la consola (`summary()`, `adonis2()`,
`envfit()`, `glm()`, etc.) como resultados. Extrae, organiza y presenta
únicamente la información necesaria mediante texto, tablas y figuras.

Cuando informes resultados estadísticos, identifica el estadístico, los
grados de libertad cuando correspondan, el tamaño o magnitud del efecto
y la incertidumbre o significación pertinente. No reduzcas la
interpretación a indicar si `p < 0.05`.

## Código y salidas

El código es el mecanismo de reproducibilidad del manuscrito, pero **no
es su narrativa**.

- Evitar mostrar código que no sea necesario para comprender o
  reproducir el análisis.
- Suprime mensajes, advertencias y salidas auxiliares que no formen
  parte de los resultados (suele lograrse con opciones como
  `message=FALSE, warning=FALSE` al declarar las
  `knitr::opts_chunk$set`).
- Las tablas científicas deben construirse a partir de objetos de R e
  imprimirse con `knitr::kable()` o herramientas compatibles, como
  `kableExtra`. Se admitirán tablas Markdown sólo excepcionalmente
  cuando procedan de fuentes externas y no formen parte del flujo
  analítico reproducible. Siempre que sea posible, convierte también
  esas tablas en objetos de R.
- Las figuras analíticas deben generarse reproduciblemente.
- Las decisiones manuales realizadas en QGIS u otro programa deben
  documentarse.
- El manuscrito final debe poder leerse de principio a fin sin necesidad
  de interpretar una consola de R.

# Reproducibilidad técnica

- usa rutas relativas, no uses rutas absolutas;
- conserva datos originales separados de productos derivados;
- fija semilla para procedimientos con aleatoriedad;
- no edites manualmente tablas que puedan regenerarse;
- guarda la información de la sesión en `session_info_manuscript.txt` y
  referencia ese archivo en la declaración de reproducibilidad; no
  imprimas `sessionInfo()` completo dentro del manuscrito;
- guarda el proyecto QGIS (`.qgz`) en el repositorio;
- documenta cualquier reclasificación o edición manual.

# Organización sugerida en tres jornadas

## Día 1 — QGIS, pregunta y matrices

Exploración espacial, selección del municipio, control de calidad,
matriz de comunidad, matriz ambiental y primera pregunta.

## Día 2 — Estadística e interpretación

NMDS, ajuste ambiental, análisis de hábitat, regresión, especies
indicadoras y figuras definitivas.

## Día 3 — Manuscrito y defensa

Redacción, citas, auditoría de IA, regeneración limpia del PDF,
diapositivas y ensayo.

# Lista de comprobación antes de entregar

- [ ] Mi trabajo contiene una pregunta biogeográfica explícita.
- [ ] Puedo explicar por qué los registros de GBIF no son abundancias.
- [ ] Exploré los datos en QGIS y guardé el proyecto.
- [ ] Documenté la limpieza y los filtros adicionales.
- [ ] Mi matriz de comunidad y ambiental tienen exactamente los mismos
  H3 y orden.
- [ ] Justifiqué las variables ambientales elegidas.
- [ ] Describí la intensidad de registro por H3.
- [ ] Informé el estrés del NMDS.
- [ ] Interpreté `envfit` como asociación, no causalidad.
- [ ] Verifiqué dispersión antes de interpretar PERMANOVA, si la usé.
- [ ] La regresión incluye una medida de la intensidad de registro de
  GBIF.
- [ ] No forcé un análisis de hábitat cuando faltaba replicación.
- [ ] Tengo al menos tres figuras y dos tablas.
- [ ] Todas las figuras y tablas se citan en el texto.
- [ ] Utilicé citas parentéticas y narrativas donde correspondía.
- [ ] Todas las citas proceden de `bibliografia.bib`.
- [ ] La lista de referencias se genera automáticamente y sólo contiene
  obras citadas.
- [ ] Utilicé referencias cruzadas automáticas para figuras y tablas.
- [ ] No escribí manualmente números de figuras o tablas.
- [ ] Mis captions permiten comprender qué representa cada figura o
  tabla.
- [ ] Incluí al menos cuatro resultados cuantitativos en la prosa de
  Resultados.
- [ ] Las cifras importantes insertadas en el texto proceden de R cuando
  es razonable.
- [ ] No utilicé salidas crudas de la consola como sustituto de tablas o
  resultados.
- [ ] Incluí limitaciones de GBIF y H3.
- [ ] El manuscrito se regenera desde RMarkdown.
- [ ] Incluí declaración de reproducibilidad.
- [ ] Incluí auditoría de IA o declaré que no utilicé IA.
- [ ] El PDF final compila sin errores.
- [ ] Los nombres científicos están correctamente escritos y
  formateados.
- [ ] Informé los resultados estadísticos con magnitud y no sólo
  mediante valores *p*.

# Criterios de evaluación del manuscrito

| Criterio                    | Nivel 1                           | Nivel 2                             | Nivel 3                                                 | Nivel 4                                                             |
|-----------------------------|-----------------------------------|-------------------------------------|---------------------------------------------------------|---------------------------------------------------------------------|
| Pregunta biogeográfica      | Ausente/operativa                 | Implícita                           | Clara y respondible                                     | Clara, pertinente y bien justificada                                |
| Comprensión de GBIF         | Confunde registros con abundancia | Reconoce sesgo de forma superficial | Distingue registros, presencia e intensidad de registro | Integra sesgo e intensidad de registro en análisis e interpretación |
| Matrices comunidad–ambiente | Incorrectas                       | Parciales                           | Correctas y alineadas                                   | Correctas, auditadas y bien justificadas                            |
| Estadística multivariada    | Incorrecta                        | Aplicación mecánica                 | Correcta                                                | Correcta, diagnosticada e integrada ecológicamente                  |
| Regresión                   | Incorrecta                        | Básica/sin esfuerzo                 | Adecuada y con esfuerzo                                 | Bien diagnosticada, parsimoniosa e interpretada                     |
| Asociación con hábitat      | Forzada/incorrecta                | Descriptiva                         | Correcta cuando procede                                 | Justificada, cauta e integrada con la ecología                      |
| Evidencia espacial          | Ausente                           | Mapas básicos                       | Mapas correctos                                         | Excelente integración SIG–estadística                               |
| Reproducibilidad            | No reproducible                   | Parcial                             | Bien documentada                                        | Flujo limpio, ejecutable y auditable                                |
| Redacción científica        | Deficiente                        | Comprensible                        | Clara                                                   | Precisa, fluida y argumentativa                                     |
| Figuras/tablas              | Incorrectas/ausentes              | Básicas                             | Correctas                                               | Excelente diseño e integración                                      |
| Discusión                   | Repite resultados                 | Superficial                         | Interpreta y reconoce limitaciones                      | Integra ambiente, muestreo, escala y literatura                     |
| Auditoría de IA             | Ausente/inventada                 | Genérica                            | Error concreto verificado                               | Auditoría convincente y útil                                        |

# Criterios de evaluación de la defensa

| Criterio                 | Nivel 1               | Nivel 2          | Nivel 3               | Nivel 4                                |
|--------------------------|-----------------------|------------------|-----------------------|----------------------------------------|
| Comprensión del problema | Confusa               | Parcial          | Clara                 | Muy clara y bien motivada              |
| Datos y sesgos           | No comprende GBIF     | Reconoce algunos | Explica correctamente | Explica implicaciones sobre inferencia |
| Método                   | No comprende el flujo | Parcial          | Correcto              | Justifica decisiones y alternativas    |
| Lectura de figuras       | No interpreta         | Describe         | Interpreta            | Sintetiza evidencia con precisión      |
| Limitaciones             | Ausentes              | Genéricas        | Adecuadas             | Críticas y específicas                 |
| Auditoría IA             | No demostrada         | Débil            | Verificada            | Demuestra error, causa y corrección    |
| Respuestas               | No responde           | Limitadas        | Correctas             | Argumenta y reconoce incertidumbre     |

# Referencias de partida

Para ecología numérica y análisis multivariado, consulta especialmente
Legendre y Legendre (2012), Borcard et al. (2018) y la documentación de
`vegan`. Para limpieza de coordenadas utiliza como referencia Zizka
et al. (2019). La lógica de especies indicadoras se apoya en Dufrêne y
Legendre (1997) y De Cáceres y Legendre (2009). Para PERMANOVA consulta
Anderson (2001).

No debes limitar tu búsqueda a esta lista. Busca bibliografía reciente y
específica sobre la flora, los ambientes y la historia de colecta del
municipio que trabajes.

<div id="refs" class="references csl-bib-body hanging-indent"
entry-spacing="0" line-spacing="2">

<div id="ref-anderson2001new" class="csl-entry">

Anderson, M. J. (2001). A new method for non-parametric multivariate
analysis of variance. *Austral Ecology*, *26*(1), 32-46.
<https://doi.org/10.1111/j.1442-9993.2001.01070.pp.x>

</div>

<div id="ref-borcard2018numerical" class="csl-entry">

Borcard, D., Gillet, F. y Legendre, P. (2018). *Numerical Ecology with
R* (2.ª ed.). Springer. <https://doi.org/10.1007/978-3-319-71404-2>

</div>

<div id="ref-decaceres2009associations" class="csl-entry">

De Cáceres, M. y Legendre, P. (2009). Associations between species and
groups of sites: indices and statistical inference. *Ecology*, *90*(12),
3566-3574. <https://doi.org/10.1890/08-1823.1>

</div>

<div id="ref-dufrene1997species" class="csl-entry">

Dufrêne, M. y Legendre, P. (1997). Species assemblages and indicator
species: the need for a flexible asymmetrical approach. *Ecological
Monographs*, *67*(3), 345-366.
[https://doi.org/10.1890/0012-9615(1997)067\[0345:SAAIST\]2.0.CO;2](https://doi.org/10.1890/0012-9615(1997)067[0345:SAAIST]2.0.CO;2)

</div>

<div id="ref-gbiforg_user_occurrence_2026" class="csl-entry">

GBIF.org User. (2026). *Occurrence Download*. The Global Biodiversity
Information Facility. <https://doi.org/10.15468/DL.J9PWMZ>

</div>

<div id="ref-legendre2012numerical" class="csl-entry">

Legendre, P. y Legendre, L. (2012). *Numerical Ecology* (3.ª ed.).
Elsevier.

</div>

<div id="ref-jose_ramon_martinez_batlle_2022_7367180" class="csl-entry">

Martínez-Batlle, J. R. (2022). *geofis/zonal-statistics: Let there be
environmental variables* (Versión v0.0.0.9000). Zenodo.
<https://doi.org/10.5281/zenodo.7367256>

</div>

<div id="ref-zizka2019coordinatecleaner" class="csl-entry">

Zizka, A., Silvestro, D., Andermann, T., Azevedo, J., Duarte Ritter, C.,
Edler, D., Farooq, H., Herdean, A., Ariza, M., Scharn, R., Svantesson,
S., Wengström, N., Zizka, V. y Antonelli, A. (2019). CoordinateCleaner:
Standardized cleaning of occurrence records from biological collection
databases. *Methods in Ecology and Evolution*, *10*(5), 744-751.
<https://doi.org/10.1111/2041-210X.13152>

</div>

</div>
