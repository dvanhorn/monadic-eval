#lang scribble/acmart @acmlarge
@(require scriblib/figure 
          scribble/manual 
          scriblib/footnote
          scribble/eval
          "evals.rkt"
          "bib.rkt")

@title[#:tag "s:interp"]{A Definitional Interpreter}

@;{
\begin{wrapfigure}{R}{0.5\textwidth} %{{{ f:syntax
  \begin{mdframed}
    \begin{alignat*}{4}
      e ∈ &&\mathrel{}   exp ⩴ &\mathrel{} 𝔥⸨(vbl⸩\ x𝔥⸨)⸩         &\hspace{3em} [⦑\emph{variable}⦒]
      \\[\mathgobble]     &&\mathrel{}       ∣ &\mathrel{} 𝔥⸨(num⸩\ n𝔥⸨)⸩         &\hspace{3em} [⦑\emph{number}⦒]
      \\[\mathgobble]     &&\mathrel{}       ∣ &\mathrel{} 𝔥⸨(if0⸩\ e\ e\ e𝔥⸨)⸩   &\hspace{3em} [⦑\emph{conditional}⦒]
      \\[\mathgobble]     &&\mathrel{}       ∣ &\mathrel{} 𝔥⸨(op2⸩\ b\ e\ e𝔥⸨)⸩   &\hspace{3em} [⦑\emph{binary op}⦒]
      \\[\mathgobble]     &&\mathrel{}       ∣ &\mathrel{} 𝔥⸨(app⸩\ e\ e𝔥⸨)⸩      &\hspace{3em} [⦑\emph{application}⦒]
      \\[\mathgobble]     &&\mathrel{}       ∣ &\mathrel{} 𝔥⸨(rec⸩\ x\ ℓ\ e𝔥⸨)⸩   &\hspace{3em} [⦑\emph{letrec}⦒]
      \\[\mathgobble]     &&\mathrel{}       ∣ &\mathrel{} ℓ                     &\hspace{3em} [⦑\emph{lambda}⦒]
      \\[\mathgobble]ℓ ∈ &&\mathrel{}   lam ⩴ &\mathrel{} 𝔥⸨(lam⸩\ x\ e𝔥⸨)⸩      &\hspace{3em} [⦑\emph{function defn}⦒]
      \\[\mathgobble] x ∈ &&\mathrel{}   var ≔ &\mathrel{} ❴𝔥⸨x⸩, 𝔥⸨y⸩, …❵        &\hspace{3em} [⦑\emph{variable names}⦒]
      %\\[\mathgobble] u ∈ &&\mathrel{}  unop ≔ &\mathrel{} ❴𝔥⸨add1⸩, …❵           &\hspace{3em} [⦑\emph{unary prim}⦒]
      \\[\mathgobble] b ∈ &&\mathrel{} binop ≔ &\mathrel{} ❴𝔥⸨+⸩, 𝔥⸨-⸩, …❵        &\hspace{3em} [⦑\emph{binary prim}⦒]
    \end{alignat*}
    \captionskip{Programming Language Syntax}
    \label{f:syntax}
  \end{mdframed}
\end{wrapfigure} %}}}
}

@figure["f:syntax" "Programming Language Syntax" "FIXME"]

We begin by constructing a definitional interpreter for a small but
representative higher-order, functional language.  The abstract syntax
of the language is defined in @Figure-ref{f:syntax}; it includes
variables, numbers, binary operations on numbers, conditionals,
@racket[letrec] expressions, functions and applications.

The interpreter for the language is defined in
@Figure-ref{f:interpreter}. At first glance, it has many conventional
aspects: it is compositionally defined by structural recursion on the
syntax of expressions; it represents function values as a closure data
structure which pairs the lambda term with the evaluation environment;
it is structured monadically and uses monad operations to interact
with the environment and store; and it relies on a helper function
@racket[δ] to interpret primitive operations.

There are a few superficial aspects that deserve a quick note:
environments @racket[ρ] are finite maps and the syntax @racket[(ρ x)]
denotes @math{ρ(x)} while @racket[(ρ x a)] denotes @math{ρ[x↦a]}.  For
simplicity, recursive function definitions (@racket[rec]) are assumed
to be syntactic values.  The @racket[do]-notation is just shorthand for
@racket[bind], as usual:
@racketblock[
  (do x ← e . r) ≡ (bind e (λ (x) (do . r)))
       (do e . r) ≡ (bind e (λ (_) (do . r)))
   (do x ≔ e . r) ≡ (let ((x e)) (do . r))
           (do b) ≡ b
]
Finally, there are two unconventional aspects worth noting.

First, the interpreter is written in an @emph{open recursive style};
the evaluator does not call itself recursively, instead it takes as an
argument a function @racket[ev]—shadowing the name of the function
@racket[ev] being defined—and @racket[ev] (the argument) is called
instead of self-recursion.  This is a standard encoding for recursive
functions in a setting without recursive binding.  It is up to an
external function, such as the Y-combinator, to close the recursive
loop.  This open recursive form is crucial because it allows
intercepting recursive calls to perform “deep” instrumentation of the
interpreter.

Second, the code is clearly @emph{incomplete}.  There are a number of free
variables, typeset as italics, which implement the following:

@itemlist[
@item{The underlying monad of the interpreter: @racket[_return] and @racket[_bind];}
@item{An interpretation of primitives: @racket[_δ] and @racket[_zero?];}
@item{Environment operations: @racket[_ask-env] for retrieving the
environment and @racket[_local-env] for installing an environment;}
@item{Store operations: @racket[_ext] for updating the store, and @racket[_find] for
dereferencing locations; and}
@item{An operation for @racket[_alloc]ating new store locations.}
]

Going forward, we make frequent use of definitions involving free
variables, and we call such a collection of such definitions a
@emph{component}. We assume components can be named (in this case,
we've named the component @racket[ev@], indicated by the box in the
upper-right corner) and linked together to eliminate free
variables.@note{We use Racket @emph{units} @~cite{local:flatt-pldi98}
to model components in our implementation.}

@figure["f:interpreter" "The Extensible Definitional Interpreter"]{
@filebox[@racket[ev@]]{
@racketblock[
(define ((ev ev) e)
  (match e
    [(num n)
     (_return n)]
    [(vbl x)
     (do ρ ← _ask-env
         (_find (ρ x)))]    
    [(if0 e₀ e₁ e₂)
     (do v  ← (ev e₀)  z? ← (_zero? v)
         (ev (if z? e₁ e₂)))]
    [(op2 o e₀ e₁)
     (do v₀ ← (ev e₀)  v₁ ← (ev e₁)
         (_δ o v₀ v₁))]
    [(rec f l e)
     (do ρ  ← ask-env  a  ← (_alloc f)
         ρ′ ≔ (ρ f a)
         (_ext a (cons l ρ′))
         (_local-env ρ′ (ev e)))]
    [(lam x e₀)
     (do ρ ← _ask-env
         (_return (cons (lam x e₀) ρ)))]
    [(app e₀ e₁)
     (do (cons (lam x e₂) ρ) ← (ev e₀)
          v₁ ← (ev e₁)
          a  ← (_alloc x)
          (_ext a v₁)
          (_local-env (ρ x a) (ev e₂)))]))
]}}

Next we examine a set of components which complete the definitional
interpreter, shown in @Figure-ref{f:concrete-components}. The first
component @racket[monad@] uses a macro @racket[define-monad] which
generates a set of bindings based on a monad transformer stack.  We
use a failure monad to model divide-by-zero errors, a state monad to
model the store, and a reader monad to model the environment.  The
@racket[define-monad] form generates bindings for @racket[return],
@racket[bind], @racket[ask-env], @racket[local-env],
@racket[get-store] and @racket[update-store]; their definitions are
standard @~cite{dvanhorn:Liang1995Monad}.

We also define @racket[run] for running monadic computations, starting with the empty
environment and store @racket[∅]:
@racketblock[
(define (mrun m)
  (run-StateT ∅ (run-ReaderT ∅ m)))
]
While the @racket[define-monad] form is hiding some details, this
component could have equivalently been written out explicitly. For
example, @racket[return] and @racket[bind] can be defined as:
@racketblock[
(define (((return a) r) s) (cons a s))
(define (((bind ma f) r) s)
  (match ((ma r) s)
    [(cons a s′) (((f a) r) s′)]
    ['failure 'failure]))
]
So far our use of monad transformers is as a mere convenience, however
the monad abstraction will become essential for easily deriving new
analyses later on.

@figure["f:concrete-components" "Components for Definitional Interpreters"]{
@filebox[@racket[monad@]]{
@racketblock[
(define-monad (ReaderT (FailT (StateT ID))))]}
@filebox[@racket[δ@]]{
@racketblock[
(define (δ o n₀ n₁)
  (match o
    ['+ (return (+ n₀ n₁))]
    ['- (return (- n₀ n₁))]
    ['* (return (* n₀ n₁))]
    ['/ (if (= 0 n₁) fail (return (/ n₀ n₁)))]))
(define (zero? v) (return (= 0 v)))]}
@filebox[@racket[store@]]{
@racketblock[
(define (find a)  (do σ ← get-store
                      (return (σ a))))
(define (ext a v) (update-store (λ (σ) (σ a v))))]}
@filebox[@racket[alloc@]]{
@racketblock[
(define (alloc x) (do σ ← get-store
                      (return (size σ))))]}
}

The @racket[δ@] component defines the interpretation of primitives,
which is given in terms of the underlying monad.  The @racket[alloc@]
component provides a definition of @racket[alloc], which fetches the
store and uses its size to return a fresh address, assuming the
invariant @racket[(∈ a σ)] @math{⇔} @racket[(< a (size σ))].  The
@racket[alloc] function takes a single argument, which is the name of
the variable whose binding is being allocated.  For the time being, it
is ignored, but will become relevant when abstracting closures
(@secref{s:abstracting-closures}).  The @racket[store@] component
defines @racket[find] and @racket[ext] for finding and extending
values in the store.

@figure["f:trace" "Trace Collecting Semantics"]{
@filebox[@racket[trace-monad@]]{
@racketblock[
(define-monad (ReaderT (FailT (StateT (WriterT List ID)))))
]}
@filebox[@racket[ev-tell@]]{
@racketblock[
(define (((ev-tell ev₀) ev) e)
  (do ρ ← ask-env  σ ← get-store
      (tell (list e ρ σ))
      ((ev₀ ev) e)))
]}}

The only remaining pieces of the puzzle are a fixed-point combinator and the
main entry-point for the interpreter, which are straightforward to define:
@racketblock[
(define ((fix f) x) ((f (fix f)) x))
(define (eval e) (mrun ((fix ev) e)))
]

By taking advantage of Racket's languages-as-libraries features
@~cite{dvanhorn:TobinHochstadt2011Languages}, we construct REPLs for
interacting with this interpreter.  Here are a few evaluation examples
in a succinct concrete syntax:

@interaction[#:eval the-pure-eval
@code:comment{Closure over the empty environment paired with the empty store.}
(λ (x) x)

@code:comment{Closure over a non-empty environment and store.}
((λ (x) (λ (y) x)) 4)

@code:comment{Primitive operations work as expected.}
(* (+ 3 4) 9)

@code:comment{Divide-by-zero errors result in failures.}
(quotient 5 (- 3 3))   
]


