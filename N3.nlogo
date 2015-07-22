globals
[
poblaciones-iniciales
poblacion-inicial-min
poblacion-inicial-max
limite-demografico
emigrantes

secesiones-exito
secesiones-fracaso

secesiones-exito-tick
secesiones-fracaso-tick

;Visualizacion solo
limite-poblacional-representacion
limite-tamano-poblado

coeficiente

num-cooperaciones
num-ataques

cooperaciones-tick
ataques-tick
]

turtles-own
[
poblacion
arado
poliorcetica
metalurgia
diversidad
limite-poblacon-acumulada
;lider
;stock recursos  
]

to setup
  ;Reset
  clear-all
  reset-ticks
  
  ;Añadimos semilla para pseudo-random
  random-seed 9998
  
  ;random-seed 9978
  
  ;Inicialización variables globales
  set poblaciones-iniciales 3
  set poblacion-inicial-min 20
  set poblacion-inicial-max 30
  set limite-demografico 50
  set emigrantes 10
  ;unidad-poblacional
  
  set secesiones-exito 0
  set secesiones-fracaso 0
  
  set num-cooperaciones 0
  set num-ataques 0
  
  set limite-poblacional-representacion 500 ;; OJO!! ESTE LÍMITE TAMBIÉN SE USA PARA LA INTERACCIÓN.
  set limite-tamano-poblado 2
  
  set coeficiente (1 / 6)
  ;Crear poblaciones
  create-turtles poblaciones-iniciales
  [
    setxy random-xcor random-ycor
    set poblacion (poblacion-inicial-min + random (poblacion-inicial-max - poblacion-inicial-min))
    set arado 0
    set poliorcetica 0
    set metalurgia 0
    ;set shape "house"
    set color white
    set size 1
    set diversidad generar-diversidad
    set-shape
    set limite-poblacon-acumulada 0
  ]

end

to set-shape
  ifelse diversidad = 0
  [set shape "cow"]
  [
   ifelse diversidad = 1
   [set shape "plant"]
   [
     ifelse diversidad = 2
     [set shape "house"]
     [
         ifelse diversidad = 3
         [set shape "wheel"]
         [set shape "flag"]
     ]  
   ]
  ]
end

to set-color
  if arado = 1
  [set color green]
  if poliorcetica = 1
  [set color red]
  if metalurgia = 1
  [set color brown]
end

to update-color-shape
  set-shape
  set-color
end

to-report generar-diversidad
  let ret 2
  let valor random 100
  if valor >= 70
  [
    ifelse valor < 85
    [set ret 1]
    [set ret 0]
  ]
  report ret
end

to go
  set secesiones-exito-tick 0
  set secesiones-fracaso-tick 0
  
  set cooperaciones-tick 0
  set ataques-tick 0
  
  ask turtles
  [
  aprender
  poblacion-crecer
  poblacion-migrar
  if diversidad < 4
  [poblacion-innovar]
  if poliorcetica = 1 and poblacion < limite-poblacional-representacion
  [
    ;print (word "poblado " who " va a interactuar")
    interactuar]
  ;aparece-lider
  update-color-shape
  ]
  
  tick
end

to-report puedo-aprender
  ifelse (random prob-aprender) = 0
  [report true]
  [report false]
end

to aprender
  ;arado
  if (diversidad > 1) and (arado = 0) and (puedo-aprender)
  [
    set arado 1
    set color green  
    ;print (word "poblado: " who " ha descubierto ARADO!!")  
  ]
  ;poliercetica
  if diversidad > 1 and arado = 1 and poliorcetica = 0 and puedo-aprender
  [
    set poliorcetica 1
    set color red 
    ;print (word "poblado: " who " ha descubierto POLIoRCETICA!!")  
  ]
  if diversidad > 2 and arado = 1 and poliorcetica = 1 and metalurgia = 0 and puedo-aprender
  [
    set metalurgia 1
    set color brown 
    ;print (word "poblado: " who " ha descubierto METALURGIA!!")  
  ]
end

to poblacion-crecer
  let multiplicador-lim 1
  let multiplicador-tasa 1
  if arado = 1
  [set multiplicador-lim multiplicador-arado
    set multiplicador-tasa multiplicador-arado]
  if diversidad = 4
  [set multiplicador-lim (multiplicador-lim * 5)]
  
  if poblacion < ((limite-demografico * multiplicador-lim) + limite-poblacon-acumulada)
  [
    let crecimiento (round (poblacion * (tasa-crecimiento / 100) * multiplicador-tasa))
    if crecimiento = 0
    [set crecimiento random 2]
    set poblacion (poblacion + crecimiento)
    set size 1 + ((poblacion / limite-poblacional-representacion) * limite-tamano-poblado)
    ;OJO parche
    if size > 5
    [set size 5]
  ]
  ;¿qué hacemos en el límite?

end


to poblacion-migrar
  let multiplicador-lim 1
  
  if arado = 1
  [set multiplicador-lim multiplicador-arado]
  if diversidad = 4
  [set multiplicador-lim (multiplicador-lim * 5)]
  
  if poblacion >= ((limite-demografico * multiplicador-lim) + limite-poblacon-acumulada)
  [
    set poblacion (poblacion - emigrantes)
    let candidatos patches in-radius separacion-max
    
    let buenos candidatos with [buen-candidato self]
    
    let nuevo-lugar one-of buenos
    ifelse nuevo-lugar = nobody
    [ 
      set secesiones-fracaso (secesiones-fracaso + 1)
      set secesiones-fracaso-tick (secesiones-fracaso-tick + 1)
      
      
      
      
      
    ]
    [
      hatch 1
      [
        set poblacion emigrantes
        ;set arado [arado] of myself ;NO ES SEGURO QUE ESTE BI
        set xcor [pxcor] of nuevo-lugar
        set ycor [pycor] of nuevo-lugar
        
        ;if (arado = 1)
        ;[print (word "poblado: " who " aprende ARADO del poblado " [who] of myself)]
      ]  
      set secesiones-exito (secesiones-exito + 1)
      set secesiones-exito-tick (secesiones-exito-tick + 1)
    ]
  ]
  
end
 
to-report buen-candidato [casilla]
  let res false
  ask casilla[
  let vecindad patches in-radius separacion-min
  set res (all? vecindad [[count turtles-here] of self = 0])
  ]
 report res
 end 

to poblacion-innovar
  
  let innovamos? 0
  
  repeat poblacion
  [
    if (random prob-diversidad = 0)
    [set innovamos? 1]
  ]
  
  if (innovamos? = 1)
  [
    ifelse (diversidad = 0)
    [set diversidad 2]
    [set diversidad (diversidad + 1)]
    set-shape
  ]
end

to interactuar
  let rival get-oponente
  
  ifelse rival != nobody
  [
  ;print (word "interaccion con " [who] of rival)
  
  let tranquilidad-a tranquilidad-poblado
  ;let tranquilidad-b [tranquilidad-poblado] of rival ; Lo hemos hecho 'unilateral', la idea original era 'recíproco'
  let propension propension-interaccion rival
  ifelse (((1 - (umbral-interaccion / 100)) * propension) > tranquilidad-a)
  [ set num-ataques num-ataques + 1
    set ataques-tick ataques-tick + 1
    atacar rival]
  [ set num-cooperaciones num-cooperaciones + 1
    set cooperaciones-tick cooperaciones-tick + 1
    cooperar rival] ;OJO rival no está decidiendo si quiere cooperar o no.
  ]
  [print "NOBODY!!!!!!!"]
end

to atacar [rival]
  let poblacion-rival [poblacion] of rival
  ask rival [die]
  ;set poblacion (poblacion - poblacion-rival)
  set limite-poblacon-acumulada (limite-poblacon-acumulada + poblacion-rival)  
end

to cooperar [rival]
  ifelse diversidad > [diversidad] of rival
  [ ask rival [set diversidad [diversidad] of self]  ]
  [ set diversidad [diversidad] of rival]
  
  ifelse arado = 1
  [ ask rival [set arado [arado] of self] ]
  [ set arado [arado] of rival]
  
  ifelse poliorcetica = 1
  [ ask rival [set poliorcetica [poliorcetica] of self] ]
  [ set poliorcetica [poliorcetica] of rival]
  
  ifelse metalurgia = 1
  [ ask rival [set metalurgia [metalurgia] of self] ]
  [ set metalurgia [metalurgia] of rival]
end

to-report get-oponente
  
  let candidatos other turtles with [distance myself < radio-interaccion-max]
  
  report  min-one-of candidatos [distance myself]
  
;  let radio 0
;  loop
;  [
;    set radio (radio + 1)
;    let candidatos other patches in-radius radio
;    let poblados nobody
;    ask candidatos
;    [
;        if turtles-here != nobody
;        [set poblados turtles-here]
;    ]
;    if poblados != nobody
;    [report one-of poblados]
;    
;    set radio (radio + 1)
;  ]
end

to-report tranquilidad-poblado
  report (((coeficiente * grado-tecnologico) + (coeficiente * grado-sociedad) - (coeficiente * poliorcetica)) * poblacion)
end

to-report propension-interaccion [rival] ; OJO lo de (1 + (coeficiente * grado-tecnologico)) es muy artificial.
  report abs ((poblacion * (1 + (coeficiente * grado-tecnologico))) - ([poblacion] of rival * (1 + (coeficiente * [grado-tecnologico] of rival))))
end

to-report grado-tecnologico
  report (arado + poliorcetica + metalurgia)
end

to-report grado-sociedad
  ifelse diversidad < 2
  [report 0]
  [report (diversidad - 1)]
end

;to aparece-lider
;  if arado = 1
;  [
;    if diversidad = 3
;    [
;      if (random prob-lider) = 0
;      [
;        set lider 1
;        set color blue
;        print (word "poblado: " who " tiene lider!!")
;      ]
;    ]
;  ]
;end
@#$#@#$#@
GRAPHICS-WINDOW
444
10
1069
656
-1
-1
12.06
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
50
0
50
1
1
1
ticks
30.0

BUTTON
17
19
83
52
NIL
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
15
67
78
100
NIL
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

BUTTON
17
118
102
151
go-once
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

SLIDER
17
168
140
201
tasa-crecimiento
tasa-crecimiento
0
100
1
1
1
NIL
HORIZONTAL

SLIDER
14
211
151
244
multiplicador-arado
multiplicador-arado
1
5
2
1
1
NIL
HORIZONTAL

PLOT
8
450
213
584
poblaciones
ticks
poblados
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"poblados" 1.0 0 -2674135 true "" "plot count turtles"

MONITOR
15
261
134
306
NIL
secesiones-exito
17
1
11

MONITOR
15
321
149
366
NIL
secesiones-fracaso
17
1
11

PLOT
233
443
433
593
secesiones/tick
tick
secesiones
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"exito" 1.0 1 -13840069 true "" "plot secesiones-exito-tick"
"fracaso" 1.0 1 -2674135 true "" "plot secesiones-fracaso-tick"

SLIDER
167
169
282
202
separacion-min
separacion-min
1
separacion-max
3
1
1
NIL
HORIZONTAL

SLIDER
167
211
295
244
separacion-max
separacion-max
separacion-min
(max-pxcor / 2)
8
1
1
NIL
HORIZONTAL

MONITOR
166
318
223
363
arado
(count turtles with [arado = 1]) / (count turtles)
17
1
11

SLIDER
167
129
304
162
prob-aprender
prob-aprender
0
100000
1000
1
1
NIL
HORIZONTAL

SLIDER
165
92
312
125
prob-diversidad
prob-diversidad
0
100000
100000
1
1
NIL
HORIZONTAL

SLIDER
183
47
356
80
umbral-interaccion
umbral-interaccion
0
100
10
1
1
NIL
HORIZONTAL

SLIDER
179
10
374
43
radio-interaccion-max
radio-interaccion-max
0
100
13
1
1
NIL
HORIZONTAL

PLOT
1121
158
1357
325
cooperaciones-ataques
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
"cooperacion" 1.0 0 -13791810 true "" "plot num-cooperaciones"
"ataque" 1.0 0 -2674135 true "" "plot num-ataques"

TEXTBOX
943
191
1093
247
- Añadir límite poblacional 500\n- actualizar graficos cuando cooperacion
11
0.0
1

PLOT
236
284
454
436
cooperacion-ataque/tick
NIL
NIL
0.0
5.0
0.0
5.0
true
false
"" ""
PENS
"cooperaciones" 1.0 1 -13791810 true "" "plot cooperaciones-tick"
"ataques" 1.0 1 -5298144 true "" "plot ataques-tick"

PLOT
1125
415
1334
599
diversidad-desarrollo
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
"num-lideres" 1.0 0 -14454117 true "" "plot count turtles with [diversidad = 4]"

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
