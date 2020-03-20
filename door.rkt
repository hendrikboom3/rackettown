#lang racket
(require pict)
(require racket/gui/base)
(require racket/random)
(require colors)

; set-brightness is a built-in pict function I might need sometime for colour schemes

(define (show tag thing) (print (cons tag thing)) thing)

(show 'start 'now)

; TODO:

; Colour coordination based on hue, saturation and brightness?  Or some other kind of colour wheel theory?
; See https://docs.racket-lang.org/colors/index.html

; Choices need to have probabilities.  Now that seems easy -- just let the attribute
;   performs whatever random selection is required.
; But we might need to adjust probabilities if a local environmental constraint arises.
;   And then just having a function is quite useless, functions
;   being opaque in Scheme,

; And I need to worry about transparency for windows.
; At the moment, windows are drawn on top of walls.
; If I were to make them transparent, they would show the wall behind instead of being a hole in the wall.

; Attributes need to have constraints -- such as a list of colours to choose from,
; And we may need to further restrict choices, possibly with a list of current possibilities.
; And then further bindings, instead of choosing, could further restrict the list.
;   Or adjust probabilities.

; And sizes, such as length and width, need to be different.
; I'd like to be able to pass in size ranges.  and let the details of an image depend on what fits,
;   with the possibility if not producing an image at all if it's not possible.

; There's a lot of inconsistency about whether to explicitly pass associationlists as parameters.

; Some object drawing functions (occasionallt called just "object")
;   insist on receiving such a parameter.
; Others manipulate functions that do that without taking an asociation list as paramter itself.
; There may be a natural distinction here; but I cross the boundary too easily.
; The low-level drawing code needs to know what is to be drawn; it takes this from an association list.
; The higher-level combiners need to manipulate functions that take an association list and produce functions that take association lists.

; ---

; Attribute management

; Attributes are stored in an associationist.  I suspect that Racket's parameters would do as sell for the present system.
; And this mechansim works well when the territories I am generating recursively do not overlap.
; But I expect them to overlap in future application,
; and then I am going to have to invent some mechanism for merging two association lists in some way.
; I do no tknow what mechanism will be appropriate, but association ilsts will likely leave me more flexibility than Racket's parametere.


; ali is an environment.  It should contain all the parameters that are needed to make a typical whatever
; (at the moment, the whatevers are a row of buildings and their components.)
; It allows attributes to be defined as functions.
;   at lookup time the entire association list is passed to the function
;   so that its value can depend on other (not necessarily previous) parameters.


(define (looker name ali succeed fail)
  (letrec (
      (lookup2 (lambda (name aa succeed fail)
        (if (eq? aa '())
          (fail)
          (if (eq? name (caar aa))
            (let ((value (cdar aa)))
              (if (procedure? value)
        	  (succeed (value ali))
         	  (succeed value)
        	)
              )
            (lookup2 name (cdr aa) succeed fail)
          )
        )
      )))
    (lookup2 name ali succeed fail)
  )
)

(define (lookup name ali fail)
  (looker name ali (lambda (result) result) fail)
)

(define (old lookup name ali fail)
  (letrec (
      (lookup2 (lambda (name aa fail)
        (if (eq? aa '())
          (fail)
          (if (eq? name (caar aa))
            (let ((value (cdar aa)))
              (if (procedure? value)
        	  (value ali)
         	  value
        	)
              )
            (lookup2 name (cdr aa) fail)
          )
        )
      )))
    (lookup2 name ali fail)
  )
)

(define (binda name value a) (cons (cons name value) a))

(define (bind name value object)
  (lambda (a)
    (object (binda name value a))
  )
)

; Freezing is a mechanism for choosing parameters to be passed down to more local objects
;   so, for example, we can set some styles for all the windows in a neighbourhood, but allow each house to have its own style for windows.
;   This is accomplished by having the window-style be a function instead of a value.
;   The freeze calls the function and rebids the name to the result of that function.  The resulting associon list is passed down to lower objects.

(define (freezea name a)
  (let ((value (lookup name a (lambda () '()))))
    (if (eq? value '()) a (binda name value a))))
    
; Got the wrong definition for lookup.  Need a way for lookup to indicate success as well as failure.
;   Returning '() isn't enough.  I wonder what the right definition is.
; TAt the moment I never use freeze; onlu its curried varsions freezeo.  And I suspect I do not need freezaa.

(define (freeze name f a)
  ( let (( value (lookup name a (lambda () '())) ))
    (if (eq? value '())
      f
      (lambda (a) (f (binda name value a)))
    )
  )
)

(define (freezeo name object)
  ( lambda (a)
    (let (( value (lookup name a (lambda () '())) ))
    (if (eq? value '())
      (object a)
      (object (binda name value a))
    )
  ))
)

(define (fuzz name object)
   (lambda (a)
     (let ((value (lookup name a (lambda () '()))))
       (if (eq? value '())
           (object a)
           (object (binda name (* value (+ 1 (* 0.15 (- (random) 0.5)))) a))
           ))))

(define (with a name value) (cons (cons name value) a))


;  Graphics combinators

(define ( hor l )
  ; l is a list of drawing functions (that take an alist as parameter)
  ; (hor l) returns a drawing function (that takes an alist as parameter)
  (if (cons? l)
    (if
      (null? (cdr l))
      (car l)
      (let
        ( [rest (hor (cdr l))] )
	(lambda (a) (hb-append ((car l) a) (rest a)))
      )
    )
    (print "ERROR: null list in hor")
  )
)  

(define ( vert l )
  ; l is a list of drawing functions (that take an alist as parameter)
  ; (vert l) returns a drawing function (that takes an alist as parameter)
  ; and draws a stacl of the objects described by l.
  (if (cons? l)
    (if
      (null? (cdr l))
      (car l)
      (let
        ( [rest (vert (cdr l))] )
	(lambda (a) (vc-append ((car l) a) (rest a)))
      )
    )
    (print "ERROR:null list in vert")
  )
)  
	

(define (horsep count object spacer a) ; object and spacer are functions taking alists.
  ; returns an object consisting of count instances ot object separated by instances of spacer laid out horizontally.
  (if (equal? count 1) (object a)
      (if (equal? count 0) (blank)
    (ht-append (object a) (spacer a) (horsep ( - count 1 ) object spacer a))
  ))
)

(define (horsepp count object spacer)
  (lambda (a) (horsep count object spacer a))
  )

(define (spacer a)
  (blank 40 40) ; TODO: 40 should be an argument
  ; (filled-rectangle 40 40 #:color "white")
  )

; Geometry

(define (itri w h)
  ; A triangle.  Used to draw evergreen trees.
  (define (draw dc dx dy)
    (define path (new dc-path%))
    (send path move-to 0 h)
    (send path line-to ( / w 2) 0)
    (send path line-to w h)
    (send path close)
    (send dc draw-path path dx dy)
    )
  (dc draw w h)
)

; Architectural primitives

(define (innerframe framewidth border-colour w)
  ( let ([width (pict-width w)]
         [height (pict-height w)]
         )
     (let [ (v (filled-rectangle framewidth height #:color border-colour #:draw-border? #f))
         (h (filled-rectangle width framewidth #:color border-colour #:draw-border? #f))
     ]
       (pin-over (pin-over (pin-over (pin-over w 0 (- height framewidth) h) (- width framewidth) 0 v) 0 0 v) 0 0 h)
       )))
(define (outerframe framewidth border-colour w)
  ( let ([width (pict-width w)]
         [height (pict-height w)]
         )
     (let [ (v (filled-rectangle framewidth (+ height framewidth framewidth) #:color border-colour #:draw-border? #f))
         (h (filled-rectangle (+ framewidth width framewidth) framewidth #:color border-colour #:draw-border? #f))
     ]
       (pin-over (pin-over (pin-over (pin-over w 0 height h) width 0 v) (- framewidth) 0 v) 0 (- framewidth) h)
       )))

(define (window a)
  ( let ( [width (lookup 'width a (lambda () 100))]
          ; 10 isn't meant to be realistic.  It's meant to be ridiculous as a way of showing that something is wrong in the picture.
          [height (lookup 'height a (lambda () 10))]
          [style (lookup 'style a (lambda () 'paned))]
          [background  (make-color 80 120 100)]
          (border-colour "white")
	)
     ; (show 'framed style) (show 'width width) (show 'height height)
        (match style
          [ 'framed
	    ( innerframe 5 border-colour (filled-rectangle width height #:color background #:draw-border? #f))
          ]
          [ 'paned
            ( innerframe 5 border-colour
                  (let ((w  (lambda (a) (window (binda 'style 'framed (binda 'width (* width 0.5) (binda 'height (* height 0.5)  a)))))))
                    ((vert (list (hor (list w w)) (hor (list w w)))) a)
                  )
            )]
          [ 'plain
            (filled-rectangle (* width 1.00) (* height 1.00 ) #:color background #:draw-border #f)
            
          ]
        )
  )
)
(define (nodoor a)
  (let ((height (lookup 'doorheight a (lambda () 2000))))
    (blank 0 height)
    ))

(define (door a)
	(let
	    (
	      [width
	        (lookup 'doorwidth a (lambda () 100))
	      ]
	      [height (lookup 'doorheight a (lambda () 200))]
	    )
	    (pin-over
	      (pin-over
		   (filled-rectangle width height #:color (lookup 'colour a (lambda(a) "gray"))) ; the door itself
               (* width 0.05)	(* height 0.025)
		(window (binda 'style 'paned (binda 'width ( * width 0.9 ) (binda 'height (* height 0.45 ) a)))) ; the window in the door
	      )
	    (* width 0.85) (* height 0.6)
	    (disk ( * width 0.10) #:color (random-ref '("yellow" "white")))) ; the doorknob
	)
)

(define (over-background facade colour)
  ; provide a coloured background for facade extending to its width and height.  (is this its bounding box?)
    (pin-over (filled-rectangle (pict-width facade) (pict-height facade) #:draw-border? #f #:color colour)
              0 0
              facade)
  )

(define (dww a) ; a door and two windows, in varying configurations
  (let
      [
       (width
        (begin (lookup 'doorwidth a (lambda () 100)))
        )
       (height (lookup 'doorheight a (lambda () 200)))
       (wall (lookup 'wall a (lambda () "lightgreen")))
      ]
    (define fw (bind 'width ( * width 0.9 ) (bind 'height (* height 0.45 ) window)))
    (define space 40)
    (define facade (random-ref (list
                 (ht-append space (blank) (door a) (fw a) (fw a) (blank))
                 (ht-append space (blank) (fw a) (door a) (fw a) (blank))
                 (ht-append space (blank) (fw a) (fw a) (door a) (blank))
                 (ht-append space (blank) (ht-append (fw a) (fw a)) (door a) (blank))
                 )))
    (define facade2 (vc-append (spacer a) facade)) ; the storey extends above the windows and doors.
    (over-background facade2 wall) ; Give it a background colour
  )
)

(define (www a) ; A floor with three windows
  (let
      [
       (width
        (begin (lookup 'doorwidth a (lambda () 100)))
        )
       (height (lookup 'doorheight a (lambda () 200)))
       (wall (lookup 'wall a (lambda () "lightgreen")))
      ]
    (define fw (bind 'width ( * width 0.9 ) (bind 'height (* height 0.45 ) window)))
    (define space 40)
    (define facade (ht-append (nodoor a)
                              (random-ref (list
                                           (ht-append space (blank)  (fw a) (fw a) (fw a) (blank))
                                           (ht-append space (blank)  (ht-append (fw a) (fw a)) (fw a) (blank))
                                           (ht-append space (blank)  (fw a) (ht-append (fw a) (fw a)) (blank))
                                           )
                                          ; nodoor is called to impose proper height to the storey.
                                          )))
    (define facade2 (vc-append (spacer a) facade))
    (over-background facade2 wall)
  )
)

(define (ornament r)
  (disk r #:color (random-ref '("red" "blue" "lightgreen" "yellow" "white" "orange")))
  )

(define (decorate1 w h base)
  (define yf (random))
  ; (print yf)
  (define y (* h yf))
  (define x ( + ( * w yf (random)) (* 0.5 w ( - 1.0 yf))))
  ; (print (list 'w w 'h h 'yf yf 'x x 'y y))
  (pin-over base x y (ornament (* w 0.2)))
  )

(define (decorate n w h base)
  (if (equal? n 0) base
      (decorate1 w h (decorate ( - n 1 ) w h base)
                 )))

(define (xmas w h)
  (decorate 4 w h (colorize (itri w h) "darkgreen"))
  )

#|
  Branching trees are built in two passes.
  First, a branchinh skeleton is built tree structure of coordinates.
  Then, the tree is drawn according to this with branches and leaves.
  The original plan was to pass over the skeleton twoce, once to draw branches
    and another time to cover them with leaves.
  However, it seems to work fine with one pass.
  I should decide whether to eliminate building the skeleton
    or find other uses for it.

  Or course, the wnole process should be further parametrized so as to produce
    different kinds of trees.

  TODO: Can it be only one pass?
  TODO: remember the skeleton for redrawing in animation.
  TODO: Of course animation requires storing or reproducibly computing a *lot* of randomness.
|#

(define (branch a len n) ; TODO: Have some parameters, even a list for parameters at different recursion depths
  (if (or (<= n 0) #;( < (random) 0.8)) '()
      (let (
            (ranbranch (λ () (branch ( + a ( * 2.0 ( - (random) 0.5))) ( * len (random)) (- n 1))))
            )
        (list
         (* len (sin a)) (* len (cos a))
         (ranbranch) (ranbranch) (ranbranch) (ranbranch) (ranbranch) (ranbranch)
                             )
        )
      ))

;(define leafcolour "darkgreen")
(define (leafcolour) (make-color 0 ( + 100 (random 50)) 0 0.25))

(define (shrubcolour) (make-color 0 ( + 100 (random 100)) 0 1.0))

(define (brpict br w)
  (if (null? br) (disk 50 #:draw-border? #f #:color (leafcolour))
      (letrec (
               (iter (λ (base brl)
                       (if (null? brl)
                           base
                           (iter
                            (if (null? (car brl))
                             (pin-over base -25 -25 (brpict (car brl) ( / w 1.4)))
                             (pin-over base 0 0 (brpict (car brl) ( / w 1.4)))
                             )
                            (cdr brl))
                           )
                       ))
               )
        (let (
              (base (linewidth w (pip-line (car br) (cadr br) 0)))
              (twigs (iter (blank) (cddr br)))
              )
          (pin-over base (car br) (cadr br) twigs)
          )
        )
      ))


(define (rantree) (inset (colorize (brpict (branch pi (* 150 (+ 0.5 (random))) 5) 15) "brown") 200 300 200 0))
; TODO: calculate a proper bounding box.
; guessing 200 or 300 isn't enough.

(define (shrub)
  (random-ref (list
               (filled-ellipse
                 (random 60 120) ( random 60 120)
                 #:draw-border? #f
                 #:color #;(random-ref '("green" "lightgreen" "darkgreen")) (shrubcolour) ;; (leafcolour) was too transparent for shrubs
                 )
               (random-ref (list
                           (colorize (itri 100 200) "darkgreen") ; TODO: vary dimensions
                           (xmas 100 200))) ; TODO: vary dimensions
               (rantree)
               )
              )
  )



(define (ran-tl-superimpose base l) ; superpose the elements of l at random points along the bottom of base.
  (if
   (pair? l)
   (let ((dx ( - (* (random) (pict-width base)) ( / (pict-width (car l)) 2))) (dy ( - (pict-height base) (pict-height (car l)))))
     (ran-tl-superimpose
      (pin-over base dx dy (car l) )
      (cdr l))
     )
   base
   )
  )

(define (groundfloor a)
  (dww a)
  )

(define (upstairs a) (www a))

(define (building aaa)
  (let* (
         (aa (freezea 'wall aaa))
         (a (freezea 'style aa))
         )
    (over-background (vc-append (upstairs a) (upstairs a) (groundfloor a))
                     (lookup 'wall a (lambda () 'black))
                     )
    ))

(define (street a) ((hor
                    (list (fuzz 'doorheight building) (fuzz 'doorheight building)
                          (fuzz 'doorheight building) (fuzz 'doorheight building)
                    )) a))

(define (planted-street a)
 (ran-tl-superimpose (street a) ; TODO: more variety in witdhs and windows of buildings
                      (list (shrub) (shrub)(shrub) (shrub)(shrub) (shrub)(shrub) (shrub)(shrub) (shrub)) ; TODO: varying numners of shrubs, occasional constraints on shrub statistics
                      ; TODO: the trees are being chopped at building boundaries
                      ))

(define (scene a) (over-background (outerframe 100 "orange" (planted-street a)) "darkgrey") ) ; why the orange?  For visibility whe debugging?

; Test cases

(define colours '( "white" "red" "orange" "yellow" "chartreuse"
                           "green" "lightgreen" "darkgreen" "turquoise"
                           "blue" "lightblue" "darkblue" "purple" "gray"
                           "lightgray:" "darkgray"
                           "brown" "lightbrown" "darkbrown"
                           "black"))
(define (random-colour) (make-color (random 256) (random 256) (random 256)))


(define alist (list
      (cons 'doorwidth 100 )
      (cons 'doorheight 200 )
      (cons 'colour (lambda (a) (random-ref colours)))
      (cons 'highlight (lambda (a) (random-ref colours)))
      #;(cons 'wall (lambda (a) (random-ref colours)))
      (cons 'wall (lambda (a) (random-colour)))
      (cons 'style (lambda (a) (random-ref '(paned framed)))) ; 'plain is also a window style, but I won't choose it.
    )
)

(define the-scene (scene alist))

(show 'start 'drawing)

(show-pict  (scale (scene alist) 0.5))

(show 'done 'drawing)

