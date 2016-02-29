#lang racket
(provide eval)
(require "../units/ev-unit.rkt"
         "../units/fix-unit.rkt"
	 "../units/eval-sto-unit.rkt"
	 "../units/sto-monad-unit.rkt"
	 "../units/env-sto-unit.rkt"
         "../units/delta-unit.rkt"
         "../units/err-unit.rkt")

(define-values/invoke-unit/infer
  (link ev@ δ@ eval-sto@ fix@ env-sto@ sto-monad@ err@))
