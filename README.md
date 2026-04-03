
# ¿Se pagan solas las elecciones en el Perú?: Un análisis de costos y multas electorales

Al revisar el manual del elector para las elecciones presidenciales de
2026, encontré un aspecto que llamó particularmente mi atención. En él
se establece que las multas por no ejercer el voto se determinan como
una proporción de la Unidad Impositiva Tributaria (UIT), específicamente
entre el 0.5% y el 2%, dependiendo del nivel de pobreza del distrito
consignado en el DNI.

Este detalle me llevó a reflexionar sobre una implicancia importante:
dado que la UIT ha mostrado una tendencia creciente en el tiempo, las
multas asociadas a la inasistencia electoral también tienden a
incrementarse de manera automática. En otras palabras, no votar se
vuelve progresivamente más costoso.

A partir de esta observación, me surgieron algunas preguntas que
considero relevantes. ¿Al final, las elecciones se pagan solas? ¿No será
que, más que un gasto, terminan generando ingresos?

Estas inquietudes motivan el desarrollo del presente repositorio. En los
apartados siguientes, me propongo analizar con mayor detalle la relación
entre los costos del proceso electoral y la recaudación derivada de las
multas por no votar.

Para tal fin, tomo como base las elecciones generales de 2021 y
considero únicamente los resultados a nivel nacional. No incluyo los
resultados correspondientes al ámbito internacional, dado que los
electores en el extranjero no están sujetos al pago de multas por
omisión al voto (con excepción de los miembros de mesa). Por último, no
incorporo información relacionada con las multas aplicables a los
miembros de mesa, debido a la falta de disponibilidad de datos al
respecto.

## Tasa de inasistencia en las elecciones

Para la primera vuelta de las elecciones a nivel nacional, observé que
la tasa de inasistencia electoral alcanzó aproximadamente el 28%. Este
nivel de ausentismo, lejos de mantenerse, se redujo en la segunda
vuelta, donde registró un valor cercano al 23.8%. Este comportamiento
sugiere una mayor participación ciudadana en la etapa decisiva del
proceso electoral.

<p align="center">

<img src="plots\tab1.png" width="500px">
</p>

No obstante, este comportamiento no es el habitual. Según una nota de
prensa del diario El Comercio, las elecciones de 2021 constituyen el
primer proceso desde 2001 en el que la tasa de inasistencia disminuye en
la segunda vuelta. Considero plausible que este resultado esté asociado,
al menos en parte, a los efectos de la pandemia, que habrían influido
tanto en los niveles de participación inicial como en la dinámica de
movilización del electorado entre ambas rondas.

### Tasa de inasistencia por departamentos.

Para la primera vuelta, el mayor ausentismo se concentra en
departamentos del norte del país, muchos de los cuales pertenecen a la
selva peruana, lo que podría estar asociado a factores estructurales
como la dispersión geográfica, limitaciones en infraestructura o
dificultades de acceso a los locales de votación. En contraste, en la
zona sur se observan los niveles más bajos de inasistencia.

<p align="center">

<img src="plots\img1.png" width="700px">
</p>

En la segunda vuelta, el patrón general se mantiene, aunque se aprecian
algunas variaciones que resultan relevantes. En particular, los
departamentos del centro del país muestran un incremento relativo en la
inasistencia al sufragio respecto a la primera ronda. Este cambio podría
reflejar dinámicas específicas del contexto electoral, como variaciones
en el interés por las candidaturas en competencia o factores
coyunturales que afectan la decisión de participación.

<p align="center">

<img src="plots\img2.png" width="700px">
</p>

En conjunto, estos resultados permiten evidenciar que la inasistencia no
se distribuye de manera homogénea en el territorio, sino que responde a
características regionales diferenciadas.

### Tasa de inasistencia por nivel de pobreza

Las tasas de inasistencia tampoco son homogéneas cuando se analizan
según el nivel de pobreza. En particular, los electores en condición de
pobreza extrema presentan una mayor propensión a no acudir a sufragar en
términos proporcionales. Para los comicios de 2021, aproximadamente el
41.6% de los electores clasificados en pobreza extrema no asistieron a
votar.

<p align="center">

<img src="plots\tab2.png" width="500px">
</p>

A continuación, se muestra la tasa de inasistencia para cada una de las
rondas electorales. En ellas se observa que el patrón se mantiene
relativamente estable entre ambas vueltas, evidenciando que las
diferencias en la participación según nivel de pobreza no responden a un
fenómeno aislado de una sola ronda, sino a una dinámica consistente a lo
largo de todo el proceso electoral.

<p align="center">

<img src="plots\tab3.png" width="500px">
</p>

## Multas asociadas a la inasistencia en las elecciones

Las multas por inasistencia al sufragio no son homogéneas, sino que se
diferencian según el nivel de pobreza del distrito consignado en el DNI
del elector. Para las elecciones generales de 2021, la estructura de
sanciones fue la siguiente: las personas clasificadas como pobres
extremos debían pagar 22 soles, los pobres 44 soles y los no pobres 88
soles.

Esta diferenciación introduce un componente distributivo en el esquema
de sanciones, en la medida en que ajusta el monto de la multa en función
de las condiciones socioeconómicas del elector. Desde una perspectiva
analítica, este aspecto resulta relevante, ya que la recaudación
potencial no solo depende del nivel de inasistencia, sino también de la
composición socioeconómica de los distritos donde esta se concentra.

Es importante precisar que, en este análisis, no se consideran las
multas asociadas a la inasistencia de los miembros de mesa, debido a la
falta de información disponible sobre este componente.

Considerando conjuntamente la tasa de inasistencia y la estructura de
multas diferenciada por nivel de pobreza, el monto potencial de
recaudación en ambas rondas electorales asciende a S/ 1,031,148,734. De
este total, S/ 557,379,196 corresponden a la primera vuelta, mientras
que S/ 473,769,538 se asocian a la segunda vuelta.

<p align="center">

<img src="plots\img3.png" width="700px">
</p>

<p align="center">

<img src="plots\img4.png" width="700px">
</p>

<p align="center">

<img src="plots\img5.png" width="700px">
</p>

Este cálculo representa un escenario teórico de recaudación, en el que
se asume el cumplimiento pleno del pago de las multas. Por ello, resulta
pertinente interpretarlo como una aproximación al monto máximo
potencial, más que como una cifra efectivamente recaudada. A
continuación, se muestra los montos de las multas por departamentos y
por cada una de las rondas de las elecciones generales 2021.

## Presupuesto de las elecciones generales 2021

Según información del Jurado Nacional de Elecciones, para las elecciones
generales de 2021 se solicitó un presupuesto total de S/ 804,010,922.
Este monto se descompone de la siguiente manera: S/ 112,438,757
destinados a las funciones propias del Jurado Nacional de Elecciones, S/
406,568,510 asignados a la ONPE, y S/ 11,743,530 correspondientes a la
RENIEC. Adicionalmente, se contemplaron demandas complementarias por un
total de S/ 273,260,125.

<p align="center">

<img src="plots\tab4.png" width="500px">
</p>

## ¿Se pagan solas las elecciones?

Al comparar el monto potencial de recaudación por multas con el
presupuesto destinado a las elecciones generales de 2021, la recaudación
superaría dicho presupuesto en S/ 227,137,812. En términos relativos,
esto implica que se recaudaría aproximadamente un 28.3% más de lo que
costó la organización del proceso electoral.

<p align="center">

<img src="plots\tab5.png" width="700px">
</p>

## Consideraciones importantes

Los beneficios potenciales asociados a la realización de las elecciones
podrían incrementarse al considerar las multas aplicables a los miembros
de mesa que no cumplieron con su función. De acuerdo con la Ley N.º
28859, dichas sanciones ascienden al 5% de una UIT, lo que introduce una
fuente adicional de recaudación que no ha sido incorporada en las
estimaciones previas.

Por otro lado, el pago que reciben los miembros de mesa por su
participación durante la jornada electoral presumiblemente se encuentra
incluido dentro del presupuesto asignado a la ONPE, aunque no dispongo
de confirmación explícita sobre este punto. En caso de no estar
completamente internalizado en dicho presupuesto, es razonable suponer
que estos costos podrían verse, al menos parcialmente, compensados por
las multas impuestas a aquellos miembros de mesa que no asistieron.

## ¿Qué podría pasar en las elecciones 2026?

Para las elecciones de 2026, las multas han aumentado en términos
nominales como consecuencia del incremento de la UIT. En este nuevo
escenario, la escala de sanciones se establece en S/ 110 para los no
pobres, S/ 55 para los pobres y S/ 27.5 para los pobres extremos.
Asimismo, el padrón electoral se ha incrementado en aproximadamente 1.8
millones de electores respecto al proceso de 2021.

Bajo estas condiciones, mayor número de electores y mayores montos de
multa, y suponiendo que la tasa de inasistencia se mantenga en niveles
similares a los observados en 2021, se estima que el monto potencial de
recaudación podría superar los S/ 1,385,714,369 que es un monto superior
a lo presupuestado para los comicios de 2026, que según el JNE es de S/
820,738,683.

A continuación, se muestra una simulación de los posibles ingresos por
multas dada distintas tasas de ausentismo en las elecciones generales.

<p align="center">

<img src="plots\img6.png" width="700px">
</p>

## Fuentes de información

**En relación a las multas.**

Mapa distrital de pobreza:

<https://portal.jne.gob.pe/portal_documentos/files/cd538695-055d-4bbb-a080-a3f282466692.pdf>

Resultados de las elecciones:

- <https://www.datosabiertos.gob.pe/dataset/resultados-por-mesa-de-las-elecciones-presidenciales-2021-primera-vuelta-oficina-nacional-0>

- <https://www.datosabiertos.gob.pe/dataset/resultados-por-mesa-de-las-elecciones-presidenciales-2021-segunda-vuelta-oficina-nacional-2>

Multas por no ir a sufragar en el año 2021:

<https://elcomercio.pe/politica/multa-por-no-votar-elecciones-2021-de-cuanto-es-la-multa-por-no-haber-ido-a-votar-onpe-multas-electorales-elecciones-generales-peru-2021-miembros-de-mesa-jornada-electoral-nndc-noticia/>

**En relación al presupuesto.**

Presupuesto para las elecciones generales del 2021:

<https://portal.jne.gob.pe/Portal/Pagina/Nota/8409/>
