#lang racket
(require "../fix.rkt"
         "../units.rkt")
(provide eval)

(define-values/invoke-unit/infer
  (link monad-grabbag@ state-crush@ alloc-0cfa@ δ-pres@
        ev-dead@ ev-gc@ ev-compile@ ev-cache@ ev-collect@
        eval-coind@ eval-dead@))

(define (eval e)
  (mrun ((eval-coind (eval-dead (fix (ev-cache (ev-dead (ev-collect ev)))))) e)))
