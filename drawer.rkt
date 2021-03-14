#lang racket/gui
 
(require (lib "gl.ss" "sgl")
         (lib "gl-vectors.ss" "sgl")
)
 
 
(define (resize w h)
  (glViewport 0 0 w h)
  #t
)
 
(define (draw-opengl)
  (glClearColor 0.0 0.0 0.0 0.0)
  (glClear GL_COLOR_BUFFER_BIT)
  (glColor3d 1.0 1.0 1.0)
  
  (glMatrixMode GL_PROJECTION)
  (glLoadIdentity)
  (glOrtho 0.0 1.0 0.0 1.0 -1.0 1.0)
  (glMatrixMode GL_MODELVIEW)
  (glLoadIdentity)
 
  (glBegin GL_QUADS)
  (glColor3d 0.0 1.0 0.0)
  (glVertex3d 0.25 0.25 0.0)
  (glColor3d 1.0 0.0 0.0)
  (glVertex3d 0.75 0.25 0.0)
  (glColor3d 1.0 1.0 1.0)
  (glVertex3d 0.75 0.75 0.0)
  (glColor3d 0.0 0.0 1.0)
  (glVertex3d 0.25 0.75 0.0)
  (glEnd)
)
(define count
  (let ((c 0))
    (lambda () (set! c ( + 1 c)) c)
    )
  )

(define (environ drawer)
  #;(printf "in environ\n")
  (define my-canvas%
    (class* canvas% ()
      (inherit with-gl-context swap-gl-buffers)
      
      (define/override (on-paint)
        (printf "on-paint ~s~n" (count))
        (with-gl-context
            (lambda ()
              #;(printf "call drawer~n")
              (drawer)
              #;(printf "returned from drawer~n")
              (swap-gl-buffers)
              )
          )
        )
      
      (define/override (on-size width height)
        (with-gl-context
            (lambda ()
              (resize width height)
              )
          )
        )
      
      (super-instantiate () (style '(gl)))
      )
    )
  #;(printf "before win~n")
  (define win (new frame% (label "OpenGl Test") (min-width 600) (min-height 600)))
  #;(printf "before my-canvas~n")
  (define gl (new my-canvas% (parent win)))
  #;(printf "before show~n")
  (send win show #t)  ;  presumably this runs the on-paint method
  #;(printf "out-environ~n")
  )

#;(define win (new frame% (label "OpenGl Test") (min-width 200) (min-height 200)))


#;(define gl  (new my-canvas% (parent win)))
 
#;(send win show #t)
 
#;(environ draw-opengl)
(provide environ)

;It should be pretty easy to tweak it.

;Hope this helps,
;Laurent


;- show quoted text -

;    - show quoted text -
;    _________________________________________________
;     For list-related administrative tasks:
;     http://lists.racket-lang.org/listinfo/users


