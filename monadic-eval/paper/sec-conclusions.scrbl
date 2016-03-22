#lang scribble/manual
@(require scribble/core)

@title{Conclusions}

We have shown that a definitional interpreter written in monadic style
can express a wide variety of semantics, such as the usual concrete
semantics, collecting semantics, abstract interpretations, symbolic
execution, and several combinations thereof. 

Remarkably, we observe that our abstract interpreter implements a form
of pushdown abstraction in which calls and returns are always properly
matched in the abstract semantics.  True to the definitional style of
Reynolds, the evaluator involves no explicit mechanics to achieve this
property; it is simply inherited from the defining language.

We believe this formulation of higher-order abstract interpretation
offers a promising new foundation for making re-usable components for
the static analysis and verification of higher-order programs.

@elem[#:style (style "paragraph" '())]{Acknowledgments} We thank Sam
Tobin-Hochstadt and Dionna Glaze for several fruitful conversations
while developing the ideas in this work.

@elem[#:style (make-style "balance" '())]