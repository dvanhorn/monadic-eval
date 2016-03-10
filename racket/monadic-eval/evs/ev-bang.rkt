#lang racket
(require "../signatures.rkt"
         "ev.rkt"
         "ev-ref.rkt")
(provide ev!@)

;; We can tie together new open evs as follows:

(define-unit ev!@
  (import monad^ menv^ mstore^ δ^ alloc^)
  (export ev!^)

  (define-values/invoke-unit ev@
    (import monad^ menv^ mstore^ δ^ alloc^)
    (export ev^))
  (define-values/invoke-unit ev-ref@
    (import monad^ menv^ mstore^ δ^ alloc^)
    (export ev-ref^))

  (define (ev! ev-fix) ((ev-ref ev) ev-fix)))