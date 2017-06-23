#lang scribble/acmart @acmlarge

@title[#:tag "s:conclusion"]{Conclusions}

We have shown that the AAM methodology can be adapted to definitional
interpreters written in monadic style.  Doing so captures a wide
variety of semantics, such as the usual concrete semantics, collecting
semantics, and various abstract interpretations.  Beyond recreating
existing techniques from the literature such as store-widening and
abstract garbage collection, we can also design novel abstractions and
capture disparate forms of program analysis such as symbolic
execution.  Further, our approach enables the novel combination of
these techniques.

To our surprise, the definitional abstract interpreter we obtained
implements a form of pushdown control flow abstraction in which calls
and returns are always properly matched in the abstract semantics.
True to the definitional style of Reynolds, the evaluator involves no
explicit mechanics to achieve this property; it is simply inherited
from the metalanguage.

We believe this formulation of abstract interpretation offers a
promising new foundation towards re-usable components for the static
analysis and verification of higher-order programs.  Moreover, we
believe the definitional abstract interpreter approach to be a
fruitful new perspective on an old topic.  We are left wondering: what
else can be profitably inherited from the metalanguage of an abstract
interpreter?