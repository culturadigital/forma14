;;; Variables de analisis globales
globals[
  numTotalMrna                      ;numero total de mensajero creados desde el inicio
  numTotalMrnaMedio                 ;numero medio de mensajero creados desde el inicio
  creaMRNA                          ;variable para crear
  ccr4acoplado                      ;ccr4 unidos a la pol
  radioTfiis                        ;radio de accion de TFIIS
  mediaVida                         ;vida media de los mensajeros
  mediaVelocidadPol                 ;velocidad media de transcripcion
]


;definir tipos agentes: promotor del gen, region codificante o CDS, terminador y Pol II (cada unidad estara formada por 250pb)

breed [promoters promoter]
breed [CDSs CDS]
breed [terminators terminator]
breed [PolIIs PolII]
breed [TFIISs TFIIS]
breed [mrnas mrna]              
breed [ccr4s ccr4] 
breed [xrn1s xrn1] 

;variables propias de cada agente

PolIIs-own [back-track transcription ccr4Feed VelPol]         ;definimos para las pol: back-track, trancripcion, tenga feedback con ccr4 y la velocidad de la pol
promoters-own [open xrn1Feed]                                 ;definimos para los promotores: open, tenga feedback con xrn1

mrnas-own[                                             ;definimos como propiedades de los mrna:
  lci                                                  ;longitud de la cadena de informacion
  lca                                                  ;longitud de la cadena de As
  estadoMrna                                           ;determina el estado actual de la enzima
                                                       ;0 = Buscando ccr4 / 1 = Degradando cadena de As / 2 = Buscando xrn1
                                                       ;3 = Degradando informacion / 4 = Destruccion y desacoplamiento
  vidaMrna                                             ;vida media
]                     

ccr4s-own[                                            ;definimos como propiedades de los ccr4:
  estadoCcr4                                          ;determina el estado actual de la enzima
                                                      ;0 = En movimiento / 1 = Acoplada al mrna 
                                                      ;2 = Buscando la polimerasa / 3 = Acoplada a la polimerasa
]

xrn1s-own[                                            ;definimos como propiedades de los xrn1:
  estadoxrn1                                          ;determina el estado actual de la enzima
                                                      ;0 = En movimiento / 1 = Acoplada al mrna 
                                                      ;2 = Buscando al promotor / 3 = Acoplado al promotor
]


;procedimiento setup

to setup
  clear-all                                   ;limpia todo lo que haya en el mundo
  reset-ticks                                 ;poner contador de ticks a 0
  set numTotalMrnaMedio 0                     ;hacemos que el numero de rna medio en el inicio sea 0
  ask patches[set pcolor white]               ; patches color blanco
  set numTotalMrna 0                          ;el numero total de mensajeros en el inicio sea 0
  set radioTfiis 2                            ;el radio de accion de TFIIS sea 2
  
  ;llamamos a las funciones que van a crear nuestros agentes
  
  ccr4F
  xrn1F
  
  set-default-shape promoters "helix"         ;hacemos que todos los promotores tengan por defecto la forma "doble helice"
  
  create-promoters 1                          ;creamos 2 promotores (500pb aprox de la region promotora)
  
  ask promoters [
    set color green                           ;fijamos el color de TODOS los promotores a verde
    set open Prob.Open                        ;fijamos el open segun la barra de deslizamiento prob.open
     setxy 1 0                                 ;fijen su posicion a las coordenadas x=1 y=0
    facexy 2 0                                ;fijen su orientacion hacia el x siguiente
    ]
    
 set-default-shape CDSs "helix"               ;hacemos que todos las CDSs tengan por defecto la forma "doble helice"  
 
 let xx 2
 create-CDSs 7 [                               ;creamos 7 CDSs (1750pb aprox de la region codificante)
   set color blue
   setxy xx 0
   set heading 90
   set xx xx + 1
 ]

 set-default-shape terminators "helix"         ;hacemos que todos los terminadores tengan por defecto la forma "doble helice"

 create-terminators 1                          ;creamos 1 terminador
  [
    set color red                             ;fijamos el color del terminador a rojo
    setxy 9 0                                 ;fijen su posicion a las coordenadas x=9 y=0
    facexy 10 0                               ;fijen su orientacion hacia el x siguiente
  ]
  
 set-default-shape PolIIs "circle"            ;hacemos que todos las PolIIs tengan por defecto la forma "circulo"  
   
 create-PolIIs Num.Pol                     ;creamos PolII segun la barra de deslizamiento num.pol
  
  ask PolIIs [                                ;pedimos a TODAS las PolII que:
    set color black                           ;fijen su color a blanco
    set xcor random-xcor                      ;se situen en una coordenada x aleatoria
    set ycor random-ycor                      ;se situen en una coordenada y aleatoria
    set back-track 0                          ;inicialmente las polimerasas no hace back-track
    set transcription 0                       ;inicialmente las polimerasas no estan transcribiendo
           ]
  set-default-shape TFIISs "dot"              ;que TFIIS sean puntos
  
  create-TFIISs Num.TFIIS                     ;crear TFIIS
  
  ask TFIISs [
     set color orange                          ;fijen su color a blanco
    set xcor random-xcor                       ;se situen en una coordenada x aleatoria
    set ycor random-ycor
       ]
end

;procedimiento go

to go
  set numTotalMrnaMedio (numTotalMrnaMedio + count mrnas)
  ask PolIIs [                                ;pedimos a las PolsII que:
    if (transcription = 0) [
      random-move                             ; ejecuten el procedimiento "movimiento-aleatorio" definido mas adelante si no esta  transcribiendo
    ] 
    initiate-transcription                    ;se ejecuta este procedimiento si la Pol encuentra un promotor
    elongate-transcription                    ;se ejecuta este procedimiento si se da el anterior 
    terminate-transcription                   ;se ejecuta este procedimiento si se da el anterior         
  ]
  if(creaMRNA = 1)[             ;si variable esta a uno se crea el mrna
    MRNAF
    set creaMRNA 0
    ]
  
  ask TFIISs [                                ;pedimos a TFIIS que:
    random-move                               ;se muevan aleatoriamente
    liberate-PolII                            ;ejecuten el procedimiento liberar a las Pol
    ]
  
  ask ccr4s [actualizaCcr4]
  ask xrn1s [actualizaxrn1]
  ask mrnas [actualizaMrna]
  
  ask promoters[actualizaProm]
  
  tick
  
end

;Factorias de mRNA

to mrnaF
  ifelse(ccr4acoplado = 0)[
  create-mrnas 1 ;creamos tantas mrna como le pasemos a la funcion
  [
  set lci 1590 ;definimos por defecto la longitud de la cadena de informacion
  set lca 100  ;definimos por defecto la longitud de la cadena de As
  set color green;
  setxy 9 0 ;dado que en este primer modelo la polimerasa no crea el mrna, su
                                  ;posicion inicial sera 0
  set estadoMRNA 0
  set numTotalMrna (numTotalMrna + 1)
  set vidaMrna ticks
  ]][
  create-mrnas 1 ;creamos tantas mrna como le pasemos a la funcion
  [
  set lci 1590 ;definimos por defecto la longitud de la cadena de informacion
  set lca 100  ;definimos por defecto la longitud de la cadena de As
  set color cyan;
  setxy 9 0 ;dado que en este primer modelo la polimerasa no crea el mrna, su
                                  ;posicion inicial sera 0
  set estadoMRNA 1
  set numTotalMrna (numTotalMrna + 1)
  ask one-of ccr4s with[estadoCcr4 = 3][set estadoCcr4 1 hide-turtle move-to patch 9 0]
  set ccr4Acoplado 0
  set vidaMrna ticks
  ]]
end


to ccr4F
  create-ccr4s numCcr4 ;creamos tantas ccr4 como le pasemos a la funcion
  
;inicializacion ccr4
  ask ccr4s[
    set estadoCcr4 0 ; el ccr4 empieza por defecto en el estado de movimiento normal
    set color blue;
    set shape "pentagon"
    setxy random-pxcor random-pycor ;el ccr4 empieza en una posicion aleatoria
  ]
end

to xrn1F
  create-xrn1s numxrn1 ;creamos tantas ccr4 como le pasemos a la funcion
  
;inicializacion xrn1
  ask xrn1s[
    set estadoxrn1 0 ; el xrn1 empieza por defecto en el estado de movimiento normal
    set color red;
    set shape "triangle"
        setxy random-pxcor random-pycor ;el xrn1 empieza en una posicion aleatoria
  ]
end

;;; Funciones de decision

to actualizaMrna                            ;Escoge la funcion de comportamiento que va a realizar (ver mas abajo) cada mrna en funcion de su estado (ver arriba)
  ifelse (estadoMrna = 0)[mrnaEstado0][       
    
    ifelse (estadoMrna = 1)[mrnaEstado1][
      
      ifelse (estadoMrna = 2)[mrnaEstado2][
       
       ifelse (estadoMrna = 3)[mrnaEstado3][
         
        mrnaEstado4
        
       ]
      ]
    ]
  ]
end

to actualizaCcr4                      ;ccr4 se mueve aleatoriamente en todo sus estados salvo cuando este acoplado con PolII o rna que se oculta
  moveRandom
end

to actualizaxrn1                      ;xrn1 se mueve aleatoriamente en todo sus estados salvo cuando este acoplado con promotor o rna que se oculta
  moveRandom
end




;;; Funciones de comportamientos

to moveRandom                       ;movimiento aleatorio
  rt random 361
  fd 1
end

to random-move                              ;definimos el procedimiento "movimiento-aleatorio"
  
  forward 1                                 ;avancen 1 posicion
  right random 181                          ;giren a la derecha 180º, angulo aleatorio
  left random 181                           ;giren a la izquierda 180º, angulo aleatorio
end

;estados del mRNA

to mrnaEstado0                                                               ;estado inicia, buacando ccr4                                                           
    if (any? ccr4s with [(estadoCcr4 = 0 ) and (distance myself  <= 1)] )[                                   ;si hay un ccr4 con estado 0 y a una dstacia del mensajero <= 1 entonces:
    ask one-of ccr4s with [(estadoCcr4 = 0 ) and (distance myself  <= 1)] [hide-turtle set estadoCcr4 1]     ;le pedimos un ccr4 con estado 0 y a una dstacia del mensajero <= 1 que se oculte y cambie su estado a acoplado 
    set estadoMrna 1 set color sky                                                                           ;cambia el estado del rna a degradandose por ccr4 y cambia su colo a celeste
  ]
    if (estadoMrna = 0 and any? ccr4s with [estadoCcr4 = 2 and (distance myself  <= 1)] )[
    ask one-of ccr4s with [estadoCcr4 = 2 and (distance myself  <= 1)] [hide-turtle set estadoCcr4 1]
    set estadoMrna 1 set color sky
  ]
  moveRandom
end


to mrnaEstado1                                ;siendo degradada por ccr4
  set lca (lca - 10)
  if (lca = 0)[set estadoMrna 2 set color sky]
  moverandom
end


to mrnaEstado2                                                                            ;buscando xrn1
    if (any? xrn1s with [(estadoxrn1 = 0 ) and (distance myself  <= 1)] )[
    ask one-of xrn1s with [(estadoxrn1 = 0 ) and (distance myself  <= 1)] [hide-turtle set estadoxrn1 1]
    set estadoMrna 3 set color yellow
    set mediaVida (mediaVida + (ticks - vidaMrna))
  ]
    if (estadoMrna = 2 and any? xrn1s with [estadoxrn1 = 2 and (distance myself  <= 1)] )[
    ask one-of xrn1s with [estadoxrn1 = 2 and (distance myself  <= 1)] [hide-turtle set estadoxrn1 1]
    set estadoMrna 3 set color yellow
    set mediaVida (mediaVida + (ticks - vidaMrna))
  ]
  moveRandom
end


to mrnaEstado3                                     ;siendo degradada por xrn1
  set lci (lci - 10)
  if (lci = 0)[set estadoMrna 4 set color brown]
  moverandom
end

to mrnaEstado4                                 ;muerte del rna y desacoplamiento de los degradadores
  let patchMrna patch-here
  ask one-of ccr4s with [estadoCcr4 = 1] [
    set estadoCcr4 2
    set color black
    move-to patchMrna
    show-turtle
  ]
  ask one-of xrn1s with [estadoxrn1 = 1] [
    set estadoxrn1 2
    set color violet
    move-to patchMrna
    show-turtle
  ]
  die
end

to initiate-transcription
  let probEnter 0                   ;definimos el procedimiento de inicio de la transcripcion  
  ask promoters [ifelse(xrn1Feed = 1)[set probEnter 100 ][set probEnter Prob.Open]]
  if (any? promoters with [open != 0] and ((random 100) < probEnter) and distance (patch 1 0) <= 2) [                ;si hay algun promotor en el patch en el que se encuentra:
    move-to patch 1 0
    set transcription 1                            ;modifica su propiedad "transcription" a 1, SI esta transcribiendo
    set heading 90                                 ;si encuentra un promotor que la PolII se oriente hacia la hebra de ADN 
    set VelPol ticks
    ask promoters [set open 0 set xrn1Feed 0]                     ;fijen el open del promotor a 0=cerrado
    ask xrn1s with [estadoxrn1 = 3][show-turtle set estadoxrn1 0 move-to patch 1 0 set color red]
    ]

  
end

to elongate-transcription                                        ;definimos el procedimiento de elongacion de la transcripcion
  let Prob.Back-track2 Prob.Back-track
  let Reactivation.Pol2 Reactivation.Pol
  set radioTfiis 2
  if (ccr4Feed = 1 and Ccr4Mode = "prevent-backtrack") [
    set radioTfiis 2
    set Prob.Back-track2 0
    ]
  
   if( Ccr4Mode = "help-TFIIS") [
     ifelse (ccr4Acoplado = 1)[
    set radioTfiis 2]
    [set radioTfiis 0]]
   
   if(Ccr4Mode = "help-polII")[
     if(ccr4Acoplado = 1)[
       set Reactivation.Pol2 1000
       ]
   ]
  
  ifelse (transcription = 1 and any? CDSs-here)  [               ;si la propiedad transcripcion es 1 = SI hay transcripcion y hay un CDS, pedimos a las polimerasas que:
    
    if ((random 100) < Prob.Back-track2 and back-track = 0)[      ;si sale un numero aleatorio menor que la barra de deslizamiento y la variable back-track es 0:
      set back-track 1                                           ;la variable pasa a 1
      back 1                                                     ; da un paso atras
      ]
    if (random 1000) < Reactivation.Pol2[
      set back-track 0
    ]
    if (back-track = 0)                                          ;si la variable es cero 
     [ forward 1]                                                ;avanza 1
  ] [ forward 1]                                                 ;si no se da todo lo anterios PolII avanza 1
  if (ccr4Feed = 0)[
    if (transcription = 1 and any? CDSs-here and any? ccr4s with [distance (myself) <= 2 and estadoCcr4 = 2])[
      ask one-of ccr4s with [estadoCcr4 = 2 and distance (myself) <= 2][hide-turtle set estadoCcr4 3]
      set ccr4Feed 1
      set ccr4Acoplado 1
    ]
    ]
end

to terminate-transcription                                       ;definimos el procedimiento de terminacion de la transcripcion
   
  if (any? terminators-here and transcription = 1) [                                    ;si hay algun terminador pedimos a las PolII que:
    set transcription 0                                           ;fijen la propiedad transcripcion a O y por tanto vuelva a moverse aleatoriamente 
    ask promoters [set open Prob.Open]                            ;fijen el open del promotor a la probabilidad de open
    set creaMRNA 1
    set ccr4Feed 0
    set radioTfiis 2 
    set mediaVelocidadPol (mediaVelocidadPol + (ticks - VelPol))
    ]
end

to liberate-PolII                                                ;definimos el procedimiento liberar a la pol
  if (any? PolIIs with [back-track = 1 and distance myself <= radioTfiis]) [                  ;si hay en este patch una PolII con back-track=1
    ask one-of PolIIs with [back-track = 1 and distance myself <= radioTfiis] [set back-track 0]                    ;pedimos a esa PolII que pase a back-track=0, se libera del bloqueo
    ]
end

to actualizaProm                  ;define el comportamiento del promotor cuando una xrn1degradada esta cerca del promotor sin acomplamiento xrn1 se acopla al promotor
  if(xrn1Feed = 0)[                                                                                          
    if (one-of xrn1s with [estadoxrn1 = 2 and (distance patch 1 0  <= 1)]) != NOBODY [                       
    ask one-of xrn1s with [estadoxrn1 = 2 and (distance patch 1 0  <= 1)] [ hide-turtle set estadoxrn1 3 ]
    ask promoters [set xrn1Feed 1]
  ]
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
234
10
782
579
16
16
16.30303030303031
1
10
1
1
1
0
1
1
1
-16
16
-16
16
0
0
1
ticks
30.0

BUTTON
4
11
67
44
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
156
10
219
43
NIL
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
6
232
178
265
Prob.Back-track
Prob.Back-track
0
100
10
1
1
NIL
HORIZONTAL

SLIDER
5
272
177
305
Prob.Open
Prob.Open
0
100
50
1
1
NIL
HORIZONTAL

SLIDER
8
153
180
186
numCcr4
numCcr4
0
100
40
1
1
NIL
HORIZONTAL

SLIDER
7
193
179
226
numxrn1
numxrn1
0
100
40
1
1
NIL
HORIZONTAL

MONITOR
790
114
871
159
NIL
count mrnas
17
1
11

TEXTBOX
788
15
938
99
Gen= X\nPolimerasa= círculo\nTFIIS= punto\nXRN1= triángulo\nCCr4= pentagono\nMRNA= rectángulo
11
0.0
1

BUTTON
80
11
143
44
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

SLIDER
8
70
180
103
Num.Pol
Num.Pol
0
100
60
1
1
NIL
HORIZONTAL

SLIDER
8
113
180
146
Num.TFIIS
Num.TFIIS
0
100
40
1
1
NIL
HORIZONTAL

CHOOSER
11
354
161
399
Ccr4Mode
Ccr4Mode
"prevent-backtrack" "help-TFIIS" "help-polII" "No feedback"
0

SLIDER
4
312
176
345
Reactivation.Pol
Reactivation.Pol
0
100
50
1
1
NIL
HORIZONTAL

PLOT
789
227
1167
482
mRNA
Time
mRNA
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot count mrnas"

MONITOR
887
114
1056
159
Vida media mRNA
(mediaVida / numTotalMrna)
17
1
11

MONITOR
1013
175
1172
220
Media cantidad mRNA
numTotalMrnaMedio / ticks
17
1
11

MONITOR
792
175
1002
220
Tiempo Medio Transcripcionl
(mediaVelocidadPol / numtotalmrna)
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
false
0
Rectangle -7500403 true true 0 75 315 225

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

double-helix
false
0
Rectangle -7500403 true true 135 135 150 150
Rectangle -7500403 true true 150 135 165 150
Rectangle -7500403 true true 135 150 150 165
Rectangle -7500403 true true 150 150 165 165
Rectangle -7500403 true true 165 120 180 135
Rectangle -7500403 true true 150 120 165 135
Rectangle -7500403 true true 180 105 195 120
Rectangle -7500403 true true 165 105 180 120
Rectangle -7500403 true true 180 90 195 105
Rectangle -7500403 true true 195 90 210 105
Rectangle -7500403 true true 195 75 210 90
Rectangle -7500403 true true 210 75 225 90
Rectangle -7500403 true true 210 60 225 75
Rectangle -7500403 true true 225 60 240 75
Rectangle -7500403 true true 225 45 240 60
Rectangle -7500403 true true 240 45 255 60
Rectangle -7500403 true true 240 30 255 45
Rectangle -7500403 true true 165 165 180 180
Rectangle -7500403 true true 150 165 165 180
Rectangle -7500403 true true 165 180 180 195
Rectangle -7500403 true true 180 180 195 195
Rectangle -7500403 true true 195 195 210 210
Rectangle -7500403 true true 180 195 195 210
Rectangle -7500403 true true 195 210 210 225
Rectangle -7500403 true true 210 210 225 225
Rectangle -7500403 true true 225 225 240 240
Rectangle -7500403 true true 210 225 225 240
Rectangle -7500403 true true 225 240 240 255
Rectangle -7500403 true true 240 255 255 270
Rectangle -7500403 true true 240 240 255 255
Rectangle -7500403 true true 45 255 60 270
Rectangle -7500403 true true 120 165 135 180
Rectangle -7500403 true true 45 240 60 255
Rectangle -7500403 true true 60 240 75 255
Rectangle -7500403 true true 60 225 75 240
Rectangle -7500403 true true 75 225 90 240
Rectangle -7500403 true true 75 210 90 225
Rectangle -7500403 true true 90 210 105 225
Rectangle -7500403 true true 90 195 105 210
Rectangle -7500403 true true 105 195 120 210
Rectangle -7500403 true true 105 180 120 210
Rectangle -7500403 true true 120 180 135 195
Rectangle -7500403 true true 135 165 150 180
Rectangle -7500403 true true 120 120 135 135
Rectangle -7500403 true true 135 120 150 135
Rectangle -7500403 true true 120 105 135 120
Rectangle -7500403 true true 105 105 120 120
Rectangle -7500403 true true 90 90 105 105
Rectangle -7500403 true true 105 90 120 105
Rectangle -7500403 true true 90 75 105 90
Rectangle -7500403 true true 75 75 90 90
Rectangle -7500403 true true 75 60 90 75
Rectangle -7500403 true true 60 60 75 75
Rectangle -7500403 true true 60 45 75 60
Rectangle -7500403 true true 45 45 60 60
Rectangle -7500403 true true 45 30 60 45

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

helix
false
0
Polygon -7500403 true true 150 150 150 135 165 135 165 120 180 120 180 105 195 105 195 90 210 90 210 75 225 75 225 60 240 60 240 45 255 45 255 30 270 30 270 45 270 60 255 60 255 75 240 75 240 90 225 90 225 105 210 105 210 120 195 120 195 135 180 135 180 150 165 150 165 165 180 165 180 180 195 180 195 195 210 195 210 210 225 210 225 225 240 225 240 240 255 240 255 255 270 255 270 270 240 270 240 255 225 255 225 240 210 240 210 225 195 225 195 210 180 210 180 195 165 195 165 180 150 180 150 165 135 165 135 180 120 180 120 195 105 195 105 210 90 210 90 225 75 225 75 240 60 240 60 255 45 255 45 270 30 270 30 240 45 240 45 225 60 225 60 210 75 210 75 195 90 195 90 180 105 180 105 165 120 165 120 150 135 150 135 135 120 135 120 120 105 120 105 105 90 105 90 90 75 90 75 75 60 75 60 60 45 60 45 45 30 45 30 30 60 30 60 45 75 45 75 60 90 60 90 75 105 75 105 90 120 90 120 105 135 105 135 120 150 120 150 135
Polygon -7500403 true true 30 270 30 285 15 285 15 300 0 300 0 285 0 270 15 270 15 255 30 255
Polygon -7500403 true true 270 45 285 45 285 30 300 30 300 0 285 0 285 15 270 15
Polygon -7500403 true true 45 30 45 15 30 15 30 0 0 0 0 15 15 15 15 30
Polygon -7500403 true true 270 270 285 270 285 285 300 285 300 300 270 300 270 285 255 285 255 270
Rectangle -7500403 true true 0 15 15 30
Rectangle -7500403 true true 285 270 300 285
Polygon -7500403 true true 0 270 0 255 15 255 15 240 30 240 30 225 45 225 45 210 60 210 60 195 75 195 75 180 90 180 90 165 105 165 105 150 120 150 120 165 105 165 105 180 90 180 90 195 75 195 75 210 60 210 60 225 45 225 45 240 30 240 30 255 15 255 15 270
Polygon -7500403 true true 150 135 150 120 165 120 165 105 180 105 180 90 195 90 195 75 210 75 210 60 225 60 225 45 240 45 240 30 255 30 255 15 270 15 270 0 285 0 285 15 270 15 270 30 255 30 255 45 240 45 240 60 225 60 225 75 210 75 210 90 195 90 195 105 180 105 180 120 165 120 165 135 150 135
Polygon -7500403 true true 150 180 150 195 165 195 165 210 180 210 180 225 195 225 195 240 210 240 210 255 225 255 225 270 240 270 240 285 255 285 255 300 270 300 270 285 255 285 255 270 240 270 240 255 225 255 225 240 210 240 210 225 195 225 195 210 180 210 180 195 165 195 165 180
Polygon -7500403 true true 120 135 105 135 105 120 90 120 90 105 75 105 75 90 60 90 60 75 45 75 45 60 30 60 30 45 15 45 15 30 30 30 30 45 45 45 45 60 60 60 60 75 75 75 75 90 90 90 90 105 105 105 105 120 120 120 120 135
Rectangle -7500403 true true 120 135 135 150

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

pol
false
0
Circle -1 true false 96 96 108
Circle -1 true false 103 13 95

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
<experiments>
  <experiment name="experiment" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>count turtles</metric>
    <enumeratedValueSet variable="numCcr4">
      <value value="48"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Reactivation.Pol">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Prob.Open">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Num.Pol">
      <value value="59"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Prob.Back-track">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Ccr4Mode">
      <value value="&quot;prevent-backtrack&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="numxrn1">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Num.TFIIS">
      <value value="46"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
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
