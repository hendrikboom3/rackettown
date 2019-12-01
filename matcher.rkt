#lang racket

(require racket/random)

; Searching the database of elementary facts

(define-syntax find
#|
find matches a bunch of patterns agaoins a list of facts.
Each pattern is matched with a 'follow', which can do simething
   fact is found that matches the pattern.
Typically, follow can perform further matching, report results
   using a side effect, or abort processing by calling a outer
   continuation.
This is somewhat curried.
The match macro takes the list of (pattern, follow) pairs
   produces a funtion that takes the list of facts as parameter.
   That function does the matching, and if successful, calls follow
   with the list of facts as argument.
   follow can use the variables that were matched in the pattern
and calls follow with the list of facts.

NOtice that follow takes the same kind of arguments as the function
    that find produces.
Thus the follow function can be another call to find, enabling one
    to nest find's to accomplish a kind of 'and'.

Taking a list of pattern, follow pairs effectively provides a kind
   of 'or'
|#
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

#|
check is like match, excepts it just tests an arbitrary boolean expressions
and calls follow only if it returns true.
It can ths be used to filter results.
|#

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

#| find takes a list of pairs
   Each pair is coded as a list, not a cons, and contains a pattern and a follow.
   It returns a function that takes a list of 'facts'.
   It matches the pattern for every 'fact' and proceeds to do follow for each of those,
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

; Defining the database

; Here's a data base as an example.  It is used in a test cas.

(define ground '((loves Bill Mary) (loves John Mary) (loves Mary Brian) (loves Brian Mary)))

; functions that will eventually be use in action rules to change state.
; Not complete yet.  Need to define 'contradicts'.  Need to deal with quantifiers.

(define (contradicts a b)
  (or
   (match a [(list 'not aa) (equal? aa b)] [_ #f]) 
   (match b [(list 'not bb) (equal? bb a)] [_ #f])
   ))

; remove facts that contradicts a from ground
(define (filter a ground)
  (if (contradicts a (car ground)) (filter a (cdr ground))
      (cons (car ground) (filter (cdr ground)))
))

; Add a fact a to ground, removing any fact that contradicts it
(define (assert a ground)
  (cons a (filter a ground))
)

; TODO: a disappear function that removes any fact that mentions a particular entity
(define (in a exp)
  (or (equal? a exp)
      (and (pair? exp) (or (in a (car exp)) (in a (cdr exp))))))

(define (disappear a ground)
  (if (pair? ground)
      (if (in a (car ground))
          (disappear a (cdr ground))
          (cons (car ground) (disappear a (cdr ground))))
      ground
      ))

#|(displayln 'test-disappear)
(displayln ground)
(displayln (disappear 'John ground))
(displayln (disappear 'Mary '(Mary)))
(displayln (disappear 'Mary '(onion (loves foo Mary))))
(displayln ground)
(displayln (disappear 'Mary ground))

(displayln 'tested)
|#



; A list of actions collected during find operations.
; This is maintained by side effects.
(define action-list '())
(define (reset-actions) (set! action-list '()))
(define (acti text consequence)
  ; text is a description of an action.
  ; consequence is a function that acts on a list of facts and returns a new one.
  (set! action-list (cons (cons text consequence) action-list))
  )

; repeat the exercise, using an action-list and a inconsequential consequence

(reset-actions)

; a sample rule expressing the eternal triangle
; TODO: find  better syntax for rules than the following:


(define rule (find ((list 'loves a n1)
        (find ((list 'loves b (? (lambda (e) (equal? e n1))))
               (check (not (equal? a b))
                      (lambda (facts) (acti (list a 'kills b) (lambda(ground) (disappear b ground)))))))))
  )

; TODO: I should not have to explicitly check for equality if the same variable is mentioned in two consequtive patterns

; Perform one turn.  This function creates alternatives and puts them in tha global variable 'action-list'
; In a game the player would get to choose between these alternatives.

(define (turn rule)
  (reset-actions)
  (rule ground)
  (if (null? action-list)
      (print 'the-end)
      (let ((act (random-ref action-list)))
            (displayln (car act))
             (set! ground ((cdr act) ground))
             (displayln ground)
             )
      )
  )

(define (turns count rule)
  (if ( <= count 0) '()
      (begin (turn rule) (turns ( - count 1 ) rule))
      ))


(displayln ground)
(reset-actions)
(turns 4 rule)

#| TODO: provide a better syntax for Racket predicate in a rule.
         Done?  Is check really adequate?  Does it need to be better still?
   TODO: pass in a function that collects actions in a variable.  Yes, a side effect.
         I'll use it instead of displayln, and it will accept an action and consequences.
         Or should actios be declared and contain their consequences?
   TODO: provide a nicer rule syntax.
   TODO: provide a notation for drawing conclusions
   TODO: Enable backward reasoning to find a rule that might contribute a particular conclusion.
   TODO: Introduce actors for use in games -- for exapmle, a player or a non-player character
|#