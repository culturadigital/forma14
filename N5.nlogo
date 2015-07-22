;-------------------------Definición de las propiedades y variables del entorno-------------------------

globals[
  densidad_real
  densidad_estimada
  error_mapa
  
  crecimiento_t1 
  crecimiento_t2
  crecimiento_t3
  
  num_patches_t1
  num_patches_t2
  num_patches_t3
  ]

patches-own[
  ;GRANDIENTES
  g_pendiente
  g_distCarretera
  g_atraccionUrbana
  g_total
  
  ;TIPO DE TERRENO
  ;   - -1= Carretera
  ;   - 0 = Campo
  ;   - 1 = Discontinuo Disperso
  ;   - 2 = Discontinuo denso
  ;-------------------------------
  ;   - 3 = Continuo denso
  ;   - 4 = agua
  ;   - 5 = industria
  ;   - 7 = pendiente alta
  ;   - 8 = ambito
  tipo
]

;-------------------------Comienzo del programa principal-------------------------

;Método para resetear el entorno.
to inicializar
 clear-all
 
 ask patches 
 [
   set tipo 0 ;tipo campo
   set g_pendiente 0
   set g_distCarretera 0
   set g_atraccionUrbana 0
   set g_total 0
   set densidad_estimada 0
 ] 
 reset-ticks
 
 set densidad_real 15533
 
 set crecimiento_t1 7.53 / 100.0
 set crecimiento_t2 9.45 / 100.0
 set crecimiento_t3 2.41 / 100.0
 
 ; CARGAR MAPAS
 cargarMapas
 set num_patches_t1 count patches with [tipo = 1]
 set num_patches_t2 count patches with [tipo = 2]
 set num_patches_t3 count patches with [tipo = 3]
 
 normalizar
 colorear
 
end

to normalizar
 ; Buscamos el valor de la máxima pendiente
 let max_g_pendiente -1
 ask patches[
   if (max_g_pendiente < g_pendiente) [set max_g_pendiente g_pendiente]
 ]
 
 ask patches[
   set g_pendiente g_pendiente / max_g_pendiente
   set g_distCarretera g_distCarretera / 255
   set g_atraccionUrbana g_atraccionUrbana / 255
 ]
end

to borrar_todo
  ask patches with [ tipo <= 3 ][
    set tipo 0
  ]
  
  crear-mapa-densidad-1
  crear-mapa-densidad-2
  crear-mapa-densidad-3
  crear-mapa-carreteras
  
  set num_patches_t1 count patches with [tipo = 1]
  set num_patches_t2 count patches with [tipo = 2]
  set num_patches_t3 count patches with [tipo = 3]
  
  colorear
  
  reset-ticks
end

; MÉTODOS DE CARGA DE IMÁGENES_________________________________

to crear-mapa-densidad-1
  import-pcolors-rgb "disc_disp.png"
  ask patches with [pcolor != [255 255 255]] [
   set tipo 1
  ]
end

to crear-mapa-densidad-2
  import-pcolors-rgb "disc_denso.png"
  ask patches with [pcolor != [255 255 255]] [
    set tipo 2
  ]
end

to crear-mapa-densidad-3
  import-pcolors-rgb "cont_denso.png"
  ask patches with [pcolor != [255 255 255]][
    set tipo 3
  ]
end

; Mapas de gradientes____________
to crear-mapa-pendiente
  import-pcolors-rgb "slope.png"
  ask patches[
    set g_pendiente 255 - first pcolor
  ]
end

to crear-mapa-distCarretera
  import-pcolors-rgb "dist_carretera.png"
  ask patches[
    set g_distCarretera 255 - first pcolor
  ]
end

to crear-mapa-atraccionUrbana
  import-pcolors-rgb "grad_centro.png"
  ask patches[
    set g_atraccionUrbana first pcolor
  ]
end

; Mapas de máscaras_____________
to crear-mapa-pendienteAlta
  import-pcolors-rgb "slope_mask.png"
  ask patches with [pcolor = [255 255 255]] [
    set tipo 7
  ]
end

to crear-mapa-agua
  import-pcolors-rgb "agua.png"
  ask patches with [pcolor != [255 255 255]] [
    set tipo 4
  ]
end

to crear-mapa-carreteras
  import-pcolors-rgb "carreteras.png"
  ask patches with [pcolor != [255 255 255]] [
    set tipo -1
  ]
end

to crear-mapa-industrial
  import-pcolors-rgb "industrial.png"
  ask patches with [pcolor != [255 255 255]] [
    set tipo 5
  ]
end

to crear-mapa-zonaEstudio
  import-pcolors-rgb "ambito.png"
  ask patches with [pcolor != [255 255 255]] [
    set tipo 8
  ]
end
;-------------------------Funciones-------------------------

;Función para ejecutar una simulación de 28 tics.
to simular 
 repeat 28[
 expansion  
 export-view (word "log" ".png")   
   tick
   ] 
end

to expansion
  let patchsCandidatos1 []
  let patchsCandidatos2 []
  let patchsCandidatos3 []
  
  ;Buscar candidatos
  ask patches [
    if (tipo = 3) [
      ask neighbors with [tipo < 3 and calcularGradienteTotal3 > 0][
        set patchsCandidatos3 fput self patchsCandidatos3
      ]
    ]
    
    if (tipo = 2) [
      ask neighbors with [tipo < 2 and calcularGradienteTotal2 > 0][
        set patchsCandidatos2 fput self patchsCandidatos2
      ]
    ]
    
    if (tipo = 1) [
      ask neighbors with [tipo < 1 and calcularGradienteTotal1 > 0][
        set patchsCandidatos1 fput self patchsCandidatos1
      ]
    ]
  ]
  
  ;Expandir mejores candidatos
  set patchsCandidatos1 sort-by [[g_total] of ?2 < [g_total] of ?1] patchsCandidatos1
  set patchsCandidatos2 sort-by [[g_total] of ?2 < [g_total] of ?1] patchsCandidatos2
  set patchsCandidatos3 sort-by [[g_total] of ?2 < [g_total] of ?1] patchsCandidatos3
  
  set patchsCandidatos1 sublist patchsCandidatos1 0 (num_patches_t1 * crecimiento_t1)
  set patchsCandidatos2 sublist patchsCandidatos2 0 (num_patches_t2 * crecimiento_t2)
  set patchsCandidatos3 sublist patchsCandidatos3 0 (num_patches_t3 * crecimiento_t3)
  
  foreach patchsCandidatos1 [
    ask ? [
      set pcolor 23
      set tipo 1
      set num_patches_t1 num_patches_t1 + 1
    ]
  ]
  
  foreach patchsCandidatos2 [
    ask ? [
      set pcolor 24
      set tipo 2
      set num_patches_t2 num_patches_t2 + 1
    ]
  ]
  
  foreach patchsCandidatos3 [
    ask ? [
      set pcolor 25
      set tipo 3
      set num_patches_t3 num_patches_t3 + 1
    ]
  ]
end

to-report calcularGradienteTotal1
  ifelse (tipo < 3 )[
    report (g_pendiente + ponderacion_distCarreteras_1 * g_distCarretera + ponderacion_atraccionUrbana_1 * g_atraccionUrbana ) / 5
  ][report 0 ]
end

to-report calcularGradienteTotal2
  ifelse (tipo < 3 )[
  report (g_pendiente + ponderacion_distCarreteras_2 * g_distCarretera + ponderacion_atraccionUrbana_2 * g_atraccionUrbana ) / 5
  ][report 0 ]
end


to-report calcularGradienteTotal3
  ifelse (tipo < 3 )[
  report (g_pendiente + ponderacion_distCarreteras_3 * g_distCarretera + ponderacion_atraccionUrbana_3 * g_atraccionUrbana ) / 5
  ][report 0 ]
end

to colorear
  ;TIPO DE TERRENO
  ;   - -1 = carretera
  ;   - 0 = Campo
  ;   - 1 = Discontinuo Disperso
  ;   - 2 = Discontinuo denso
  ;   - 3 = Continuo denso
  ;   - 4 = agua
  ;   - 5 = industria
  ;   - 7 = pendiente alta
  ;   - 8 = ambito
  ask patches[
    if (tipo = -1) [set pcolor [50 50 50]]
    if (tipo = 0) [set pcolor green]
    if (tipo = 1) [set pcolor 23] ; Disc disperso: naranja osc
    if (tipo = 2) [set pcolor 24] ; Disc denso:    naranja medio
    if (tipo = 3) [set pcolor 25] ; Cont denso:    naranja claro
    if (tipo = 4) [set pcolor blue]
    if (tipo = 5) [set pcolor yellow]
    if (tipo = 7) [set pcolor 52] ; verde oscuro
    if (tipo = 8) [set pcolor black] ; negro
  ]
end

to cargarMapas
 crear-mapa-densidad-1
 crear-mapa-densidad-2
 crear-mapa-densidad-3
 
 crear-mapa-pendiente
 crear-mapa-distCarretera
 crear-mapa-atraccionUrbana
 
 crear-mapa-pendienteAlta
 crear-mapa-agua
 crear-mapa-carreteras
 crear-mapa-industrial
 crear-mapa-zonaEstudio
end

;Comparación de los dos mapas, real y calculado.
to compara_mapa
set densidad_estimada (count patches with [tipo = 1]) + (count patches with [tipo = 2]) + (count patches with [tipo = 3])
set error_mapa (densidad_estimada - densidad_real) / 100 
end

;-------------------------Dibujar manualmente el escenario-------------------------

to Dibujar
 if mouse-inside?
 [
 ;Dibujar carretera.       
  if mouse-down?
  [         
    ask patch mouse-xcor mouse-ycor 
    [
     set pcolor 50 ;Poner valor de carretera.
    ]        
  ]                 
]      
end

to borrar
 if mouse-inside?
 [
   ;Borrar terreno.      
  if mouse-down?
  [ 
    ask patch mouse-xcor mouse-ycor 
    [
     set pcolor black
    ]      
  ]
 ]
end
@#$#@#$#@
GRAPHICS-WINDOW
532
2
1491
1034
-1
-1
1.0
1
10
1
1
1
0
1
1
1
0
948
0
1000
0
0
1
ticks
30.0

BUTTON
74
17
210
50
Inicializar
inicializar
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
5
649
145
682
Dibujar carreteras
Dibujar
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
74
55
209
88
Borrar todo
borrar_todo
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
302
66
520
99
ponderacion_distCarreteras_1
ponderacion_distCarreteras_1
0
2
1
1
1
NIL
HORIZONTAL

SLIDER
302
103
520
136
ponderacion_atraccionUrbana_1
ponderacion_atraccionUrbana_1
0
2
1
1
1
NIL
HORIZONTAL

PLOT
5
387
529
639
Superficie_urbanizada
Años
Superficie (ha)
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Superficie 1" 1.0 0 -408670 true "" "plot count patches with [tipo = 1]"
"Superficie 2" 1.0 0 -955883 true "" "plot count patches with [tipo = 2]"
"Superficie 3" 1.0 0 -10146808 true "" "plot count patches with [tipo = 3]"

MONITOR
4
341
82
386
Superficie 1
count patches with [tipo = 1]
2
1
11

MONITOR
81
341
159
386
Superficie 2
count patches with [tipo = 2]
2
1
11

MONITOR
158
341
236
386
Superficie 3
count patches with [tipo = 3]
2
1
11

BUTTON
152
649
292
682
Borrar terreno
borrar
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
348
40
593
74
Discontínuo disperso (1)
14
0.0
1

TEXTBOX
339
146
599
180
Discontínuo denso (2)\n
14
0.0
1

SLIDER
305
167
523
200
ponderacion_distCarreteras_2
ponderacion_distCarreteras_2
0
2
1
1
1
NIL
HORIZONTAL

SLIDER
305
209
524
242
ponderacion_atraccionUrbana_2
ponderacion_atraccionUrbana_2
0
2
1
1
1
NIL
HORIZONTAL

TEXTBOX
343
244
606
278
Contínuo denso (3)
14
0.0
1

SLIDER
306
271
524
304
ponderacion_distCarreteras_3
ponderacion_distCarreteras_3
0
2
1
1
1
NIL
HORIZONTAL

SLIDER
306
315
523
348
ponderacion_atraccionUrbana_3
ponderacion_atraccionUrbana_3
0
2
1
1
1
NIL
HORIZONTAL

BUTTON
72
171
212
204
Comparar con mapa real
compara_mapa
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
-1
221
128
266
Superficie total real
densidad_real
2
1
11

MONITOR
153
222
286
267
Superficie total estimada
densidad_estimada
2
1
11

TEXTBOX
92
141
242
159
Comparaciones
14
0.0
1

MONITOR
77
276
206
321
Error de estimación
error_mapa
2
1
11

TEXTBOX
274
10
549
40
Ponderaciónes tejido urbano
20
0.0
1

BUTTON
74
93
210
126
Simulación
simular
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
220
89
277
134
Años
ticks
0
1
11

@#$#@#$#@
## WHAT IS IT?

Lo que el modelo trata de mostrar es cómo influyen ciertas fuerzas o factores motrices (red de carreteras y centralidades urbanas) en los procesos de expansión urbana en un entorno metropolitano. Se trata pues de aplicar una serie de reglas relativamente simples para explicar un fenómeno que se produce en un sistema complejo, como son los sistemas metropolitanos, pero no por ello carente de ciertos patrones de comportamiento que se repiten de forma genérica en distintos sistemas.

## HOW IT WORKS

Conocido el crecimiento urbano residencial real en su componente espacio-temporal (componente intrínseco del sistema), con la finalidad de simplificar el modelo, entendemos el crecimiento urbano como un proceso de expansión por agregación, es decir, que para que una celda cambie al estado "urbano" debe tener al menos una celda adyacente en dicho estado, de forma análoga a los criterios de vecindad establecidos en los conocidos como autómatas celulares. 

Los estados posibles de una celda pueden ser cuatro: No urbano, discontinuo disperso, continuo disperso y continuo denso, los tres últimos de tipo urbano en orden creciente de compacidad y densidad.

Una segunda regla que debe cumplir el modelo es la dirección de los cambios de estado, de modo que una uso no urbano puede cambiar a cualquiera de los tres usos urbanos (colonización de nuevos usos no urbanos), o un uso urbano puede cambiar a otro siempre y cuando el estado del nuevo uso sea de mayor compacidad/densidad que el anterior (fenómeno de densificación). Es decir, una celda en el estado discontinuo disperso puede cambiar a continuo disperso o continuo denso, el continuo disperso puede cambiar a continuo denso, y el continuo denso no puede cambiar a ningún otro uso. Este fenómeno se producirá de nuevo por adyacencia, del mismo modo que ocurre para la regla de cambio de estado de urbano a no urbano. Los usos urbanos no se transformarán bajo ninguna circunstacia en no urbano.

La tercera regla para que se produzca la transformación de no urbano a urbano está relacionada con la aptitud del entorno para que se produzca el fenómeno en cuestión. Dicho criterio está relacionado por un lado con elementos que actúan como limitantes para este crecimiento, es decir, a modo de máscara (presencia de masas de agua, pendiente mayor de 10% o zonas industriales/infraestructuras), mientras que otros actúan como potenciadores del crecimiento urbano residencial (elementos de atracción como la red de carreteras o el efecto de centralidades y otros como el gradiente de pendientes menores de 10%). Gracias a éstos últimos elementos potenciadores, se establece un índice de transición potencial, o índice de potencialidad (IP) normalizado de 0 a 1, y donde además del efecto del gradiente de cada uno de los factores, interviene un elemento ponderador que puede ser introducido por el usuario, y que estará relacionado con el peso que se quiera asignar a cada factor motriz para explicar el crecimiento urbano. Además, este ponderador puede actuar con distinto grado dependiendo del tipo de uso residencial que interviene en el fenómeno.

De este modo:

PI para el uso i = grad_pendiente + (ponderacion_distCarreteras * grad_distCarretera) + (ponderacion_atraccionUrbana * grad_atraccionUrbana) / 5

Finalmente, aquellas celdas que cumplan las reglas de crecimiento y además tengan un PI mayor, serán las que se transformen con cada iteración (tick), y de este modo serán las que contribuyan en su conjunto al fenómeno de expansión urbana. Todo ello bajo un ritmo de crecimiento propio para cada tipo de uso y establecido según datos de crecimiento real. Hecho que contribuye a asignar al modelo de cierto realismo a la ver que nos permite dotar a los ticks de temporalidad (un tick = un año)
 

## HOW TO USE IT

El modelo comienza haciendo click en el botón "inicializar", que carga el entorno y con él todas las capas que intervienen en el modelo. Se trata de datos geográficos reales obtenidos de distintas fuentes cartográficas para el área metropolitana de Sevilla (capa de usos del suelo, pendientes obtenidas a partir de MDT, red de carreteras, etc.). 

Una vez cargado el entorno, comenzamos la ejecución con el botón simulación. 
El momento temporal en el que se inicia la simulación es 1956, y se pretende ejecutar el modelo hasta 1984, con la finalidad de poder comparar los resultados del con cartografía de usos del suelo disponible para dicho año final. De hecho, el modelo está preparado para que se ejecute y se pare en este periodo, lo que implica un total de 28 ticks. 


## THINGS TO NOTICE

Durante la ejecución del modelo se obtiene un gráfico con la evolución de la superficie urbana por tipos de usos residenciales, y al finalizar el mismo (28 ticks) se obtiene de forma automática una imagen png. con la foto final. Además, con el botón "comparar con mapa real" se obtiene el resultado de la superficie total estimada es comparada con la total según datos reales para comprobar que en términos de crecimiento neto el modelo ha sido diseñado correctamente (error de estimación).

## THINGS TO TRY

Antes de ejecutar el modelo, el usuario puede probar a cambiar los ponderadores para cada uno de los usos (con los sliders), y de este modo comprobar cómo influye en el resultado de la simulación el hecho de asignar mayor peso al elemento de atracción de la red de carreteras (patrón de crecimiento lineal) o por el contrario dotar de mayor peso al efecto de atracción de las distintas centralidades urbanas, todo esto de forma global o  incluso de forma particular para algún uso residencial concreto.

## EXTENDING THE MODEL

El modelo tiene ciertas limitaciones que impiden desarrollar una simulación del todo realista en relación al fenómeno estudiado, pero que podrían ser depuradas con la modificación de algunas de las reglas.

1. Modificación de la regla de vecindad. Del mismo modo que se ha realizado en numerosos estudios previos relacionados con el fenómeno de crecimiento urbano donde se aplica el concepto de autómata celular, sería interesante aplicar una vecindad más allá de la adyacencia más próxima (en nuestro modelo vecindad de Moore de 8 celdas). Esta regla está especialmente justificada en sistemas complejos como el metropolitano, donde la influencia de celdas vecinas actúa como un gradiente dentro de radios de varios cientos de metros.

2. Adicción de nuevas formas de crecimiento como la colonización de nuevas ocupaciones lejanas a las manchas urbanas ya asentadas, pero que de algún modo, por un lado aleatorio y por otro movido por la adecuidad del entorno, se producen cada cierto tiempo.

3. Adicción de nuevos elementos territoriales que influyan en el índice de potencialidad, como por ejemplo la capacidad de cambio de ciertos usos del suelo hacia usos residenciales. Se trata en cualquier caso de elementos ya estudiados en la dinámica de cambios de usos del suelo en entornos metropolitanos.

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.1.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
