<div style="margin:1.5em; text-align:center">Parsing: an expanding timeline</div>

#The fourth century BCE

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
      His work has no direct effect on the other events in this timeline.

#1943
      Emil Post defines and studies a formal rewriting system using
      productions.
      With this, the process of reinventing Pannini in the West begins.

#1948
      Claude Shannon publishes the foundation paper of information theory.
      Andrey Markov's finite state processes are used heavily.

#1952
      Grace Hopper writes a linker-loader and
      <a href="https://en.wikipedia.org/wiki/History_of_compiler_construction#First_compilers">
        describes it
        as a "compiler"</a>.
      She seems to be the first person to use this term for a computer program.
      Hopper uses the term
      "compiler" in its original sense:
      "something or someone that brings other things together".
    </p>

#1954
      At IBM, a team under John Backus begins working
      on the language which will be called FORTRAN.
      The term "compiler" is still being used in Hopper's looser sense,
      instead of its modern one.
      In particular, there is no implication that the output of a "compiler"
      is ready for execution by a computer.
      <!-- "http://www.softwarepreservation.org/projects/FORTRAN/paper/Backus-ProgrammingInAmerica-1976.pdf
        pp. 133-134
      -->
      The output of one 1954 "compiler",
      for example, produces relative addresses,
      which need to be translated by hand before a machine can execute them.
    </p>

#1955
      Noam Chomsky is awarded a Ph.D. in linguistics and accepts a teaching post at MIT.
      MIT does not have a linguistics department and
      Chomsky, in his linguistics course, is free to teach his own approach,
      highly original and very mathematical.
    </p>

#1956
    <!-- "Three models" -->
    <p>
      Chomsky publishes the paper which
      is usually considered the foundation of Western formal language theory.
      The paper advocates a natural language approach that involves
    </p><ul>
      <li>a bottom layer, using Markov's finite state processes;
      </li><li>a middle, syntactic layer, using context-free grammars and
        context-sensitive grammars; and
      </li><li>a top layer, which involves mappings or "transformations"
        of the output of the syntactic layer.
      </li></ul><p>
      These layers resemble, and will inspire,
      the lexical, syntactic and AST transformation phases
      of modern parsers.
      For finite state processes, Chomsky acknowledges Markov.
      The other layers seem to be Chomsky's own formulations --
      Chomsky does not cite Post's work.
    </p>

#1957
      Steven Kleene discovers regular expressions,
      a very handy notation for Markov's processes.
      Regular expressions turn out to describe exactly the mathematical
      objects being studied as
      finite state automata,
      as well as some of the objects being studied as
      neural nets.
    </p>

#1957
      Noam Chomsky publishes
      <b>Syntactic Structures</b>,
      one of the most influential books of all time.
      The orthodoxy in 1957 is structural linguistics
      which argues, with Sherlock Holmes, that
      "it is a capital mistake to theorize in advance of the facts".
      Structuralists start with the utterances in a language,
      and build upward.
    </p>
    <p>
      But Chomsky claims that without a theory there
      are no facts: there is only noise.
      The Chomskyan approach is to start with a grammar, and use the corpus of
      the language to check its accuracy.
      Chomsky's approach will soon come to dominate linguistics.
    </p>

#1957
      Backus's team makes the first FORTRAN compiler
      available to IBM customers.
      FORTRAN is the first high-level language
      that will find widespread implementation.
      As of this writing,
      it is the oldest language that survives in practical use.
      FORTRAN is a line-by-line language
      and its parsing is primitive.
    </p>

#1958
      John McCarthy's LISP appears.
      LISP goes beyond the line-by-line syntax --
      it is recursively structured.
      But the LISP interpreter does not find the
      recursive structure:
      the programmer must explicitly
      indicate the structure herself,
      using parentheses.

#1959
      Backus invents a new notation to describe
      the IAL language (aka ALGOL).
      Backus's notation is influenced by his study of Post --
      he seems not to have read Chomsky until later.
      <!-- http://archive.computerhistory.org/resources/text/Oral_History/Backus_John/Backus_John_1.oral_history.2006.102657970.pdf
      p. 25 -->
    </p>

#1960
      Peter Naur
      improves the Backus notation
      and uses it to describe ALGOL 60.
      The improved notation will become known as Backus-Naur Form (BNF).

#1960
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
    </p>

#1960
      A.E. Gleenie publishes his description of a compiler-compiler.
      <!-- http://www.chilton-computing.org.uk/acl/literature/reports/p024.htm -->
      Glennie's "universal compiler" is more of a methodology than
      an implementation -- the compilers must be written by hand.
      Glennie credits both Chomsky and Backus, and observes that the two
      notations are "related".
      He also mentions Post's productions.
      Glennie may have been the first to use BNF as a description of a
      <b>procedure</b>
      instead of as the description of a
      <b>Chomsky grammar</b>.
      Glennie points out that the distinction is "important".
    </p>

#Chomskyan BNF and procedural BNF
      BNF, when used as a Chomsky grammar, describes a set of strings,
      and does
      <b>not</b>
      describe how to parse strings according to the grammar.
      BNF notation, if used to describe a procedure, is a set of instructions, to be
      tried in some order, and used to process a string.
      Procedural BNF describes a procedure first, and a language only indirectly.
    </p>
    <p>
      Both procedural and Chomskyan BNF describe languages,
      but usually
      <b>not the same</b>
      language.
      This is an important point, and one which will be overlooked
      many times in the years to come.
    <p>
      The pre-Chomskyan approach,
      using procedural BNF,
      is far more natural
      to someone trained as a computer programmer.
      The parsing problem appears to the programmer in the form of
      strings to be parsed,
      exactly the starting point of procedural BNF
      and pre-Chomsky parsing.
    </p>
    <p>
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
    </p>
    <p>
      Despite the naturalness of the pre-Chomskyan approach
      to parsing, we will find that the first fully-described
      automated parsers are Chomskyan.
      This is a testimony to Chomsky's influence at the time.
      We will also see that Chomskyan parsers
      have been dominant ever since.
    </p>

#1961
      In January,
      Ned Irons publishes a paper describing his ALGOL 60
      parser.
      It is the first paper to fully describe any parser.
      The Irons algorithm is Chomskyan and top-down
      with a "left corner" element.
      The Irons algorithm
      is general,
      meaning that it can parse anything written in BNF.
      It is syntax-driven (aka declarative),
      meaning that the parser is
      actually created from the BNF --
      the parser does not need
      to be hand-written.
    </p>

#1961
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
    </p>
    <ul>
      <li>
        Memory and CPU were both extremely limited.
        Hand-coding paid off, even when the gains were small.
      </li>
      <li>
        Non-hand coded top-down parsing,
        of the kind Lucas's syntax-driven
        approach allowed, is a very weak parsing technique.
        It was (and still is) often necessary
        to go beyond its limits.
      </li>
      <li>
        Top-down parsing is intuitive -- it essentially means calling
        subroutines.
        It therefore requires little or
        no knowledge of parsing theory.
        This makes it a good fit for hand-coding.
      </li>
    </ul>

#1963
      L. Schmidt, Howard Metcalf, and Val Schorre present papers
      on syntax-directed compilers at a Denver conference.
      <!-- Schorre 1964, p. D1.3-1 -->
    </p>

#1964
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

#1965
      Don Knuth invents LR parsing.
      The LR algorithm is deterministic,
      Chomskyan and bottom-up,
      but it is not thought to be practical.
      Knuth is primarily interested
      in the mathematics.
    </p>

#1968
      Jay Earley invents the algorithm named after him.
      Like the Irons algorithm,
      Earley's algorithm is Chomskyan, syntax-driven and fully general.
      Unlike the Irons algorithm, it does not backtrack.
      Earley's algorithm is both top-down and bottom-up at once --
      it uses dynamic programming and keeps track of the parse
      in tables.
      Earley's approach makes a lot of sense
      and looks very promising indeed,
      but there are three serious issues:
    </p>
    <ul>
      <li>First, there is a bug in the handling of zero-length rules.
      </li>
      <li>Second, it is quadratic for right recursions.
      </li>
      <li>Third, the bookkeeping required to set up the tables is,
        by the standards of 1968 hardware, daunting.
      </li>
    </ul>

#1969
      Frank DeRemer describes a new variant of Knuth's LR
      parsing.
      DeRemer's LALR algorithm requires only
      a stack and a state table of quite
      manageable size.
      LALR looks practical.
    </p>

#1969
      Ken Thompson writes the "ed" editor as one of the first components
      of UNIX.
      At this point, regular expressions are an esoteric mathematical formalism.
      Through the "ed" editor and its descendants,
      regular expressions will become
      an everyday
      part of the working programmer's toolkit.
    </p>

#Recognizers
      In comparing algorithms, it can be important to keep in mind whether
      they are recognizers or parsers.
      A
      <b>recognizer</b>
      is a program which takes a string and produces a "yes"
      or "no" according to whether a string is in part of a language.
      Regular expressions are typically used as recognizers.
      A
      <b>parser</b>
      is a program which takes a string and produces a tree reflecting
      its structure according to a grammar.
      The algorithm for a compiler clearly must be a parser, not a recognizer.
      Recognizers can be, to some extent,
      used as parsers by introducing captures.

#1972
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
    </p>

#1972
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
    </p>
    <p>
      GTDPL's obscurity buys nothing in the way of additional parsing
      power.
      Like all non-Chomskyan parsers,
      GTDPL is basically a extremely powerful recognizer.
      Pressed into service as a parser, it is comparatively weak.
      As a parser, GTDPL
      is essentially equivalent to Lucas's 1961 syntax-driven
      algorithm,
      which was in turn a restricted form of recursive descent.
    </p>
    <p>
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
    </p>

#1975
      Bell Labs converts its C compiler from hand-written recursive
      descent to DeRemer's LALR algorithm.
    </p>

#1977
      The first "Dragon book" comes out.
      This soon-to-be classic textbook is nicknamed after
      the drawing on the front cover,
      in which a knight takes on a dragon.
      Emblazoned on the knight's lance are the letters "LALR".
      From here on out,
      to speak lightly of LALR will be to besmirch the escutcheon
      of parsing theory.
    </p>

#1979
      Bell Laboratories releases Version 7 UNIX.
      V7 includes what is, by far,
      the most comprehensive, useable and easily available
      compiler writing toolkit yet developed.
    </p>

#1979
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
    </p>

#1987
      Larry Wall introduces Perl 1.
      Perl embraces complexity like no previous language.
      Larry uses YACC and LALR very aggressively --
      to my knowledge more aggressively than anyone before
      or since.
    </p>

#1991
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
    </p>
    <p>
      But Earley parsing is almost forgotten.
      Twenty years will pass
      before anyone writes a practical
      implementation of Leo's algorithm.
    </p>

#1990's
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

#2000
      Larry Wall decides on a radical reimplementation
      of Perl -- Perl 6.
      Larry does not even consider using LALR again.
    </p>

#2002
      John Aycock and R. Nigel Horspool
      publish their attempt at a fast, practical Earley's parser.
      Missing from it is Joop Leo's improvement --
      they seem not to be aware of it.
      Their own speedup is limited in what it achieves
      and the complications it introduces
      can be counter-productive at evaluation time.
      But buried in their paper is a solution to the zero-length rule bug.
      And this time the solution requires no additional bookkeeping.
    </p>

#2004
      Bryan Ford publishes his paper on PEG.
      Implementers by now are avoiding YACC,
      and it seems
      as if there might soon be no syntax-driven algorithms in practical
      use.
      Ford fills this gap by repackaging the nearly-forgotten GTDPL.
      Ford adds packratting, so that PEG is always linear,
      and provides PEG with an attractive new syntax.
      But nothing has been done to change
      <a href="http://jeffreykegler.github.io/Ocean-of-Awareness-blog/individual/2015/03/peg.html">
        the problematic behaviors</a>
      of GTDPL.

#2006
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
    </p>

#Today
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
    </p>
    <p>
    </p><h3>Marpa: an afterword</h3><p>
      The recollections of my teachers cover most of
      this timeline.
      My own begin around 1970.
      Very early on, as a graduate student,
      I became unhappy with the way
      the field was developing.
      Earley's algorithm looked interesting,
      and it was something I returned to on and off.
    </p>
    <p>
      The original vision of the 1960's was a parser that
      was
    </p>
    <ul>
      <li>efficient,
      </li>
      <li>practical,
      </li>
      <li>general, and
      </li>
      <li>syntax-driven.
      </li>
    </ul>
    <p>
      By 2010 this vision
      seemed to have gone the same way as many other 1960's dreams.
      The rhetoric stayed upbeat, but
      parsing practice had become a series of increasingly desperate
      compromises.
    </p>
    <p>
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
    </p>
    <p>
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
    </p>
  </body>
</html>
