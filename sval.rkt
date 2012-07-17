#lang racket
(provide eval eval@ (struct-out both-ans))
(require "ev-sig.rkt"
         "eval-sig.rkt"
         "ev-monad-sig.rkt"
         "symbolic-monad-sig.rkt"
         "ev-symbolic-unit.rkt"
         "sto-explicit-unit.rkt"
         "delta-unit.rkt")

(struct both-ans (left right) #:transparent)

(define-unit eval@
  (import ev^ δ^ sto-monad^)
  (export eval^ return^ ev-monad^ symbolic-monad^)
  
  (define (symbolic? x) (or (symbol? x) (pair? x)))
  
  (define ((both v1 v2) s)
    (both-ans (cons v1 s) (cons v2 s)))
  
  (define (symbolic-apply f v)
    (return `(,f ,v)))
  
  (define (eval e) ((ev e (hash)) (hash)))
  (define (rec e r) (ev e r))
  (define ((return v) s) (cons v s))
  (define ((fail) s) (cons 'fail s))
  (define ((bind a f) s)
    (let loop ([res (a s)])
      (match res
        [(both-ans a1 a2)
         (both-ans (loop a1) (loop a2))]
        [(cons 'fail s) (cons 'fail s)]     
        [(cons v s)
         ((f v) s)]))))


(define-values/invoke-unit/infer
  (link eval@ ev-symbolic@ symbolic-delta@ sto-explicit@))