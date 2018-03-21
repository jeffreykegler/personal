<!-- -->
<div style="display:none">pandoc -f markdown -t html -o timeline.html timeline.md</div>
<div style="line-height:1.6; font-size:3em; text-align:center">
Parsing: an expanding timeline</div>
<div style="line-height:1.6; font-size:2em; text-align:center">
Jeffrey Kegler</div>

# The fourth century BCE: Pannini's description of Sanskrit

In India, Pannini creates
a sophisticated description of the Sanskrit language,
exact and complete, and including pronunciation.
Sanskrit
could be recreated using nothing but Pannini's grammar.
Pannini's grammar is probably the first formal system of any kind, predating Euclid.
Even today, nothing like it exists for any other natural language
of comparable size or corpus.
Pannini is the object of serious study today.
But in the 1940's and 1950's Pannini is almost unknown in the West.
Pannini's work remains under-studied.
It will have no direct effect on the other events in this timeline.

# 1960: Markov's chains

Andrei Markov introduces his "chains" --
a set of states with transitions
between them.
Markov uses his chains, not for parsing,
but for solving problems in probability.
<!--
"Extension of the law of large numbers to dependent quantities"
(in Russian).
-->

# 1943: Post's rewriting system

Emil Post defines and studies a formal rewriting system using
productions.
With this, the process of rediscovering Pannini in the West begins.

# 1945: Turing discovers stacks

Alan Turing discovers the stack as part of his design of
the ACE machine.
This is important in parsing
because recursive parsing requires stacks.
The importance of Turing's discovery is not noticed at the time
and stacks will be re-discovered many times over the next two decades.
<!--
Carpenter, B. E.; Doran, R. W. (January 1977). "The other Turing machine". The Computer Journal. 20 (3): 269–279.
-->

# 1948: Shannon repurposes Markov's chains

Claude Shannon publishes the foundation paper of information theory.
<!--
"A Mathematical Theory of Communication"
-->
Andrey Markov's finite state processes are used heavily.
In this paper,
Shannon makes an attempt to model English using Markov chains.
<!--
pp. 4-6.
-->
# 1952: Grace Hopper use the term "compiler"

Grace Hopper writes a linker-loader.
[She calls it a
"compiler"](https://en.wikipedia.org/wiki/History_of_compiler_construction#First_compilers").
Hopper seems to be the first person to use this term for a computer program.

# Term: "compiler"

Hopper used the term
"compiler" in the meaning it had at the time:
"something or someone that brings other things together".
Since Hopper the term has acquired a very specialized meaning
in the computer field, so that we would not call Hopper's program
a "compiler" today.

As an aside,
whatever it is called,
Hopper's program was a major achievement,
both in terms of insight and execution.
Hopper's reputation is well-deserved.

# 1954: The FORTRAN project begins

At IBM, a team under John Backus begins working
on the language which will be called FORTRAN.

# Term: "compiler"

As of 1954,
the term "compiler" was still being used in Hopper's looser sense,
instead of its modern, specialized, one.
In particular, there was no implication that the output of a "compiler"
is ready for execution by a computer.
<!-- "http://www.softwarepreservation.org/projects/FORTRAN/paper/Backus-ProgrammingInAmerica-1976.pdf
pp. 133-134
-->
The output of one 1954 "compiler",
for example, produced relative addresses,
which needed to be translated by hand before a machine can execute them.

# 1955: Noam Chomsky starts teaching at MIT

Noam Chomsky is awarded a Ph.D. in linguistics and accepts a teaching post at MIT.
MIT does not have a linguistics department and
Chomsky, in his linguistics course, is free to teach his own approach,
highly original and very mathematical.

# 1956

Chomsky publishes the paper which
is usually considered the foundation of Western formal language theory.
<!--
"Three models for the description of language"
-->
Chomsky demolishes the idea that natural language grammar
can be modeled using only Markov chains.

Instead,
the paper advocates a natural language approach that uses
three layers:

* a bottom layer, using Markov chains;
* a middle layer, using context-free grammars and
context-sensitive grammars; and
* a top layer, which maps or "transforms"
the output of the middle layer.

Chomsky's approach will inspire
the structure of modern parsers.
Chomsky's bottom layer becomes the modern compiler's
lexical phase.
His middle layer becomes the syntactic phase of
modern compilers.
And his top layer inspires the
AST transformation phase of modern parsers.

For finite state processes, Chomsky acknowledges Markov.
The other layers seem to be Chomsky's own formulations --
Chomsky does not cite Post's work.

# Term: "Parsing"

Chomsky is a turning point, so much so that
it settles the meaning of many of the terms we
are using.
"Parsing", for our purposes,
is transforming a string of symbols into
a structure.
Typically this structure is a parse tree.

# 1957: Kleene's regular expressions

Steven Kleene discovers regular expressions,
a very handy notation for Markov chains.
It will turn out that the mathematical
objects being studied as
finite state automata
are equivalent to Markov chains.
Also equivalent are some of the objects being studied as
neural nets.
And therefore regular expressions are equivalent
to all of them.

# 1957: Chomsky publishes "Syntactic Structures"

Noam Chomsky publishes
*Syntactic Structures*,
one of the most influential books of all time.
The orthodoxy in 1957 is structural linguistics
which argues, with Sherlock Holmes, that
"it is a capital mistake to theorize in advance of the facts".
Structuralists start with the utterances in a language,
and build upward.

But Chomsky claims that without a theory there
are no facts: there is only noise.
The Chomskyan approach is to start with a grammar, and use the corpus of
the language to check its accuracy.
Chomsky's approach will soon come to dominate linguistics.

# 1957: FORTRAN released

Backus's team makes the first FORTRAN compiler
available to IBM customers.
FORTRAN is the first high-level language
that will find widespread implementation.
As of this writing,
it is the oldest language that survives in practical use.
FORTRAN is a line-by-line language
and its parsing is pre-Chomskyan and hackish.

# 1958: LISP released

John McCarthy's LISP appears.
LISP goes beyond the line-by-line syntax --
it is recursively structured.
But the LISP interpreter does not find the
recursive structure:
the programmer must explicitly
indicate the structure herself,
using parentheses.

# 1959: Backus's notation

Backus discovers a new notation to describe
the IAL language (aka ALGOL).
Backus's notation is influenced by his study of Post --
he seems not to have read Chomsky until later.
<!-- http://archive.computerhistory.org/resources/text/Oral_History/Backus_John/Backus_John_1.oral_history.2006.102657970.pdf
p. 25 -->

# 1960: BNF

Peter Naur
improves the Backus notation
and uses it to describe ALGOL 60.
The improved notation will become known as Backus-Naur Form (BNF).

# 1960: The ALGOL report

The ALGOL 60 report
specifies, for the first time, a block structured
language.
ALGOL 60 is recursively structured but the structure is
implicit -- newlines are not semantically significant,
and parentheses indicate syntax only in a few specific cases.
The ALGOL compiler will have to find the structure.
It is a case of 1960's optimism at its best.
As the ALGOL committee is well aware, a parsing
algorithm capable
of handling ALGOL 60 does not yet exist.
But the risk they are taking will soon pay off.

# The Quest

With the ALGOL 60 report, 
a quest begins which continues to this day:
the search for a parser that is

* efficient,
* practical,
* syntax-driven, and
* general.

# Term: "syntax-driven"

For our purposes,
a parser is "syntax-driven" if it will parse
from grammars written in BNF.
You would certainly *hope* that
you could adequately specify
a parser by specifying its syntax.

# Term: "general"

A general parser is a parser that will parse
*any* grammar that can be written in BNF.
This is a very useful property -- it makes it
easy for a grammar-writer to know that her grammar
will parse.
It also makes it easy to auto-generate grammars,
knowing that they will successfully parse.
This opens the way to second-order languages --
languages which specify other languages.

# 1960: Gleenie's compiler-compiler

A.E. Gleenie publishes his description of a compiler-compiler.
<!-- http://www.chilton-computing.org.uk/acl/literature/reports/p024.htm -->
Glennie's "universal compiler" is more of a methodology than
an implementation -- the compilers must be written by hand.
Glennie credits both Chomsky and Backus, and observes that the two
notations are "related".
He also mentions Post's productions.
Glennie may have been the first to use BNF as a description of a
*procedure*
instead of as the description of a
*Chomsky grammar*.
Glennie points out that the distinction is "important".

# Chomskyan BNF and procedural BNF

BNF, when used as a Chomsky grammar, describes a set of strings,
and does
*not*
describe how to parse strings according to the grammar.
BNF notation, if used to describe a procedure, is a set of instructions, to be
tried in some order, and used to process a string.
Procedural BNF describes a procedure first, and a language only indirectly.

Both procedural and Chomskyan BNF describe languages,
but usually
*not the same*
language.
This is an important point, and one which will be overlooked
many times in the years to come.

The pre-Chomskyan approach,
using procedural BNF,
is far more natural
to someone trained as a computer programmer.
The parsing problem appears to the programmer in the form of
strings to be parsed,
exactly the starting point of procedural BNF
and pre-Chomsky parsing.

Even when the Chomskyan approach is pointed out,
it does not at first seem very attractive.
With the pre-Chomskyan approach,
the examples of the language
more or less naturally lead to a parser.
In the Chomskyan approach
the programmer has to search for
an algorithm to parse strings according to his grammar --
and the search for good algorithms to parse
Chomskyan grammars has proved surprisingly
long and difficult.
Handling
semantics is more natural with a Chomksyan approach.
But, using captures, semantics
can be added to a pre-Chomskyan parser
and, with practice, this seems natural enough.

Despite the naturalness of the pre-Chomskyan approach
to parsing, we will find that the first fully-described
automated parsers are Chomskyan.
This is a testimony to Chomsky's influence at the time.
We will also see that Chomskyan parsers
have been dominant ever since.

# 1961

In January,
Ned Irons publishes a paper describing his ALGOL 60
parser.
It is the first paper to fully describe any parser.
The Irons algorithm is Chomskyan and top-down
with a bottom-up "left corner" element --
it is what now would be called a "left corner" parser.
<!--
Among those who state that Irons 1961 parser is what
is now called "left-corner" is Knuth ("Top-down syntax analysis", p. 109).
-->

The Irons algorithm
is general,
meaning that it can parse anything written in BNF.
It is syntax-driven (aka declarative),
meaning that the parser is
actually created from the BNF --
the parser does not need
to be hand-written.

# Terms: "Top-down"

A top-down parser, starts from the top BNF production
and works down.
It derives child productions, starting with their parent,
and eventually reaching input tokens.

# Terms: "Bottom-up"

A bottom-up parser, starts from the input and
and works up, finding productions based on input
tokens, then finding other production based on their
children.

# Misconception: "Top-down" vs. "bottom-up"

A common, and important, misconception is that every
parser is either top-down or bottom-up.
A related misconception is that even parsers that are
not clearly one or the other can always be usefully described
in terms of their top-down and bottom-up components.

As we saw, the Irons 1961 parser is not simply top-down or
bottom-up, though arguably describing it in terms of
top-down and bottom-up components is helpful.
But for other parsing algorithms, top-down vs. bottom-up
classification is a pointless pedantry --
the classification can be done, but tells you nothing about the actual
behavior of the parser.

# Terms: "Synthetic attribute"

Irons 1961 also introduces synthetic attributes:
the parse creates a tree,
which is evaluated bottom-up.
Each node is evaluated using attributes
"synthesized" from its child nodes.
<!--
Irons is credited with the discovery of synthetic attributes
by Knuth ("Genesis of Attibute Grammars").
-->

Pedantically, synthetic attributes are not a parsing concept --
they are way of doing semantics.
But almost nobody parses without intending to
apply some kind of semantics,
and feedback from new semantic concepts has had major effects
on the development of parsing.
Synthetic attributes will be important.

# 1961: Lucas discovers recursive descent

Peter Lucas publishes the first
description of a purely top-down parser.
This can be considered to be recursive descent,
though in Lucas's
paper the algorithm has a
syntax-driven implementation, useable only for
a restricted class of grammars.
Today we think of recursive descent as a methodology for
writing parsers by hand.
Hand-coded approaches became more popular
in the 1960's due to three factors:

* Memory and CPU were both extremely limited.
Hand-coding paid off, even when the gains were small.
* Non-hand coded top-down parsing,
of the kind Lucas's syntax-driven
approach allowed, is a very weak parsing technique.
It was (and still is) often necessary
to go beyond its limits.
* Top-down parsing is intuitive -- it essentially means calling
subroutines.
It therefore requires little or
no knowledge of parsing theory.
This makes it a good fit for hand-coding.

# 1963

L. Schmidt, Howard Metcalf, and Val Schorre present papers
on syntax-directed compilers at a Denver conference.
<!-- Schorre 1964, p. D1.3-1 -->

# 1964

Schorre publishes a paper on the Meta II
"compiler writing language",
summarizing the papers of the 1963 conference.
Schorre cites both Backus and Chomsky as sources
for Meta II's notation.
Schorre notes
that his parser
is "entirely different" from that of Irons 1961 --
in fact it is pre-Chomskyan.
Meta II is a template, rather
than something that readers can use,
but in principle it can be turned
into a fully automated compiler-compiler.
<!-- Schorre 1964, p. D1.3-1
http://ibm-1401.info/Meta-II-schorre.pdf
-->

# 1965

Don Knuth discovers LR parsing.
The LR algorithm is deterministic,
Chomskyan and bottom-up.
Knuth is primarily interested
in the mathematics,
and
the parsing algorithm he gives
is not practical.
He leaves development of practical LR parsing
algorithms as an "open question"
for "future research".
<!--
P. 637
-->

# 1968

When Knuth discovered the LR grammars,
he announced them to the world
with a full-blown mathematical description.
The top-down grammars, which arose historically,
lack such a description.
In 1968,
Lewis and Stearns fill that gap
by defining the LL(k) grammars.
<!--
They are credited in Rosencrantz and Stearns (1970)
and Aho and Ullman, p. 368.
-->


# Terms: LL and LR

When LL is added to the vocabulary of parsing,
the meaning of "LR" shifts slightly.
In 1965 Knuth meant LR to mean
"translatable from left to right".
<!--
Knuth 1965, p. 610.
See on p. 611
"corresponds with the intuitive notion of translation
from left to right looking k characters ahead".
-->
LL means
"scan from the left, using left reductions"
and LR acquires its current meaning of
scan from the left, using right reductions".
<!--
Knuth, "Top-down syntax analysis", p. 102.
-->

# 1968

Jay Earley discovers the algorithm named after him.
Like the Irons algorithm,
Earley's algorithm is Chomskyan, syntax-driven and fully general.
Unlike the Irons algorithm, it does not backtrack.
Earley's algorithm is both top-down and bottom-up at once --
it uses dynamic programming and keeps track of the parse
in tables.
Earley's approach makes a lot of sense
and looks very promising indeed,
but there are three serious issues:

* First, there is a bug in the handling of zero-length rules.
* Second, it is quadratic for right recursions.
* Third, the bookkeeping required to set up the tables is,
by the standards of 1968 hardware, daunting.

# 1968

Knuth publishes a paper on a concept he had been working
for the previous few years:
attribute grammars.
<!--
Knuth, "Semantics of context-free languages", 1968.
-->
Irons' synthetic attributes had always been inadequate for
many problems, and had been supplemented by side effects
or state variables.
Knuth adds inherited attributes,
and discovers attribute grammars.

# Term: "Inherited attributes"

Recall that a node in parse gets its synthetic attributes
from its parents.
Inherited attributes are attibutes a node gets from its
parents.
Of course, this creates potential circularities,
but inherited attributes are powerful and,
with care, the circularities can be dealt with.

# Term: "Attribute grammar"

An attribute grammar is a grammar whose node may have
both inherited and synthetic attributes.

# 1969
Frank DeRemer describes a new variant of Knuth's LR
parsing.
DeRemer's LALR algorithm requires only
a stack and a state table of quite
manageable size.
LALR looks practical.

# 1969
Ken Thompson writes the "ed" editor as one of the first components
of UNIX.
At this point, regular expressions are an esoteric mathematical formalism.
Through the "ed" editor and its descendants,
regular expressions will become
an everyday
part of the working programmer's toolkit.

# Recognizers
In comparing algorithms, it can be important to keep in mind whether
they are recognizers or parsers.
A
*recognizer*
is a program which takes a string and produces a "yes"
or "no" according to whether a string is in part of a language.
Regular expressions are typically used as recognizers.
A
*parser*
is a program which takes a string and produces a tree reflecting
its structure according to a grammar.
The algorithm for a compiler clearly must be a parser, not a recognizer.
Recognizers can be, to some extent,
used as parsers by introducing captures.

# 1972
Alfred Aho and Jeffrey Ullman
publish a two volume textbook summarizing the theory
of parsing.
This book is still important.
It is also distressingly up-to-date --
progress in parsing theory slowed dramatically
after 1972.
Aho and Ullman describe
a straightforward fix to the zero-length rule bug in Earley's original algorithm.
Unfortunately, this fix involves adding even more bookkeeping to Earley's.

# 1972
Under the names TDPL and GTDPL,
Aho and Ullman investigate
the non-Chomksyan parsers in
the Schorre lineage.
They note that
"it can be quite difficult to determine
what language is defined by a TDPL parser".
That is,
GTDPL parsers do whatever they do,
and that whatever is something
the programmer in general will not be able to describe.
The best a programmer can usually do
is to create a test suite and fiddle with the GTDPL description
until it passes.
Correctness cannot be established in any stronger sense.
GTDPL is an extreme form of
the old joke that "the code is the documentation" --
with GTDPL nothing
documents the language of the parser,
not even the code.

GTDPL's obscurity buys nothing in the way of additional parsing
power.
Like all non-Chomskyan parsers,
GTDPL is basically a extremely powerful recognizer.
Pressed into service as a parser, it is comparatively weak.
As a parser, GTDPL
is essentially equivalent to Lucas's 1961 syntax-driven
algorithm,
which was in turn a restricted form of recursive descent.

At or around this time,
rumor has it
that the main line of development for GTDPL parsers
is classified secret by the US government.
<!-- http://www.wikiwand.com/en/Talk:Metacompiler/Archive_2 -->
GTDPL parsers have the property that even small changes
in GTDPL parsers can be very labor-intensive.
For some government contractors,
GTDPL parsing provides steady work for years to come.
Public interest in GTDPL fades.

# 1975
Bell Labs converts its C compiler from hand-written recursive
descent to DeRemer's LALR algorithm.

# 1977
The first "Dragon book" comes out.
This soon-to-be classic textbook is nicknamed after
the drawing on the front cover,
in which a knight takes on a dragon.
Emblazoned on the knight's lance are the letters "LALR".
From here on out,
to speak lightly of LALR will be to besmirch the escutcheon
of parsing theory.

# 1979
Bell Laboratories releases Version 7 UNIX.
V7 includes what is, by far,
the most comprehensive, useable and easily available
compiler writing toolkit yet developed.

# 1979
Part of the V7 toolkit is Yet Another Compiler Compiler (YACC).
YACC is LALR-powered.
Despite its name, YACC is the first compiler-compiler
in the modern sense.
For some useful languages, the process of going from
Chomskyan specification to executable is fully automated.
Most practical languages,
including
the C language
and YACC's own input language,
still require manual hackery.
Nonetheless,
after two decades of research,
it seems that the parsing problem is solved.

# 1987
Larry Wall introduces Perl 1.
Perl embraces complexity like no previous language.
Larry uses YACC and LALR very aggressively --
to my knowledge more aggressively than anyone before
or since.

# 1991
Joop Leo discovers a way of speeding up right
recursions in Earley's algorithm.
Leo's algorithm
is linear for just about every unambiguous grammar of
practical interest, and many ambiguous ones as well.
In 1991 hardware is six orders of magnitude faster
than 1968 hardware, so that the
issue of bookkeeping overhead had receded
in importance.
This is a major discovery.
When it comes to speed,
the game has changed in favor of the Earley algorithm.

But Earley parsing is almost forgotten.
Twenty years will pass
before anyone writes a practical
implementation of Leo's algorithm.

# The 1990's
Earley's is forgotten.
So everyone in LALR-land is content, right?
Wrong. Far from it, in fact.
Users of LALR are making unpleasant discoveries.
While LALR automatically
generates their parsers,
debugging them
is so hard they could just as easily
write the parser by hand.
Once debugged, their LALR parsers are fast for correct inputs.
But almost all they tell the users about incorrect inputs
is that they are incorrect.
In Larry's words, LALR is "fast but stupid".

# 1992

Two papers introduce combinators.
<!--
Frost, "Constructing programs as executable attribute grammars".
-->
The one by Hutton focuses on combinator parsing
<!--
Hutton, "Higher order parsing".
-->
Combinator parsing is not actually a parsing innovation --
it's the decades-old recursive descent
wrapped up in an attribute grammar.
But it is an exciting new development in semantics:
developments in functional programming are showing the
potential value of
attribute grammars.

# 2000

Larry Wall decides on a radical reimplementation
of Perl -- Perl 6.
Larry does not even consider using LALR again.

# 2002

John Aycock and R. Nigel Horspool
publish their attempt at a fast, practical Earley's parser.
Missing from it is Joop Leo's improvement --
they seem not to be aware of it.
Their own speedup is limited in what it achieves
and the complications it introduces
can be counter-productive at evaluation time.
But buried in their paper is a solution to the zero-length rule bug.
And this time the solution requires no additional bookkeeping.

# 2004

Bryan Ford publishes his paper on PEG.
Ford fills this gap by repackaging the nearly-forgotten GTDPL.
Ford adds packratting, so that PEG is always linear,
and provides PEG with an attractive new syntax.

Implementers by now are avoiding YACC,
but the demand for syntax-driven parsers remains.
PEG is not, in fact, syntax-driven,
but it uses the same BNF notation,
and many users don't know the difference.
And nothing has been done to change
[the problematic
behaviors](http://jeffreykegler.github.io/Ocean-of-Awareness-blog/individual/2015/03/peg.html)
of GTDPL.

# 2006
GNU announces that the GCC compiler's parser has been rewritten.
For three decades,
the industry's flagship C compilers have used
LALR as their parser --
proof of the claim that LALR and serious
parsing are equivalent.
Now, GNU replaces
LALR with the technology that
it replaced a quarter century earlier:
recursive descent.

# Today
After five decades of parsing theory,
the state of the art seems to be back
where it started.
We can imagine someone taking
Ned Iron's original 1961 algorithm
from the first paper ever published describing a parser,
and republishing it today.
True, he would have to
translate its code from the mix of assembler and
ALGOL into something more fashionable, say Haskell.
But with that change,
it might look like a breath of fresh air.

# Marpa: an afterword

The recollections of my teachers cover most of
this timeline.
My own begin around 1970.
Very early on, as a graduate student,
I became unhappy with the way
the field was developing.
Earley's algorithm looked interesting,
and it was something I returned to on and off.

Recall that
the original vision of the 1960's was a parser that
was efficient, practical, general, and
syntax-driven.

By 2010 this vision
seemed to have gone the same way as many other 1960's dreams.
The rhetoric stayed upbeat, but
parsing practice had become a series of increasingly desperate
compromises.

But,
while nobody was looking for them,
the solutions to the problems encountered in the 1960's
had appeared in the literature.
Aycock and Horspool had solved the zero-length rule bug.
Joop Leo had found the speedup for right recursion.
And the issue of bookkeeping overhead had pretty much evaporated on its
own.
Machine operations are now a billion times faster than in 1968,
and are probably no longer relevant in any case --
cache misses are now the bottleneck.

The programmers of the 1960's would have been prepared
to trust a fully declarative Chomskyan parser.
With the experience with LALR in their collective consciousness,
modern programmers might be more guarded.
As Lincoln said, "Once a cat's been burned,
he won't even sit on a cold stove."
But I found it straightforward to rearrange the Earley parse engine
to allow efficient
event-driven handovers between procedural and syntax-driven
logic.
And Earley tables provide the procedural logic with
full knowledge of the state of the
parse so far,
so that
Earley's algorithm is a better platform
for hand-written procedural logic than recursive descent.
