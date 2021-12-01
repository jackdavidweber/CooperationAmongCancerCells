turtles-own
[
  energy
]

patches-own
[
  gfy            ;; short for growth factor a (produced by yellow & red)
  gfp            ;; short for growth factor b (produced by pink & red)
]

to setup
  clear-all
  ;; creating the bugs the following way ensures that we won't
  ;; wind up with more than one bug on a patch
  ask n-of carrying-capacity patches [
    sprout 1 [
      set energy 10
      set color green
      if not mutation-occurs
      [
        ifelse random 100 < (prob-gfy-mutation * prob-gfp-mutation) / 100
        [
          set color red
        ]
        [
          if random 100 < prob-gfy-mutation [set color yellow]
          if random 100 < prob-gfp-mutation [set color pink]
        ]
      ]

      face one-of neighbors
      set size 2  ;; easier to see
    ]
  ]
  ;; plot the initial state of the system
  reset-ticks
end

to go
  if not any? turtles [ stop ]

  ;; diffuse both gf through world
  diffuse gfy diffusion-rate
  diffuse gfp diffusion-rate
  ;; The world retains a percentage of its gf each cycle.
  ;; (The Swarm and Repast versions have 1.0 meaning no
  ;; evaporation and 0.0 meaning complete evaporation;
  ;; we reverse the scale to better match the name.)
  ask patches [ set gfy gfy * (1 - evaporation-rate) ]
  ask patches [ set gfp gfp * (1 - evaporation-rate) ]

  ;; agentsets in NetLogo are always in random order, so
  ;; "ask turtles" automatically shuffles the order of execution
  ;; each time.
  ask turtles [
    produce_gf
    get_energy
    reproduce
  ]
  diffuse gfy diffusion-rate
  diffuse gfp diffusion-rate

  kill-turtles
  recolor-patches
  tick
end

to produce_gf
  let actual-output-gfy output-gfy
  let actual-output-gfp output-gfp

  ;; TODO: currently gf is outputted on currently occupied patch. Should maybe output gf in area surrounding to promote sharing
  if color = red [
    ifelse red-produces-gf
    [
      if energy < output-gfp + output-gfy [
        set actual-output-gfy round (actual-output-gfy / (actual-output-gfy + actual-output-gfp)) * energy
        set actual-output-gfp energy - actual-output-gfy
      ]
    ]
    [
      set actual-output-gfp 0
      set actual-output-gfy 0
    ]
  ]
  if color = yellow [
    if energy < output-gfy [set actual-output-gfy energy]  ;; makes sure that cell is not producing more gf than energy allows
    set actual-output-gfp 0
  ]
  if color = pink [
    if energy < output-gfp [set actual-output-gfp energy]  ;; makes sure that cell is not producing more gf than energy allows
    set actual-output-gfy 0
  ]
  if color = green [
    set actual-output-gfp 0
    set actual-output-gfy 0
  ]

  set gfy gfy + actual-output-gfy
  set gfp gfp + actual-output-gfp
  set energy energy - actual-output-gfy - actual-output-gfp

end

to get_energy
  if color = yellow [
    set energy energy + gfp * gf-energy-multiplier  ;; TODO: confirm that gfp is only the gfp of the patch the turtle is on
    set gfp 0
  ]
  if color = pink [
    set energy energy + gfy * gf-energy-multiplier
    set gfy 0
  ]
  if color = red [
    set energy energy + (gfp + gfy) * gf-energy-multiplier
    set gfp 0
    set gfy 0
  ]

  set energy energy + energy-to-all-turtles-per-tick
  ;; TODO: add energy for green
end

to recolor-patches
  ;; more gfy = red (255 0 0)
  ;; more gfp = blue (0 0 255)
  ;; both = magenta (255 0 255)
  ;; 1.7 is the correct magic number for scaling, I think

  ask patches [ set pcolor (list (min (list (gfy * 1.7) 255)) 0 (min (list (gfp * 1.7) 255))) ]
end

to find-empty-patch-or-die
  let target one-of neighbors with [not any? turtles-here]
  ifelse target != nobody [ move-to target ][die]  ;; TODO: can introduce concept of competition. i.e. if no empty space, offspring have to fight to see which survive
end

to reproduce ;; each turtle reproduces according to its fitness and then dies
  let fertility floor energy / reproduction-energy
  set energy energy - fertility * reproduction-energy

  hatch fertility [
    ;; Randomly mutate all non-cells.
    ;; TODO: figure out whether cancerous cells can mutate and stop double counting mutation rate.
    if mutation-occurs [
      if random 100 < prob-gfy-mutation [
        if color = green [set color yellow]
        if color = pink [set color red]
      ]
      if random 100 < prob-gfp-mutation [
        if color = green [set color pink]
        if color = yellow [set color red]
      ]
    ]

    set energy 1  ;; TODO: make cancer cells have higher energy than normal cells

    ;; move offspring to an adjacent empty patch. If no empty patches exist, offspring dies.
    find-empty-patch-or-die
  ]
end

;; kill turtles in excess of carrying capacity
;; note that reds, yellows, and pinks have equal probability of dying
to kill-turtles
  ;; Kill remaining turtles based on carrying-capacity
  let num-turtles count turtles
  if num-turtles > carrying-capacity [
    let num-to-die num-turtles - carrying-capacity
    ask n-of num-to-die turtles [ die ]
  ]
end

;;; the following procedures support the two extra buttons
;;; in the interface

;; remove all gf from the world
to gfy-nowhere
  ask patches [ set gfy 0 ]
end

;; add max-output-gf to all locations in the world
to gfy-everywhere
  ask patches [ set gfy gfy + output-gfy ]
end


; Copyright 2004 Uri Wilensky.
; See Info tab for full copyright and license.
@#$#@#$#@
GRAPHICS-WINDOW
371
10
779
419
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
99
0
99
1
1
1
ticks
30.0

BUTTON
22
186
91
219
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
93
186
161
219
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
0

SLIDER
177
171
370
204
evaporation-rate
evaporation-rate
0
0.02
0.0
0.001
1
NIL
HORIZONTAL

SLIDER
177
205
370
238
diffusion-rate
diffusion-rate
0
1
1.0
0.1
1
NIL
HORIZONTAL

SLIDER
199
112
372
145
output-gfp
output-gfp
0
100
60.0
1
1
NIL
HORIZONTAL

SLIDER
200
69
373
102
output-gfy
output-gfy
0
100
60.0
1
1
NIL
HORIZONTAL

TEXTBOX
8
239
135
267
Other parameters
11
0.0
0

TEXTBOX
7
165
157
183
Actions
11
0.0
0

TEXTBOX
7
260
148
289
(OK to change\nduring run)
11
0.0
0

SLIDER
105
30
284
63
carrying-capacity
carrying-capacity
1000
8000
8000.0
50
1
NIL
HORIZONTAL

PLOT
11
312
370
501
Cell Types
Time
Cell Types
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -2674135 true "" "plot count turtles with [color = red]"
"pen-1" 1.0 0 -2064490 true "" "plot count turtles with [color = pink]"
"pen-2" 1.0 0 -10899396 true "" "plot count turtles with [color = green]"
"pen-3" 1.0 0 -1184463 true "" "plot count turtles with [color = yellow]"

SLIDER
10
67
182
100
prob-gfy-mutation
prob-gfy-mutation
0
100
1.0
1
1
NIL
HORIZONTAL

SLIDER
10
111
183
144
prob-gfp-mutation
prob-gfp-mutation
0
100
1.0
1
1
NIL
HORIZONTAL

SWITCH
382
432
544
465
mutation-occurs
mutation-occurs
0
1
-1000

SLIDER
374
537
559
570
reproduction-energy
reproduction-energy
0
10
2.0
1
1
NIL
HORIZONTAL

SLIDER
583
536
793
569
gf-energy-multiplier
gf-energy-multiplier
0
5
4.0
1
1
NIL
HORIZONTAL

SLIDER
459
496
691
529
energy-to-all-turtles-per-tick
energy-to-all-turtles-per-tick
0
10
1.0
1
1
NIL
HORIZONTAL

SWITCH
605
433
768
466
red-produces-gf
red-produces-gf
1
1
-1000

TEXTBOX
376
476
526
494
Energy\n
11
0.0
0

@#$#@#$#@
## WHAT IS IT?


## HOW IT WORKS


## HOW TO USE IT

## Some good defaults:
* cell-count = 1000
* output-gfy = 60
* output-gfp = 60
* evaporation-rate = 0
* diffusion-rate = 1
* prob-gfy-mutation = 15
* prob-gfp-mutation = 15
* mutation-occurs = Off (means that mutation does not happen every time cell reproduces)
* gf-energy-multiplier = 4 (means that consuming 1 gf results in 4 energy)
* energy-to-all-turtles-per-tick =- 1
* reproduction-energy = 2 (means that 2 energy is required to reproduce a single offspring)
* carrying-capacity = 8000
* red-produces-gf = Off (means that red cancer cells can consume both kinds of gf but do not produce)

### What you will see
Groups of yellow and pink cells cluster together. Red cells surround them.

### Things to try
* decrease carrying capacity
* allow red to produce gf 


## RELATED MODELS

Slime

## CREDITS AND REFERENCES

Swarm version of Heatbugs -- https://web.archive.org/web/20130211011213/http://www.swarm.org/wiki/Examples_of_Swarm_applications

RePast version of Heatbugs -- http://repast.sourceforge.net/repast_3/examples/

## HOW TO CITE

If you mention this model or the NetLogo software in a publication, we ask that you include the citations below.

For the model itself:

* Wilensky, U. (2004).  NetLogo Heatbugs model.  http://ccl.northwestern.edu/netlogo/models/Heatbugs.  Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

Please cite the NetLogo software as:

* Wilensky, U. (1999). NetLogo. http://ccl.northwestern.edu/netlogo/. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

## COPYRIGHT AND LICENSE

Copyright 2004 Uri Wilensky.

![CC BY-NC-SA 3.0](http://ccl.northwestern.edu/images/creativecommons/byncsa.png)

This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 License.  To view a copy of this license, visit https://creativecommons.org/licenses/by-nc-sa/3.0/ or send a letter to Creative Commons, 559 Nathan Abbott Way, Stanford, California 94305, USA.

Commercial licenses are also available. To inquire about commercial licenses, please contact Uri Wilensky at uri@northwestern.edu.

This model was created as part of the projects: PARTICIPATORY SIMULATIONS: NETWORK-BASED DESIGN FOR SYSTEMS LEARNING IN CLASSROOMS and/or INTEGRATED SIMULATION AND MODELING ENVIRONMENT. The project gratefully acknowledges the support of the National Science Foundation (REPP & ROLE programs) -- grant numbers REC #9814682 and REC-0126227.

<!-- 2004 -->
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

square
false
0
Rectangle -7500403 true true 0 0 300 300

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

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.2.1
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
