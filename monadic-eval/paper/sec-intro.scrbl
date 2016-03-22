#lang scribble/manual
@(require "bib.rkt")

@title{Introduction}

In his landmark paper, @emph{Definitional interpreters for
higher-order languages}@~cite[reynolds72], Reynolds first observed
that when a language is defined by way of an interpreter, it is
possible for the defined language to inherit semantic characteristics
of the defining language of the interpreter.  For example, it is easy
to write a compositional evaluator that defines a call-by-value
language if the defining language is call-by-value, but defines a
call-by-name language if the defining language is call-by-name.

In this paper, we make the following two observations:

@itemlist[#:style 'ordered

@item{Definitional interpreters, written in monadic style,
can simultaneously define a language's semantics as well as
safe approximations of those semantics.}

@item{These definitional @emph{abstract} interpreters can inherit
characteristics of the defining language.  In particular, we show that
the abstract interpreter inherits the call and return matching
property of the defining language and therefore realizes an abstract
intpretation in the pushown style of analyses@~cite[cfa2-diss
pdcfa-sfp10].}

]

A common problem of past approaches to the control flow analysis of
functional languages is the inability to properly match a function
call with its return in the abstract semantics, leading to infeasible
program (abstract) executions in which a call is made from one point
in the program, but control returns to another.  The CFA2 analysis of
Vardoulakis and Shivers@~cite[cfa2-lmcs] was the first approach that
overcame this shortcoming.  In essence, this kind of analysis can be
viewed as replacing the traditional finite automata abstractions of
programs with pushdown automata@~cite[pdcfa-sfp10].

In this paper we investigate the use of definitional interpreters as
the basis for abstract interpretation of higher-order languages.  We
show that a definitional interpreter---a compositional evaluation
function---written in a monadic and componential style can express a
wide variety of concrete and abstract interpretations.  