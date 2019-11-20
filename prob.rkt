#lang racket

; This kind of works.  but the nested probabilities are a mess.
; Only luck makes this terminate if alternatives are recursive.
; Should probably flatten sentences to avoid a lot of random-looking parentheses.

; Maybe a recursion counter to block deep recursions?
; Maybe choose another altenative as recovery if an alternative blocks?

; Maybe a choice function that has some kind of odds to determine probabilities.

(require racket/random)

(define-syntax funs
  (syntax-rules ()
    [(funs a) (list (lambda() a))]
    [(funs a b ...) (cons (lambda () a) (funs b ...))]

   ))

(define-syntax choices
  (syntax-rules ()
    [(choices) (list)]
    [(choices (a b) ...) (list (list a (lambda () b)) ...)]
    ))

(define (count-odds a)
  (match a
   ('() 0)
   ((cons (list n d) rest) (+ n (count-odds rest)))
  ))

(define (select count a)
  (match a
   ('() (void))
   ((cons (list n d)  rest)
    (if ( < count n)
        d
        (select ( - count n) rest))
    )))

(define (choose a)
  (let ((c (count-odds a)))
    (let ((r (random c)))
      ((select r a))
      )))
      
(provide choose choices)