#lang racket
(provide eval)
(require "../units/sto-set-monad-unit.rkt"
         "../units/eval-sto-unit.rkt"
	 "../units/ev-bang-unit.rkt"
         "../units/delta-unit.rkt"
         "../units/sto-set-unit.rkt"
         "../units/err-unit.rkt")

(define-values/invoke-unit/infer
  (link ev!@ δ@ eval-sto@ sto-set-monad@ sto-set@ err@))
