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
   (print b) is that is to be dome upon success.
   and (list) is the empty list of 'fact's, so nothing is found.

   And here's one with two facts to be found and one extrneous one:
|#


#;((find ((list 'a v w) (lambda (facts) (print v))))
       '((a c x) (a d y) (c e z)))
#;((find [(list 'a v w)
        (find (_ (lambda (facts) (print v))))])
       '((a c x) (a d y) (c e z))
       )

(define ground '((loves Bill Mary) (loves John Mary)))

((find ((list 'loves a n) (find ((list 'loves b n) (lambda (facts) (displayln (list 'kills a b))))
                               )))
  ground
 )

#| TODO: provide a constraint that two individuals ae distinct.
   TODO: provide a nicer rule syntax.
   TODO: provide a notation for drawing conclusions
   TODO: Enable backward reasoning to find a rule that might contribute a particular conclusion.
|#