#lang racket
(require "../fix.rkt"
         "../units.rkt"
         "../syntax.rkt"
         "../tests/tests.rkt")
(provide eval)

(define-values/invoke-unit/infer
  (link monad-gc@ state@ alloc@ δ@ ev@ ev-roots@ ev-collect@))

(define (eval e) (mrun ((fix (ev-roots (ev-collect ev))) e)))
