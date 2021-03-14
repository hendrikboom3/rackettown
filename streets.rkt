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

; TODO: some of these could come from the appropriate Racket package
(define red (gl-float-vector 1.0 0.0 0.0 1.0))
(define green (gl-float-vector 0.0 1.0 0.0 1.0))
(define blue (gl-float-vector 0.0 0.0 1.0 1.0))
(define white (gl-float-vector 1.0 1.0 1.0 1.0))
(define yellow (gl-float-vector 1.0 1.0 0.0 1.0))
(define grey1 (gl-float-vector 0.35 0.35 0.35 0.35))
(define grey2 (gl-float-vector 0.3 0.3 0.3 0.3))
(define grey3 (gl-float-vector 0.25 0.25 0.25 0.25))
(define grey4 (gl-float-vector 0.2 0.2 0.2 0.2))

(struct polygon (vertices p q))
(define (poly-drawer poly)
  (define (poly-recur poly)
    (printf "poly ~s\n" poly)
    (match poly
      ((polygon vertices p q)
       (printf "  vertices ~s~n" vertices)
       (when (not (or p q))
         (define colours (list red green red white blue))
         (define rancolour (lambda () (random-ref (list red yellow yellow red blue))))
         #;(define rancolour (lambda () (random-ref (list grey1 grey2 grey3 grey4))))
         #;(define rancol (list (rancolour)(rancolour)(rancolour)(rancolour) (rancolour)))
         (define rancol (let ((c (rancolour))) (list c c c c c)))
         (define plain (list green green green green green))
         (define pond (list blue blue blue blue blue))
         (define m 0.0075)
         ; TODO: indent from edges of poly
         #;(define vertices (list
                             (gl-float-vector ( + x m)         ( + y m)        0.0 )
                             (gl-float-vector ( + x ( - ew m)) ( + y m)        0.0 )
                             (gl-float-vector ( + x ( - ew m)) ( + y (- ns m)) 0.0 )
                             (gl-float-vector (+ x m)          (+ y ( - ns m)) 0.0 )
                             )
             )
         ; TODO: Do I need a real ranrot here?
         (define (ranrot vertices) vertices)
         #;(define (ranrot vertices)
             ; need rotation so opengl doesn't always choose the same triangles to draw the square as.
             (if ( > (random) 0.5)
                 vertices
                 (match vertices
                   ((list a b c d) (list b c d a))
                   )
                 )
             )
         (gl-begin 'polygon)
         (for (
               (col (if ( > (random) 0.00) colours (if ( > (random) 0.2) plain pond)))
               (vert vertices #;(ranrot vertices))) 
           (printf "    colour ~s vertex ~s~n" vert col)
           (gl-color-v col)
           (gl-vertex-v vert)
           )
         (gl-end)
         )
       (when p (poly-recur p))
       (when q (poly-recur q))
       )
      (else (void))
      )
    )
  (lambda ()
    #;(random-seed 6)
    (poly-recur poly))
  )

(define (rect-drawer rect)
  (printf "in rect-drawer~n")
  (define (rect-recur rect)
    (printf "in rect-recur ~s\n" rect)
    (match rect
      ((rectangle x y ew ns p q)
           (when (not (or p q))
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
  (printf "out rect-drawer\n")
  (lambda ()
    (define s (random 100))
    (printf "seed ~s~n" s)
    (random-seed s)
    (rect-recur rect))
  )

; Recursive split poly
(define (psplit poly i j)
  ; split a poly whose longest diagonal in from vertex i to j
  (void)
  )

(define (distance2 v1 v2)
  ;(printf "v1 ~s v2 ~s~n" v1 v2)
  (define sum 0)
  (for ((x1 (in-vector(gl-vector->vector v1))) (x2 (in-vector (gl-vector->vector v2))))
    ;(printf "x1 ~s x2 ~s~n" x1 x2)
    (set! sum (+ sum ( * (- x1 x2) (- x1 x2))))
    )
  sum)

(define (polysplit poly)
  (match poly
    [(polygon vertices p q)
     (define index1 0)
     (define index2 0)
     (define maxsofar 0)
     (for ([i (in-range (vector-length vertices))]) ; todo: get ranges right
             (for ([j (in-range (+ 1 i) (vector-length vertices))])
               (define d (distance2 (vector-ref vertices i) (vector-ref vertices j)))
               ( when ( > d maxsofar) (set! maxsofar d)
                  (set! index1 i)
                  (set! index2 j)
                  )
               ))
     (when (> maxsofar .01)
       (psplit poly index1 index2) ; This one will be nontrivial
       (polysplit (polygon-p poly))
       (polysplit (polygon-q poly))
       )
     ]
    [else (void)]
    )
  poly
  )

; recursive slpi rectangle

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

(printf "verv? ~s~n" (gl-float-vector? (gl-float-vector 0.0 0.0 0.0)))
(printf "vect? ~s~n" (vector? (gl-float-vector 0.0 0.0 0.0)))

#;(environ (poly-drawer
;          (polysplit
           (polygon
                      (vector
                       (gl-float-vector 0.0 0.0 0.0)
                       (gl-float-vector 0.5 0.0 0.0)
                       (gl-float-vector 0.5 0.9 0.0)
                       (gl-float-vector -0.3 0.8 0.0)
                       (gl-float-vector -0.3 0.2 0.0)
                       ) #f #f)
           )
;          )
         )
(printf "hello.~n")
(environ (rect-drawer
          (recsplit (rectangle -0.9 -0.9 1.8 1.8 #f #f))
          ))
(printf "goodbye.~n")
