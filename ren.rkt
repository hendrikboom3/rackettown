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
      
; (cons 'FOO (choose (choices (1 'a) (2 'b) (3 'c))))

(define (quest)
  (flatten (choose (choices
    (10 (list 'find (thing)))
    (1 'event)
    (1 'accomplishment)
    (1 'get-to-a-place)
    (1 'send-message)
    (1 (random-ref '(investigate explore find-out)))
    (1 (cons (random-ref '(capture photograph beg-a-favour-of paint)) 'supernatural-creature))
    (1 'calculate-something)
    (1 'translate)
    (1 (cons 'learn (random-ref '(language))))
  ))))

(define (thing)
  (choose (choices
                (1 '(amulet))
                (1 '(gold bar))
                (1 (cons 'rare (thing)))
                (1 (cons 'magic (thing)))
                (1 (list (thing) 'and (thing)))
                )))

; (funs 'a 'b 'c)

; ((random-ref (funs 'a 'b 'c)))

(quest)(quest)(quest)(quest)(quest)(quest)(quest)(quest)(quest)(quest)
