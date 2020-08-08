#lang racket
(require sgl sgl/gl-vectors)
(require racket/random)

;; Rectangles

; (define (rectangle-print [p : rectangle] [port : Output-Port] [ _ : (U Boolean One Zero)] )
(define (rectangle-print p port _ )
  (fprintf port "rectangle{x~s y~s ns~s ew~s p~s q~s}"
           (rectangle-x p) (rectangle-y p) (rectangle-ns p) (rectangle-ew p) (rectangle-p p) (rectangle-q p))
)

#;(define-struct rectangle
  ((x : Real)
   (y : Real)
   [ew : Real]
   [ns : Real]
   [p : (Option rectangle)]
   [q : (Option rectangle)])
  #:mutable
  #:property prop:custom-write rectangle-print
)

(define-struct rectangle (x y ns ew p q   ) #:mutable
  #:property prop:custom-write rectangle-print
  )

;(define (split [r : rectangle])
(define (split r)
  (match r
    ((rectangle x y ew ns _ _)
     (define f ( + 0.2 (* (random) 0.6)))
     (if ( > ns ew)
         (let* (
                (s (* ns f))
               ; (p : rectangle (rectangle x y s ew #f #f)
               ; (q : rectangle (rectangle (- ns s) ew #f #f))
                )
           (set-rectangle-p! r (rectangle x y ew s #f #f))
           (set-rectangle-q! r (rectangle x (+ y s)ew (- ns s) #f #f))
           r)
         (let* (
                (s (* ew f))
                ;(p : rectangle (rectangle ns s))
                ;(q : rectangle (rectangle ns (- ew s)))
                )
           (set-rectangle-p! r (rectangle x y s ns #f #f))
           (set-rectangle-q! r (rectangle (+ x s) y (- ew s) ns #f #f) )
           r)
         )
     )
    ))

;; Rectangle test

#;(define o (rectangle 0 0 1.0 1.0 #f #f))
#;  o
#; ( split o)
      
;; Drawing context

(require "drawer.rkt")


(define (rect-drawer rect)
  (define (rect-recur rect)
    #;(printf "~s\n" rect)
    (match rect
      ((rectangle x y ew ns p q)
           (when (not (or p q))
             (define red (gl-float-vector 1.0 0.0 0.0 1.0))
             (define green (gl-float-vector 0.0 1.0 0.0 1.0))
             (define blue (gl-float-vector 0.0 0.0 1.0 1.0))
             (define white (gl-float-vector 1.0 1.0 1.0 1.0))
             (define yellow (gl-float-vector 1.0 1.0 0.0 1.0))
             (define grey1 (gl-float-vector 0.35 0.35 0.35 0.35))
             (define grey2 (gl-float-vector 0.3 0.3 0.3 0.3))
             (define grey3 (gl-float-vector 0.25 0.25 0.25 0.25))
             (define grey4 (gl-float-vector 0.2 0.2 0.2 0.2))
             (define colours (list red green red white))
             #;(define rancolour (lambda () (random-ref (list red yellow yellow red))))
             (define rancolour (lambda () (random-ref (list grey1 grey2 grey3 grey4))))
             #;(define rancol (list (rancolour)(rancolour)(rancolour)(rancolour)))
             (define rancol (let ((c (rancolour))) (list c c c c)))
             (define plain (list green green green green))
             (define pond (list blue blue blue blue))
             (define m 0.0075)
             (define vertices (list
                               (gl-float-vector ( + x m)         ( + y m)        0.0 )
                               (gl-float-vector ( + x ( - ew m)) ( + y m)        0.0 )
                               (gl-float-vector ( + x ( - ew m)) ( + y (- ns m)) 0.0 )
                               (gl-float-vector (+ x m) (+ y ( - ns m))          0.0 )
                               )
               )
             (define (ranrot vertices)
               ; need rotation so opengl doesn't always choose the same triangles to draw the square as.
               (if ( > (random) 0.5)
                   vertices
                   (match vertices
                     ((list a b c d) (list b c d a))
                     )
                   )
               )
            (gl-begin 'quads)
             (for (
                   (col (if ( > (random) 0.00) rancol (if ( > (random) 0.2) plain pond)))
                   (vert (ranrot vertices))) 
               (gl-color-v col)
               (gl-vertex-v vert)
               )
             (gl-end)
             )
           (when p (rect-recur p))
           (when q (rect-recur q))
           )
      (else (void))
      )
    )
  (lambda ()
    (random-seed 7)
    (rect-recur rect))
  )

#; Recursive split

(define (recsplit rect)
  #;(printf "split ~s~n" rect)
  (match rect
    [(rectangle x y ew ns p q)
     (when (> (min ew ns) 0.1 )
       (split rect)
       (recsplit (rectangle-p rect))
       (recsplit (rectangle-q rect))
       )
     ]
    )
  rect)

(random-ref '(1 2 3))

(environ (rect-drawer
          (recsplit (rectangle -0.9 -0.9 1.8 1.8 #f #f))
          ))
