#lang racket

; TODO: include a mechanism to forbid nesting a choice inside itself.
; no more magic magic magic gold bars
(require "prob.rkt")
(require racket/random)
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
    (1 (list 'translate 'from (language) 'to (language)))
    (1 (cons 'learn (random-ref (language))))
  ))))

(define (thing)
  (choose (choices
                (3 '(amulet))
                (3 '(gold bar))
                (1 (cons 'rare (thing)))
                (1 (cons 'magical (thing)))
                (1 (list (thing) 'and (thing)))
                )))

(define (language)
   (choose (choices
            (1 '(English))
            (1 '(French))
            (1 '(Sanskrit))
            )))
; (funs 'a 'b 'c)

; ((random-ref (funs 'a 'b 'c)))

(provide quest)

(quest)(quest)(quest)(quest)(quest)(quest)(quest)(quest)(quest)(quest)
