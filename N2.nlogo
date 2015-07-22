globals[ 
  trimestre
  año
  impacto-global
  limite-usuarios-maximo
  limite-usuarios-minimo
    
  color-edificable
  
  n-unifamiliares
  n-adosadas
  n-bloques
  color-unifamiliar
  color-adosada
  color-bloque
  capacidad-unifamiliar
  capacidad-adosada
  capacidad-bloque
  ocupacion-minimo
  ocupacion-maximo
  
  n-hoteles
  n-hostales
  n-apartamentos
  color-hotel
  color-hostal
  color-apartamento
  capacidad-hotel
  capacidad-hostal
  capacidad-apartamento
  
  color-actividad
  color-espacio
  color-dotacion
  
  ]

patches-own[
  numero-usuarios
  edificable
  impacto-abastecimiento
  impacto-saneamiento
  impacto-energia
  impacto-social
  impacto-economico
  impacto-movilidad
  litros-disponibles
  litros-consumidos
  energia-disponible
  energia-consumida
  saneamiento-disponible
  saneamiento-consumida
  placa-solar
]

to setup
  ca 
  set año 1
  set trimestre 0
  set impacto-global 0
  set limite-usuarios-maximo (list 15000 20000 30000)
  set limite-usuarios-minimo (list 10000 15000 20000)
  ;Modelo 0 = estacional -- Modelo 1 = desestacional
  
  configurar-inicio
  
  ;incremento se elige en la interfaz
  ask patches[
    set pcolor white
  ]
  import-pcolors-rgb "forma14 imagen raster copyrecortada.png" 
  
  let total-no-blanco count patches with [pcolor != white]
  generar-actividad (total-no-blanco * actividad-economica% / 100) color-actividad  
  generar-espacio (total-no-blanco * espacio-libre% / 100) color-espacio
  generar-actividad (total-no-blanco * dotacion% / 100) color-dotacion
  
  generar-edificios n-unifamiliares color-unifamiliar 
  generar-edificios n-adosadas color-adosada
  generar-edificios n-bloques color-bloque 
  generar-edificios n-hoteles color-hotel 
  generar-edificios n-hostales color-hostal 
  generar-edificios n-apartamentos color-apartamento 
   
  reset-ticks
end

to go
  ;viviendas-turistico-actEco-dotacion
  ;let suma-total-impactos (impacto-ambiental + ...)
  ;let declara, set modifica
  
  repoblar-todo
  calcula-impacto-abastecimiento
  calcula-impacto-movilidad
  calcula-impacto-economico
  calcula-impacto-saneamiento
  calcula-impacto-energia
  
  set impacto-global (impacto-global + sum [impacto-abastecimiento + impacto-movilidad + impacto-economico + impacto-saneamiento + impacto-energia] of patches)
  
  tick
  let sumatorio (sum [numero-usuarios] of patches)
  if trimestre = 3 and  sumatorio < (item (incremento - 1) limite-usuarios-maximo) and sumatorio > (item (incremento - 1) limite-usuarios-minimo) [
    if impacto-global > 25000 [
      
      set ocupacion-minimo (map [map [ ? * 0.9] ?] ocupacion-minimo)
      set ocupacion-maximo (map [map [ ? * 0.9] ?] ocupacion-maximo) 
       
    ] 
    if impacto-global < -25000 [
      set ocupacion-minimo (map [map [ ? * 1.1] ?] ocupacion-minimo)
      set ocupacion-maximo (map [map [ ? * 1.1] ?] ocupacion-maximo)
    ]
  ]
  set trimestre (ticks mod 4)
  if trimestre = 0 [set año (año + 1)]
  
  if año > 20 [stop]  
end

to generar-edificios [lista coloreable]
  ask n-of (item (incremento - 1) lista) patches with [pcolor = color-edificable] [
    set pcolor coloreable
    if random 100 < placas-solares% [
      set placa-solar 1 
    ]
  ]
  
end

to generar-actividad [total coloreable]
  ask n-of (total) patches with [pcolor = color-edificable] [
    set pcolor coloreable
  ]
end

to generar-espacio [total coloreable]
  let verdes count patches with [ pcolor = color-espacio]
  
  if total > verdes [ 
    let a-pintar (total - verdes)
    ask n-of a-pintar patches with [pcolor = color-edificable] [
      set pcolor coloreable
    ]
  ]
end

to repoblar [minimo maximo ocupacion tipo]
  ask patches with [pcolor = tipo] [
    set numero-usuarios round (((minimo + random (maximo - minimo)) / 100 ) * ocupacion)
    ; abastecimiento
    set litros-disponibles ocupacion * litros-disponible * 90
    set litros-consumidos numero-usuarios * (200 + (random 40) - 20) * 90
    ; energia
    set energia-disponible ocupacion * energia-disponible-edificacion * 90
    set energia-consumida numero-usuarios * (100 + (random 30) - 15) * 90
    ; saneamiento
    set saneamiento-disponible ocupacion * saneamiento-disponible-edificacion * 90
    set saneamiento-consumida numero-usuarios * (2 + (random 2) - 1) * 90
    
  ]
end

to configurar-inicio
  set color-edificable [242 227 134]
  
  set n-unifamiliares (list 743 990 1500)
  set n-adosadas (list 383 510 750)
  set n-bloques (list 150 200 300)
  set color-unifamiliar [255 0 0]
  set color-adosada [225 0 0]
  set color-bloque [195 0 0]
  set capacidad-unifamiliar 4
  set capacidad-adosada 4
  set capacidad-bloque 30
  set ocupacion-minimo (list (list 0 20 100 0) (list 20 60 60 20))
  set ocupacion-maximo (list (list 20 60 150 20) (list 60 100 100 60))
  
  set n-hoteles (list 3 4 7)
  set n-hostales (list 25 33 50)
  set n-apartamentos (list 948 1252 1850)
  set color-hotel [0 255 0]
  set color-hostal [0 225 0]
  set color-apartamento [0 195 0]
  set capacidad-hotel 300
  set capacidad-hostal 50
  set capacidad-apartamento 4
  
  set color-actividad [0 0 255]
  set color-espacio [106 141 13]
  set color-dotacion [0 0 145]
end
  
to repoblar-todo
  let i1 Modelo
  repoblar (item trimestre (item i1 ocupacion-minimo)) (item trimestre (item i1 ocupacion-maximo)) capacidad-unifamiliar color-unifamiliar
  repoblar (item trimestre (item i1 ocupacion-minimo)) (item trimestre (item i1 ocupacion-maximo)) capacidad-adosada color-adosada
  repoblar (item trimestre (item i1 ocupacion-minimo)) (item trimestre (item i1 ocupacion-maximo)) capacidad-bloque color-bloque
  repoblar (item trimestre (item i1 ocupacion-minimo)) (item trimestre (item i1 ocupacion-maximo)) capacidad-hotel color-hotel
  repoblar (item trimestre (item i1 ocupacion-minimo)) (item trimestre (item i1 ocupacion-maximo)) capacidad-hostal color-hostal
  repoblar (item trimestre (item i1 ocupacion-minimo)) (item trimestre (item i1 ocupacion-maximo)) capacidad-apartamento color-apartamento  
end

to calcula-impacto-abastecimiento
  ;let total 0
  
  ask patches with [pcolor != white and pcolor != color-espacio ] [
    
  let consumo litros-consumidos
  let disponible litros-disponibles
    ifelse consumo >= disponible [
      ifelse consumo = disponible [
        set impacto-abastecimiento (impacto-abastecimiento + 2)
        set impacto-economico (impacto-economico + 1)
      ][ ;else
        ifelse consumo >= (disponible * 2) [
          set impacto-abastecimiento (impacto-abastecimiento + 8)
          set impacto-economico (impacto-economico + 3)
        ][;else
          set impacto-abastecimiento (impacto-abastecimiento + 6)          
        ]
      ]
    ][ ;else
      ifelse consumo <= (disponible / 2) [ ; ifelse _____ [ si ] [ no ]
         set impacto-abastecimiento (impacto-abastecimiento + 1)
      ][
        set impacto-abastecimiento (impacto-abastecimiento + 3)
        set impacto-economico (impacto-economico - 1)
      ]
    ] 
  ]
  ;set total (sum [impacto-abastecimiento] of patches)
  ;report total
end

to calcula-impacto-movilidad
  ;let total 0
  
  ask patches with [pcolor = color-unifamiliar or pcolor = color-adosada or pcolor = color-bloque or pcolor = color-hotel or pcolor = color-hostal or pcolor = color-apartamento][
       ifelse any? neighbors with [ pcolor = color-actividad or pcolor = color-espacio or pcolor = color-dotacion] [
         let n (one-of neighbors with [ pcolor = color-actividad or pcolor = color-espacio or pcolor = color-dotacion])
         let c [pcolor] of n
         ifelse any? other neighbors with [pcolor != c and (pcolor = color-espacio or pcolor = color-actividad or pcolor = color-dotacion)] [
            
            set impacto-movilidad (impacto-movilidad + ( -5 * numero-usuarios))
            ;ejemplo otro impacto -> set impacto- ... (impacto- ... + ( numero * numero-usuarios))
            
         ][
           set impacto-movilidad (impacto-movilidad + ( -1 * numero-usuarios))  
         ]
       ][
         ifelse pcolor = color-unifamiliar or pcolor = color-adosada or pcolor = color-bloque [
           if pcolor = color-unifamiliar [
             set impacto-movilidad (impacto-movilidad + ( 30 * numero-usuarios))
           ]          
           if pcolor = color-adosada [
             set impacto-movilidad (impacto-movilidad + ( 40 * numero-usuarios))
           ]
           if pcolor = color-bloque [
             set impacto-movilidad (impacto-movilidad + ( 50 * numero-usuarios))
           ]
         ][
           if pcolor = color-hotel [
             set impacto-movilidad (impacto-movilidad + ( 30 * numero-usuarios))
           ]
           if pcolor = color-hostal [
             set impacto-movilidad (impacto-movilidad + ( 20 * numero-usuarios))
           ]
           if pcolor = color-apartamento [
             set impacto-movilidad (impacto-movilidad + ( 10 * numero-usuarios))
           ]
         ]
       ]
  ]
  
  ;set total (sum [impacto-movilidad] of patches)
  ;report total
end

to calcula-impacto-economico
  
  ask patches [
    ifelse pcolor = color-hotel or pcolor = color-hostal or pcolor = color-apartamento [
       ifelse any? neighbors with [ pcolor = color-actividad ] [
           if pcolor = color-hotel [
             set impacto-economico (impacto-economico - ( 40 * numero-usuarios))
           ]
           if pcolor = color-hostal [
             set impacto-economico (impacto-economico - ( 20 * numero-usuarios))
           ]
           if pcolor = color-apartamento [
             set impacto-economico (impacto-economico - ( 15 * numero-usuarios))
           ]
       ][
          if pcolor = color-hotel [
             set impacto-economico (impacto-economico + ( 20 * numero-usuarios))
           ]
           if pcolor = color-hostal [
             set impacto-economico (impacto-economico + ( 30 * numero-usuarios))
           ]
           if pcolor = color-apartamento [
             set impacto-economico (impacto-economico + ( 35 * numero-usuarios))
           ]
       ]
    ][
      if pcolor = color-unifamiliar or pcolor = color-adosada or pcolor = color-bloque [
        ifelse any? neighbors with [ pcolor = color-actividad ] [
           if pcolor = color-unifamiliar [
             set impacto-economico (impacto-economico - ( 10 * numero-usuarios))
           ]
           if pcolor = color-adosada [
             set impacto-economico (impacto-economico - ( 15 * numero-usuarios))
           ]
           if pcolor = color-bloque [
             set impacto-economico (impacto-economico - ( 25 * numero-usuarios))
           ]
        ][
           if pcolor = color-unifamiliar [
             set impacto-economico (impacto-economico + ( 15 * numero-usuarios))
             set impacto-movilidad (impacto-movilidad + ( 10 * numero-usuarios))
           ]
           if pcolor = color-adosada [
             set impacto-economico (impacto-economico + ( 20 * numero-usuarios))
             set impacto-movilidad (impacto-movilidad + ( 10 * numero-usuarios))
           ]
           if pcolor = color-bloque [
             set impacto-economico (impacto-economico + ( 30 * numero-usuarios))
             set impacto-movilidad (impacto-movilidad + ( 30 * numero-usuarios))
           ]
        ]
      ]
    ]
  ]
  
end

to calcula-impacto-energia
  ask patches with [pcolor != white and pcolor != color-espacio ] [
  
  ifelse placa-solar = 1 [
     set impacto-energia (impacto-energia - 15 * numero-usuarios)
  ][ 
  let consumo energia-consumida
  let disponible energia-disponible
    ifelse consumo >= disponible [
      ifelse consumo = disponible [
        set impacto-energia (impacto-energia + 5)
        set impacto-economico (impacto-economico + 3)
      ][ ;else
        ifelse consumo >= (disponible * 2) [
          set impacto-energia (impacto-energia + 15)
          set impacto-economico (impacto-economico + 6)
        ][;else
          set impacto-energia (impacto-energia + 8)          
        ]
      ]
    ][ ;else
      ifelse consumo <= (disponible / 2) [ ; ifelse _____ [ si ] [ no ]
         set impacto-energia (impacto-energia + 3)
      ][
        set impacto-energia (impacto-energia + 2)
        set impacto-economico (impacto-economico - 2)
      ]
    ] 
  ]
  ]
end

to calcula-impacto-saneamiento
  
  ask patches with [pcolor != white and pcolor != color-espacio ] [
    
  let consumo saneamiento-consumida
  let disponible saneamiento-disponible
    ifelse consumo >= disponible [
      ifelse consumo = disponible [
        set impacto-saneamiento (impacto-saneamiento + 10)
        set impacto-economico (impacto-economico + 15)
      ][ ;else
        ifelse consumo >= (disponible * 2) [
          set impacto-saneamiento (impacto-saneamiento + 20)
          set impacto-economico (impacto-economico + 10)
        ][;else
          set impacto-saneamiento (impacto-saneamiento + 18)          
        ]
      ]
    ][ ;else
      ifelse consumo <= (disponible / 2) [ ; ifelse _____ [ si ] [ no ]
         set impacto-saneamiento (impacto-saneamiento + 1)
      ][
        set impacto-saneamiento (impacto-saneamiento + 5)
        set impacto-economico (impacto-economico - 3)
      ]
    ] 
  ]
  
end
@#$#@#$#@
GRAPHICS-WINDOW
345
10
1331
537
-1
-1
4.0
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
243
0
123
0
0
1
ticks
30.0

BUTTON
19
16
83
49
Setup
setup
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
98
16
161
49
Go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

CHOOSER
19
69
192
114
incremento
incremento
1 2 3
2

MONITOR
205
177
329
222
Parcelas vacias
count patches with [pcolor = [242 227 134]]
17
1
11

SLIDER
19
171
193
204
actividad-economica%
actividad-economica%
0
100
10
1
1
NIL
HORIZONTAL

SLIDER
19
210
191
243
espacio-libre%
espacio-libre%
0
100
10
1
1
NIL
HORIZONTAL

SLIDER
20
251
192
284
dotacion%
dotacion%
0
100
10
1
1
NIL
HORIZONTAL

CHOOSER
20
118
192
163
Modelo
Modelo
0 1
0

MONITOR
202
69
267
114
Trimestre
trimestre + 1
17
1
11

BUTTON
184
16
247
49
Paso
go
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
275
69
332
114
Año
año
17
1
11

MONITOR
206
123
327
168
numero de usuarios
sum [numero-usuarios] of patches
17
1
11

PLOT
19
438
271
588
Impactos
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"econ" 1.0 0 -16777216 true "" "plot sum [impacto-economico] of patches"
"abast" 1.0 0 -987046 true "" "plot sum [impacto-abastecimiento] of patches"
"movil" 1.0 0 -2674135 true "" "plot sum [impacto-movilidad] of patches"
"saneam" 1.0 0 -13840069 true "" "plot sum [impacto-saneamiento] of patches"
"energia" 1.0 0 -8990512 true "" "plot sum [impacto-energia] of patches"

SLIDER
20
288
258
321
litros-disponible
litros-disponible
50
200
75
5
1
NIL
HORIZONTAL

SLIDER
20
328
259
361
placas-solares%
placas-solares%
0
100
25
1
1
NIL
HORIZONTAL

PLOT
277
437
477
587
Impacto Global
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot sum [impacto-movilidad + impacto-economico + impacto-abastecimiento] of patches"

PLOT
484
438
684
588
Numero de usuarios
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot sum [numero-usuarios] of patches"

SLIDER
20
364
259
397
energia-disponible-edificacion
energia-disponible-edificacion
25
125
70
5
1
NIL
HORIZONTAL

SLIDER
18
401
259
434
saneamiento-disponible-edificacion
saneamiento-disponible-edificacion
5
20
11
1
1
NIL
HORIZONTAL

MONITOR
205
229
328
274
Impacto global
impacto-global
17
1
11

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

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
