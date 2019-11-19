#lang racket
(define-syntax find
    (syntax-rules ()
      [ 
       (find ( pattern follow) ...)
       (lambda (facts)
         (for ([fact facts])
           [begin
             #;(print (list 'try 'fact fact 'against 'pattern ...))
             (match fact (pattern (begin #;(print (list 'found fact))(follow facts))) ... (_ (void)))
           ]
         )
      )]
    )
  )
(define-syntax check
  (syntax-rules ()
    [
     (check test follow)
     (if test follow (lambda (facts) (void)))
     ]
    )
  )

  ;; Is that really IT?

;; TODO:Don't want to have to write all those 'list's.
#;(match '(a c) ((list a b) (print b))) 

#| find takes a list of pairs (coded as a list, not a cons) of a pattern and a follow.
   It returns a function that takes a list of 'facts'.
   It matched the pattern for every 'fact' and proceeds to do follow for each of those,
      using the bindings provided by the pattern.
: Here is an example:

|#


#;((find ((list a b) (print b)))
       (list))

#| (list a b) is a pattern.
   (print b) is what is to be dome upon success.
   and (list) is the empty list of 'fact's, so nothing is found.

   And here's one with two facts to be found and one extraneous one:
|#


#;((find ((list 'a v w) (lambda (facts) (print v))))
       '((a c x) (a d y) (c e z)))
#;((find [(list 'a v w)
        (find (_ (lambda (facts) (print v))))])
       '((a c x) (a d y) (c e z))
       )

(define ground '((loves Bill Mary) (loves John Mary)))

; functions that will eventually be use in action rules to change state.
; Not complete yet.  Need to define 'contradicts'.  Need to deal with quantifiers.

(define (contradicts a b)
  (or
   (match a [(list 'not aa) (equal? aa b)] [_ #f]) 
   (match b [(list 'not bb) (equal? bb a)] [_ #f])
   ))
(define (filter a ground)
  (if (contradicts a (car ground)) (filter (cdr ground))
      (cons (car ground) (filter (cdr ground)))
))
  
(define (establish a ground)
  (cons a (filter a ground))
)

; TODO: find  better syntax for rules than the following:

((find ((list 'loves a n)
        (find ((list 'loves b n)
               (check (not (equal? a b))
                      (lambda (facts) (displayln (list a 'kills b))))))))
;; ((find ((list 'loves a n) (find ((list 'loves b n) (lambda (facts) (unless (equal? a b) (displayln (list a 'kills b)))))                               )))
  ground
 )

#| TODO: provide a better syntax for Racket predicate in a rule.  (Done?  Is check really adequate?
   TODO: pass in a function that collects actions in a variable.  Yes, a side effect.
         I'll use it instead of displayln, and it will accept an action and consequences.
         Or should actios be declared and contain their consequences?
   TODO: provide a nicer rule syntax.
   TODO: provide a notation for drawing conclusions
   TODO: Enable backward reasoning to find a rule that might contribute a particular conclusion.
   TODO: Introduce actors for use in games -- for exapmle, a player or a non-player character
|#