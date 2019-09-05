#lang racket
(require pict)
(require racket/gui/base)
(require racket/random)

(define (show tag thing) (print (cons tag thing)) thing)

; TODO:

; Choices need to have probabilities.  Now that seems easy -- just let the attribute
;   performs whatever random selection is required.
; But we might need to adjust probabilities if a local environmental constraint arises.
;   And then just having a function is quite useless, functions
;   being opaque in Scheme,


; Attributes need to have constraints -- such as a list of colours to choose from,
; And we may need to further restrict choices,   possibly with possibilities.
; And then further bindings, instead of choosing, could further restrict the list.
;   Or adjust probabilities.

; And sizes, such as length and width, need to be different.
; I'd like to be able to pass in size ranges.  and let the details of an image depend on whether they fit,
;   with the possibility if not producing an image at all if it's not possible.

; There's a lot of inconsistency about whether to explicitly pass associationlists as parameters.

; Some object drawing functions (occasionallt called just "object")
;   insist on receiving such a parameter.
; Others manipulate functions that do that without taking an asociation list as paramter itself.
; There may be a natural distinction here; but I cross the boundary too easily.
; The low-level drawing code needs to know what is to be drawn; it takes this from an association list.
; The higher-level combiners need to manipulate functions that take an association list and produce functions that take association lists.



; Attribute management

; ali is an environment.  It should contain all the parameters that are neede to make a typical whatever (at the moment, the whatever is a door.)
; At the moment, also, it allows attributes to be defined as functions
;   at lookup time the entire association list is passed to the function so that its value can depend on other (not necessarily previous) parameters.

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
;   so, for example, we can set a style for all the windows in a house, but allow each house to have its own style for windows.
;   This is accomplished by having the window-style be a function instead of a value.  The freeze calls the function and rebids the name to the result of that function.  The resulting associon list is passed down to lower objects.

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

(define (with a name value) (cons (cons name value) a))


;  Graphics combinators

(define ( hor l )
  (if (cons? l)
    (if
      (null? (cdr l))
      (car l)
      (let
        ( [rest (hor (cdr l))] )
	(lambda (a) (hc-append ((car l) a) (rest a)))
      )
    )
    (print "ERROR: null list in hor")
  )
)  

(define ( vert l )
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
  (if (equal? count 1) (object a) ; TODO: zero case
    (ht-append (object a) (spacer a) (horsep ( - count 1 ) object spacer a))
  )
)

(define (horsepp count object spacer)
  (lambda (a) (horsep count object spacer a))
  )

(define (spacer a)
  (blank 40 40)
  ; (filled-rectangle 40 40 #:color "white")
  )


; Architectural primitives

(define (frame framewidth w)
  ( let ([width (pict-width w)]
         [height (pict-height w)]
         )
     (let [ (v (filled-rectangle framewidth height #:color "red" #:draw-border? #f))
         (h (filled-rectangle height framewidth #:color "red" #:draw-border? #f))
     ]
       (pin-over (pin-over (pin-over (pin-over w 0 (- height framewidth) h) (- width framewidth) 0 v) 0 0 v) 0 0 h)
       )))

(define (window a)
  ( let ( [width (lookup 'width a (lambda () 100))]
          ; 10 isn't meant to be realistic.  It's meant to be ridiculous as a way of showing that something is wrong in the picture.
          [height (lookup 'height a (lambda () 10))]
          [style (lookup 'style a (lambda () 'paned))]
          [background (make-color 80 120 100)]
	)
     ; (show 'framed style) (show 'width width) (show 'height height)
        (match style
          [ 'framed
	    ( frame 5 (filled-rectangle width height #:color background #:draw-border? #f))
          ]
          [ 'paned
            ( frame 5
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
		   (filled-rectangle width height #:color (lookup 'colour a (lambda(a) "gray")))
               (* width 0.05)	(* height 0.025)
		(window (binda 'style 'paned (binda 'width ( * width 0.9 ) (binda 'height (* height 0.45 ) a))))
	      )
	    (* width 0.85) (* height 0.6)
	    (disk ( * width 0.10) #:color "yellow"))
	)
)

(define (dww a)
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
    (define facade2 (vc-append (spacer a) facade))
    (pin-over (filled-rectangle (pict-width facade2) (pict-height facade2) #:color wall)
              0 0
              facade2)
    ;   (ht-append (door a) (window a) (door a))
  )
)

(define (4doors a)
  (horsep 4 door spacer a)
)

(define (8doors a)
  (horsep 8 door spacer a)
)

; Test cases

(define colours '( "white" ; "red" "orange" "yellow" "chartreuse"
                           "green" "lightgreen" "darkgreen" "turquoise"
                           "blue" "lightblue" "darkblue" "purple" "gray"
                           "lightgray:" "darkgray"
                           "brown" "lightbrown" "darkbrown"
                           "black"))



(define alist (list
      (cons 'doorwidth 100 )
      (cons 'doorheight 200 )
      (cons 'colour (lambda (a) (random-ref colours)))
      (cons 'highlight (lambda (a) (random-ref colours)))
      (cons 'wall (lambda (a) (random-ref colours)))
      (cons 'style (random-ref '(paned framed))) ; 'plain is also a window style, but I won't choose it.
    )
)

; (lookup 'colour alist (lambda(a) "gray"))

; (print 'yup)

; (show 'alist alist)

; (print 'bar)
; (print "\n")

(define (stackdoors a)
  (vc-append
    (4doors a)
    (8doors a)
    ((freezeo 'colour 8doors) a)
))



; (show-pict ((hor (list door window door)) alist))

; (show-pict (horsep 3 door window alist))

; (show-pict (scale (stackdoors alist) 0.5))

(show-pict (scale (dww alist) 2.0))


(define e1 0)
(define e2 0)
(define e3 0)

(define (rantest)
         (for ([i (in-range 1 10000)])
           (let ((c (random-ref '(u v w))))
             (if (eq? c 'u) (set! e1 (+ e1 1))
                 (if (eq? c 'v) (set! e2 (+ e2 1))
                     (if (eq? c 'w) (set! e3 (+ e3 1))
                         '()
                         ))))))

(rantest)

(print (list 'alpha e1 e2 e3 'omega))
