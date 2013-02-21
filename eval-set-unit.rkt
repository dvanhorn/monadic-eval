#lang racket/unit
(require racket/match
	 racket/set
         "signatures.rkt")

(import ev^)
(export eval^ unit^ unit-ans^ unit-vals^ bind^ fail^)

(define (eval e)
  ((ev e (hash)) (hash)))

(define (rec e r) (ev e r))
(define ((unit v) s) (set (cons v s)))
(define ((fail) s) (set (cons 'fail s)))
(define ((bind a f) s)
  (for*/fold ([rs (set)])
    ([ret (a s)])
    (set-union rs
	       (match ret
                 [(cons 'fail s) (set (cons 'fail s))]
		 [(cons v s)
		  ((f v) s)]))))

(define ((unit-vals vs) s)
  (unit-anss (for/set ([v vs])
               (cons v s))))

(define (unit-ans v s)
  (unit-anss (set (cons v s))))

(define (unit-anss anss) anss)