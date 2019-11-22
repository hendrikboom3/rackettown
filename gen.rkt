#lang racket

; TODO: include a mechanism to forbid nesting a choice inside itself.
; no more magic magic magic gold bars
(require "prob.rkt")
(require racket/random)
; (cons 'FOO (choose (choices (1 'a) (2 'b) (3 'c))))

(define (quest)
  (flatten (choose (choices
    (10 (list 'find (thing)))
;    (1 'event)
    (1 'accomplishment)
;    (1 'get-to-a-place)
    (1 'send-message)
    (1 (random-ref '(investigate explore find-out)))
    (1 (cons (random-ref '(capture photograph beg-a-favour-of paint)) 'supernatural-creature))
    (1 'calculate-something)
    (1 (list 'translate 'from (language) 'to (language)))
    (1 (cons 'learn (language)))
    (10 (cons (random-ref (list 'look 'go)) (random-ref (direction))))
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

(define (direction)
  (choose (choices
           (1 '(up))
           (1 '(down))
           (1 '(left))
           (1 '(right))
           (1 '(forward))
           (1 '(back))
           (1 '(east))
           (1 '(west))
           (1 '(north))
           (1 '(south))
           )))

; (funs 'a 'b 'c)

; ((random-ref (funs 'a 'b 'c)))

(define (scrib x)
  (cond 
    ((symbol? x) (symbol->string x))
    ((pair? x) (cons (scrib(car x)) (cons " " (scrib(cdr x)))))
    ((null? x) x)
    ((string? x) x)
    (#t "error")
    ))

(define (ll) (flatten (quest)))
(define (ss) (flatten (scrib (quest))))
(provide ss)
(ss) (ss) (ss)
'foo
(ll)(ll)(ll)(ll)(ll)(ll)(ll)(ll)(ll)(ll)

(provide quest)

(quest)(quest)(quest)(quest)(quest)(quest)(quest)(quest)(quest)(quest)
