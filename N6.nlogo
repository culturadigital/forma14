globals[
  npartidos ;;Lista de los nombres de los npartidos
  ipartidos
  ]

breed [ medios medio] ;; Esto es la declaracion de raza medio
breed [ votantes votante] ;; Esto es la declaracion de la raza personas



votantes-own[
  partido
  posicionpolitica ;;Afinidad con cada partido
 lopartidos
 intencion
 votoevento ;cambio
  ]



to setup
  
  clear-all
  
  reset-ticks
  
  set npartidos ["IU" "PP" "PSOE" "EA" "PNV" "CIU" "ERC" "BNG" "NABAI" "CC" "CHA" ]
  set ipartidos (list (iIU) (iPP) (iPSOE) (iEA) (iPNV) (iCIU) (iERC) (iBNG) (iNABAI) (iCC) (iCHA))
  if iIU + iPP + iPSOE + iEA + iPNV + iCIU + iERC + iBNG + iNABAI + iCC + iCHA > 100 [beep user-message "Un poco más tonto y naces de corcho"] 

 
 ;; ask patches  [recolorea]
 
 create-medios 1 [set shape "sirculo" set size efecto-medio * 2 set color red]
 
  create-votantes electores [
  set shape "person"
  set xcor random-xcor
  set ycor random-ycor
  set posicionpolitica -1]
  ;set partido (one-of npartidos)
  
  ;Para introducir los datos iniciales
    ifelse datos [
      let ii 0
      show count votantes with [ posicionpolitica = -1]
      while [ii < 10.1] [
        ask n-of ( ((electores * (item ii ipartidos) )/ (iIU + iPP + iPSOE + iEA + iPNV + iCIU + iERC + iBNG + iNABAI + iCC + iCHA))) (votantes with [posicionpolitica = -1]) [
         set posicionpolitica ii   
        ]
        set ii (ii + 1)
      ] 
      ask votantes with [posicionpolitica = -1] [ set posicionpolitica random 10.1] 
    ][
      ask votantes [set posicionpolitica (random 10.1)]
    ]
  
  ask votantes [
    set votoevento posicionpolitica
    ;;Lo que piensan los votantes de cada partido
    set lopartidos (list (random 5.1) (5 + random 5.1) (random 6.1) (5 + random 5.1) (5 + random 5.1) (random 5.1) (random 5.1) (random 5.1) (random 5.1) (5 + random 5.1) (random 5.1))
    ;set intencion (min map [distancia posicionpolitica ?] lopartidos)
    set intencion indicemenordistancia self
    set label partido set label-color white
  ]  
  
 
  
  
  
  ask votantes [revoto]
  evento
  ;create-votantes numvotantes [setxy random-xcor random-ycor
   ;set shape "person"
   ;set partido (one-of npartidos)
  
end  

to go
;  if ticks = 72 [ stop ]
  
  ask votantes [
    fd 0.5      ;anda hacia adelante 0.5
    rt -20 + random 40 ;gira -15 a la izquierda y entre 30 a la derecha
    afectaMedio ;Varía como va a afectar el evento
    revoto ;
    ]
  
  tick
end
  
to revoto
  set partido (item votoevento npartidos)
  
  set label partido
end
to-report indicemenordistancia [ag1]
  let i 0; indice del while
  let m 100 ;la menos distancia almacenada
  let k [] ; el indice de la menor distancia almacenada
  let dt 0 ; distancia absoluta actual
  while [i < 11][
   set dt (abs (item i lopartidos - posicionpolitica))
    if dt < m [
      set k (list i)
      set k (lput i k)
      set m dt
    ]
    if dt = m [ set k (lput i k) ]
    
    set i (i + 1)
  ]
  report one-of k
end

to evento
  let influye 0
  let probcamb 0; probabilidad de cambio
  let cambio 2; cambia si=1 o no=0
  let nvoto 0; generar random el nuevo voto
  ask votantes [
    set cambio 2
  set influye random 3.1
  if influye > 0 
  [
    if influye = 3 [  ;Influye Mucho
       set probcamb random 3.1
       if probcamb = 3 [ set cambio 0 ]
    ]
    
    if influye = 2 [  ;Influye Bastante
       set probcamb random 1.1
       if probcamb = 1 [ set cambio 0 ]
    ]
    
    if influye = 1 [  ;Influye Poco
       set probcamb random 3.1
       ifelse probcamb = 3 [][ set cambio 0 ]
    ]
  ifelse cambio = 0 [][
    set nvoto random 11
    set votoevento nvoto
  ]
  ]
  ]
end

to afectaMedio
  let afecta random 1.1
  ;let hipotenusa (sqrt (max-pxcor * max-pxcor + max-pycor * max-pycor))
  ;let nvoto ((distance one-of medios /  hipotenusa))
  ;set nvoto 1 / nvoto
  
  if (afecta = 1 and distance one-of medios < efecto-medio ) [
   let tt (2 + (1 / (1 + distance one-of medios)))
       ;ifelse ( nvoto > 10.1) [set votoevento 10] [set votoevento nvoto]
        set votoevento (votoevento - (tt) + random (2 * tt))     
        if (votoevento >= 11) [set votoevento (votoevento - 11)]
        if (votoevento < 0)  [set votoevento (11 + votoevento)]
   ]
  set votoevento (floor votoevento)
  
  
end
@#$#@#$#@
GRAPHICS-WINDOW
172
10
668
501
18
17
13.143
1
13
1
1
1
0
1
1
1
-18
18
-17
17
1
1
1
ticks
30.0

BUTTON
20
43
83
76
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

TEXTBOX
20
151
170
169
Recuento de electores:
14
102.0
1

INPUTBOX
675
158
725
218
iPP
44.8
1
0
Number

INPUTBOX
675
98
725
158
iIU
6.79
1
0
Number

INPUTBOX
676
218
726
278
iPSOE
39
1
0
Number

INPUTBOX
676
278
726
338
iEA
0.3
1
0
Number

INPUTBOX
676
338
726
398
iPNV
1.3
1
0
Number

INPUTBOX
725
98
775
158
iCIU
3.6
1
0
Number

INPUTBOX
726
157
776
217
iERC
2.5
1
0
Number

INPUTBOX
726
218
776
278
iBNG
0.8
1
0
Number

INPUTBOX
727
278
777
338
iNABAI
0.01
1
0
Number

INPUTBOX
726
338
776
398
iCC
0.7
1
0
Number

INPUTBOX
676
399
726
459
iCHA
0.2
1
0
Number

MONITOR
676
20
776
65
Porcentaje total
iIU + iPP + iPSOE + iEA + iPNV + iCIU + iERC + iBNG + iNABAI + iCC + iCHA
17
1
11

SWITCH
676
65
776
98
datos
datos
0
1
-1000

PLOT
784
10
1315
378
Grafica Partidos
Tiempo(tick)
Número Electores
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"IU" 1.0 0 -16777216 true "" "plot count votantes with [partido = \"IU\"]"
"PP" 1.0 0 -7500403 true "" "plot count votantes with [partido = \"PP\"]"
"PSOE" 1.0 0 -2674135 true "" "plot count votantes with [partido = \"PSOE\"]"
"EA" 1.0 0 -955883 true "" "plot count votantes with [partido = \"EA\"]"
"PNV" 1.0 0 -6459832 true "" "plot count votantes with [partido = \"PNV\"]"
"CIU" 1.0 0 -1184463 true "" "plot count votantes with [partido = \"CIU\"]"
"ERC" 1.0 0 -10899396 true "" "plot count votantes with [partido = \"ERC\"]"
"BNG" 1.0 0 -13840069 true "" "plot count votantes with [partido = \"BNG\"]"
"NABAI" 1.0 0 -14835848 true "" "plot count votantes with [partido = \"NABAI\"]"
"CC" 1.0 0 -11221820 true "" "plot count votantes with [partido = \"CC\"]"
"CHA" 1.0 0 -13791810 true "" "plot count votantes with [partido = \"CHA\"]"

BUTTON
20
10
83
43
GO
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

MONITOR
811
393
874
438
IU
word (count votantes with [partido = \"IU\"] * 100 / electores) \" %\"
17
1
11

MONITOR
874
438
936
483
PP
word (count votantes with [partido = \"PP\"] * 100 / electores) \" %\"
17
1
11

MONITOR
936
438
998
483
PSOE
word (count votantes with [partido = \"PSOE\"] * 100 / electores) \" %\"
17
1
11

MONITOR
998
438
1060
483
EA
word (count votantes with [partido = \"EA\"] * 100 / electores) \" %\"
17
1
11

MONITOR
1060
438
1122
483
PNV
word (count votantes with [partido = \"PNV\"] * 100 / electores) \" %\"
17
1
11

MONITOR
811
438
874
483
CIU
word (count votantes with [partido = \"CIU\"] * 100 / electores) \" %\"
17
1
11

MONITOR
874
393
936
438
ERC
word (count votantes with [partido = \"ERC\"] * 100 / electores) \" %\"
17
1
11

MONITOR
936
393
998
438
BNG
word (count votantes with [partido = \"BNG\"] * 100 / electores) \" %\"
17
1
11

MONITOR
998
393
1060
438
NABAI
word (count votantes with [partido = \"NABAI\"] * 100 / electores) \" %\"
17
1
11

MONITOR
1060
393
1122
438
CC
word (count votantes with [partido = \"CC\"] * 100 / electores) \" %\"
17
1
11

MONITOR
1122
438
1179
483
CHA
word (count votantes with [partido = \"CHA\"] * 100 / electores) \" %\"
17
1
11

MONITOR
31
172
88
217
IU
count votantes with [partido = \"IU\"]
17
1
11

MONITOR
31
217
88
262
PP
count votantes with [partido = \"PP\"]
17
1
11

MONITOR
31
262
88
307
PSOE
count votantes with [partido = \"PSOE\"]
17
1
11

MONITOR
31
306
88
351
EA
count votantes with [partido = \"EA\"]
17
1
11

MONITOR
31
351
88
396
PNV
count votantes with [partido = \"PNV\"]
17
1
11

MONITOR
87
172
150
217
CIU
count votantes with [partido = \"CIU\"]
17
1
11

MONITOR
88
218
150
263
ERC
count votantes with [partido = \"ERC\"]
17
1
11

MONITOR
88
263
150
308
BNG
count votantes with [partido = \"BNG\"]
17
1
11

MONITOR
88
307
150
352
NABAI
count votantes with [partido = \"NABAI\"]
17
1
11

MONITOR
88
351
150
396
CC
count votantes with [partido = \"CC\"]
17
1
11

MONITOR
31
396
88
441
CHA
count votantes with [partido = \"CHA\"]
17
1
11

BUTTON
83
10
146
43
prueba72
setup\nrepeat 72 [go]
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
20
75
168
108
electores
electores
0
7000
100
10
1
NIL
HORIZONTAL

SLIDER
20
108
168
141
efecto-medio
efecto-medio
0
max-pxcor
5
1
1
NIL
HORIZONTAL

BUTTON
83
43
146
76
NIL
go
NIL
1
T
OBSERVER
NIL
G
NIL
NIL
1

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

sirculo
true
0
Circle -7500403 false true 0 0 300

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
