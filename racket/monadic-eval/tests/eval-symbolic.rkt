#lang racket
(require rackunit
         "../transformers.rkt"
         "../evals/eval-symbolic.rkt"
         "../syntax.rkt"
         "../set.rkt")

(define-syntax check-eval
  (syntax-rules ()
    [(check-eval e v ...)
     (check-match (eval e)
                  (set (cons (cons v _) _) ...))]))

(check-eval (num 5) 5)
(check-eval (op1 'add1 (num 5)) 6)
(check-eval (op2 '+ (num 5) (num 11)) 16)
(check-eval (lam 'x (vbl 'x))
            (cons (lam 'x (vbl 'x)) ρ))

(check-eval (app (lam 'x (num 7)) (num 5)) 7)
(check-eval (app (lam 'x (lam '_ (vbl 'x))) (num 5))
            (cons (lam '_ (vbl 'x)) ρ))            
(check-eval (app (lam 'x (vbl 'x)) (num 5)) 5)          

(check-eval (ifz (num 0) (num 7) (num 8)) 7)
(check-eval (ifz (num 1) (num 7) (num 8)) 8)
(check-eval (ref (num 5))
            (? number?))
(check-eval (drf (ref (num 5))) 5)
(check-eval (drf (srf (ref (num 5)) (num 7))) 7)
(check-eval (op1 'add1
                 (ifz (drf (srf (ref (num 0)) (num 1)))
                      (num 43)
                      (num 42)))
            43)
(check-eval (op1 'add1
                 (ifz (drf (srf (ref (num 1)) (num 0)))
                      (num 43)
                      (num 42)))
            44)

(check-eval (op1 'add1 (ifz (sym 'n) (num 7) (num 8)))
            8
            9)
            
(check-eval (op1 'add1 (app (sym 'f) (num '7)))
            (failure))
(check-eval (lrc 'f (lam 'x
                         (ifz (vbl 'x)
                              (vbl 'x)
                              (op1 'add1
                                   (app (vbl 'f)
                                        (op2 '+ 
                                             (vbl 'x)
                                             (num -1))))))
                 (app (vbl 'f)
                      (num 5)))
            5)

(check-eval (op2 'quotient (num 1) (num 0)) (failure))
(check-eval (op2 'quotient (num 1) (sym 's)) (failure) '(quotient 1 s))
(check-eval (op2 'quotient (sym 'n) (num 1)) '(quotient n 1))
(check-eval (ifz (sym 'a)
                 (ifz (sym 'b) (num 1) (num 2))
                 (ifz (sym 'c) (num 3) (num 4)))
            1
            2
            3
            4)