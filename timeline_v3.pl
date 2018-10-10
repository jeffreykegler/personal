#!perl

use 5.010;
use strict;
use warnings;
use English qw( -no_match_vars );
use autodie;

sub usage {
	my ($message) = @_;
	die $message, "\nusage: $PROGRAM_NAME input fn_out > html_out\n";
}

my $fn_number = 0;
my @fn_lines = ();
my @lines = ();

sub do_constants {
    my ($line) = @_;
    $line =~ s/<thisyear>/2018/g;
    return $line;
}

LINE: while ( my $line = <DATA> ) {
    chomp $line;
    $line = do_constants($line);
    if ( $line =~ /<footnote>/ ) {
        do_footnote($line);
	next LINE;
    }
    if ( $line =~ /<h1>/ ) {
        do_h1($line);
	next LINE;
    }
    push @lines, $line;
}

my $output = join "\n", map { do_phase2($_) } @lines;
my $footnotes = join "\n", '<h1>Footnotes</h1>', map { do_phase2($_) } @fn_lines;
$output =~ s[<comment>FOOTNOTES HERE</comment>][$footnotes];

say $output;

sub bib_tag {
   my ($desc) = @_;
   $desc =~ s/ \s+ /_/gxms;
   $desc =~ s/[^_a-zA-Z0-9]/_/gxms;
   return 'bib-' . $desc;
}

sub do_bib {
   my ($line) = @_;
   my ($before, $stag, $desc, $etag, $after);
   ($before, $stag, $desc, $etag, $after) =
       $line =~ m{^ (.*) (<bibid>) ([^<]*) (<\/bibid>) (.*) $}mxs;
   if (defined $desc) {
       my $tag = bib_tag($desc);
       return $before
           . '<b id="' . $tag . '">' . $desc . '</b>'
	   . $after;
   }
   ($before, $stag, $desc, $etag, $after) =
       $line =~ m{^ (.*) (<bibref>) ([^<]*) (<\/bibref>) (.*) $}xms;
   if (defined $desc) {
       my $tag = bib_tag($desc);
       return $before
           . '<a href="#' . $tag . '">' . $desc . '</a>'
	   . $after;
   }
   return $line;
}

sub do_mla_url {
   my ($line) = @_;
   my @mla_lines = ();
   my ($before, $stag, $desc, $etag, $after) =
       $line =~ m{^ (.*) (<mla_url>) ([^<]*) (<\/mla_url>) (.*) $}xms;
   if (not defined $desc) {
      @mla_lines = ($line);
      return @mla_lines;
   }
   @mla_lines =
      ($before
	 . '<a href="' . $desc . '">' . $desc . '</a>'
	   . $after);
   return @mla_lines;
}

sub do_phase2 {
   my ($line) = @_;
   my @lines = ();
   my $bibed_line = do_bib($line);
   for my $urled_line (do_mla_url($bibed_line))
   {
      push @lines, $urled_line;
   }
   return @lines;
}

sub do_footnote {
    my ($line) = @_;
    $fn_number++;
    my $fn_ref = join '-', 'footnote', $fn_number, 'ref';
    my $fn_href = join '-', 'footnote', $fn_number;
    my $footnoted_line = $line;
    $footnoted_line =~ s/<footnote>.*$//;
    $footnoted_line .= qq{<a id="$fn_ref" href="#$fn_href">[$fn_number]</a>};
    push @fn_lines, qq{<p id="$fn_href"><b>$fn_number</b>.};
    $line =~ s/^.*<footnote>//;
    my $inside_footnote = $line;
    $inside_footnote =~ s/^.*<footnote>//;
    push @fn_lines, $inside_footnote if $inside_footnote =~ m/\S/;
    my $post_footnote = '';
  FN_LINE: while ( my $fn_line = <DATA> ) {
        chomp $fn_line;
	$fn_line = do_constants($fn_line);
        if ( $fn_line =~ m[<\/footnote>] ) {
	    $post_footnote = $fn_line;
	    $post_footnote =~ s[^.*<\/footnote>][];
	    $fn_line =~ s[</footnote>.*$][];
	    push @fn_lines, $fn_line if $fn_line =~ m/\S/;
	    push @fn_lines, qq{ <a href="#$fn_ref">&#8617;</a></p>};
	    last FN_LINE;
        }
	push @fn_lines, $fn_line;
    }
    $footnoted_line .= $post_footnote;
    push @lines, $footnoted_line if $footnoted_line =~ m/\S/;
}

# for tracking duplicates
my %h1_tags = ();

sub h1_tag {
   my ($desc) = @_;
   $desc = lc $desc;
   $desc =~ s/\s+$//;
   $desc =~ s/^\s+//;
   $desc =~ s/[":]//g;
   $desc =~ s/<[^>]*>//g;
   $desc =~ s/ \s+ /_/gxms;
   $desc =~ s/[^_a-zA-Z0-9]/_/gxms;
   die "Duplicate h1 tag: $desc" if $h1_tags{$desc};
   $h1_tags{$desc} = 1;
   return 'h1-' . $desc;
}

sub do_h1 {
    my ($line) = @_;
    if ($line !~ m{</h1>}) {
      # multiline
      my ($prefix, $header) = $line =~ m{(.*)<h1>(.*)$};
      if (not defined $header) {
       die "mal-formed line: $line";
       }
      if ($prefix =~ /\S/) {
	 die "Non-whitespace before <h1> in $line";
      }
      my $h1_tag = h1_tag($header);
      push @lines, qq{$prefix<h1 id="$h1_tag">};
      push @lines, qq{$prefix$header};
      return;
     }
     # single line
    my ($prefix, $header, $suffix) = $line =~ m{^(.*)<h1>(.*)</h1>(.*)$};
    if (not defined $suffix) {
       die "mal-formed line: $line";
    }
    if ($prefix =~ /\S/) {
       die "Non-whitespace before single-line <h1> in $line";
    }
    if ($suffix =~ /\S/) {
       die "Non-whitespace after </h1> in $line";
    }
    my $h1_tag = h1_tag($header);
    push @lines, qq{$prefix<h1 id="$h1_tag">};
    push @lines, qq{$prefix$header};
    push @lines, qq{$prefix</h1>};
    return;
}

__DATA__
<!--
      Formatted using
      marpa_r2_html_fmt --no-added-tag-comment --no-ws-ok-after-start-tag
  -->
<html>
  <head>
    <title>
      Parsing: a timeline -- V3.0
    </title>
    <style type="text/css">
      mytitle { font-size: 300%; text-align: center; display: block }
      author { font-size: 200%; text-align: center; display: block }
      version { font-size: 200%; text-align: center; display: block }
      datestamp { text-align: center; display: block }
      h1 { font-size: x-large }
      body {
      max-width:900px;
      font-size: large
      }
      comment { display:none }
      footnote { display:none }
      biblio { display:none }
      bibref { font-weight: bold }
      bibid { font-weight: bold }
      mla_container { font-style: italic }
      mla_title { }
      mla_title::before { content: open-quote }
      mla_title::after { content: close-quote }
      mla_url { display:none }
      term { }
      term::before { content: open-quote }
      term::after { content: close-quote }
    </style>
  </head>
  <body>
    <mytitle>Parsing: a timeline</mytitle>
    <version>Version 3.0</version>
    <datestamp>Revision 2, 6 October 2018</datestamp>
    <author>Jeffrey Kegler</author>
    <h1>4th BCE: Pannini's description of Sanskrit</h1>
    <p>In India, Pannini creates an exact and complete description of
      the Sanskrit language, including pronunciation. Sanskrit could be
      recreated using nothing but Pannini's grammar.
      Pannini's grammar is
      probably the first formal system of any kind, predating Euclid. Even
      today, nothing like it exists for any other natural language of
      comparable size or corpus. Pannini is the object of serious study
      today. But in the 1940's and 1950's Pannini is almost unknown in
      the West.
      Pannini will have no direct effect on the other events in
      this timeline.
    </p>
    <h1>1906: Markov's chains</h1>
    <p>Andrey Markov introduces his
      <term>chains</term>
      -- a set of
      states with transitions between them.<footnote>
        <bibref>Markov 1906</bibref>.
      </footnote>
      One offshoot of Markov's work will be what we now
      know as regular expressions.
      Markov uses his chains,
      not for parsing,
      but for addressing a problem in probability --
      does the law of large numbers require that events be
      independent?<footnote>
        Indirectly, Markov's purpose may have been
        to refute Nekrasov's proof of free will.
	Nekrasov reasoned as follows:
	<ul>
	<li>Events that follow the law of large numbers must be independent.</li>
	<li>Social statistics follow the law of large numbers.</li>
	<li>Social statistics are made up of individual human choices.</li>
	<li>Individual human choices are independent.</li>
	<li>Since individual human choices are independent of
	outside influence,
	human beings have free will.</li>
	</ul>
        Markov undercut Nekrasov's proof.
	by demonstrating that the law of large
        numbers works just as well for dependent events
        (<bibref>Hayes 2013</bibref>, pp. 92-93).
      </footnote>.
    </p>
    <h1>1913: Markov and Eugene Onegin</h1>
    <p>In 1913, Markov revisits his chains,
      applying them to the sequence of vowels and consonants
      in Pushkin's
      <cite>Eugene Onegin</cite><footnote>
        <bibref>Markov 1913</bibref>.
        See
        <bibref>Hayes 2013</bibref>
        and
        <bibref>Hilgers and Langville 2006</bibref>, pp. 155-157.
      </footnote>.
      Again, Markov's interest is not in parsing.
      Nonetheless,
      this is an application to language
      of what later will be regarded
      as a parsing technique,
      and apparently for the first time in the West.
    </p>
    <h1>1929: Bloomfield's "Postulates"</h1>
    <p>In 1929 Leonard Bloomfield,
      as part of his effort to create a linguistics that
      would be taken seriously as a science,
      published his "Postulates".<footnote>
        <bibref>Bloomfield 1926</bibref>.
      </footnote>
      Known as structural linguistics,
      Bloomfield's approach will be very successful,
      dominating American lingustics for
      over two decades.
    </p>
    <h1>"Language" as of 1929</h1>
    <p>
      Bloomfield's "Postulates" defines a "language" as
    </p>
    <blockquote>
      [t]he totality of utterances that can be made in a speech
      community<footnote>
        <bibref>Bloomfield 1926</bibref>,
        definition 4 on p. 154.
      </footnote>
    </blockquote>
    <p>
      Note that there is no reference in this definition to the usual view --
      that the utterances of a language "mean" something.
    </p>
    <p>
      This omission is not accidental.<footnote>
        "The statement of meanings is therefore the weak point in
        language-study, and will remain so until human knowledge
        advances very far beyond its present state. In practice, we define the
        meaning of a linguistic form, wherever we can, in terms of some
        other science.",
        <bibref>Bloomfield 1926</bibref>, p. 140.
      </footnote>
      Bloomfield excludes meaning from his definition of language
      because he wants linguistics to be taken
      seriously as science.
      Behaviorist thought is very influential at this
      time and behavorists believe that,
      while human behaviors can be observed and verified
      and therefore made the subject of science,
      mental states cannot be verified.
      Claiming to know what someone means
      by a word
      is claiming to read his mind.
      And "mind-reading" is not science.
    </p>
    <h1>1943: Post's rewriting system</h1>
    <p>Emil Post defines and studies a formal rewriting system<footnote>
        <bibref>Post 1943</bibref>.
      </footnote>
      using productions.
      With this, the process of rediscovering Pannini in the
      West begins.</p>
    <h1>1945: Turing discovers stacks</h1>
    <p>Alan Turing discovers the stack as part of his design of the
      ACE machine. This will be important in parsing because recursive parsing
      requires stacks. The importance of Turing's discovery is not noticed
      at the time and stacks will be rediscovered many times over the
      next two decades<footnote>
        <bibref>Carpenter and Doran 1977</bibref>
      </footnote>.
    </p>
    <h1>1948: Shannon repurposes Markov's chains</h1>
    <p>Claude Shannon publishes the foundation paper of information theory<footnote>
        <bibref>Shannon 1948</bibref>.
      </footnote>.
      In this
      paper, Shannon models English using Andrey Markov's
      chains<footnote>
        <bibref>Shannon 1948</bibref>, pp. 4-6.
        See also
        <bibref>Hilgers and Langville 2006</bibref>,
        pp. 157-159.
      </footnote>.
      The approach is similar to Markov's but the intent
      seems to be different --
      Shannon's is a serious attempt at a contribution
      to parsing human languages.
    </p>
    <h1>1949: Rutishauser's compiler</h1>
    <p>From 1949 to 1951 at the ETH Zurich, Heinz Rutishauser works on
      the design of what we would now call a compiler<footnote>
        <bibref>Knuth and Pardo 1976</bibref>,
        pp. 29-35, 40.
      </footnote>.
      Rutishauser's arithmetic expression parser
      does not honor precedence but it does allow nested parentheses.
      It is perhaps the first algorithm which can really be considered a
      parsing method.
      Rutishauser's compiler is never implemented.</p>
    <h1>The Operator Issue as of 1949</h1>
    <p>
      In the form of arithmetic expressions, operator expressions
      are the target of the first efforts at automatic parsing.
      We will not see this issue go away.
      Very informally<footnote>
        No formal apparatus for describing operator expressions is fully worked
	out as of 1949.
      </footnote>,
      we can say that
      an operator expression is an expression
      built up from operands
      and operators.
      It is expected that the operand might be another operator expression,
      so operator expressions raise the issue of recursion.
    </p>
    <p>
      The archetypal examples of operator expressions are arithmetic expressions:
    </p><pre><tt>
         2+(3*4)
         13^2^-5*9/11
         1729-42*8675309
      </tt></pre>
    <p>
      In Western mathematics arithmetic expressions have been read
      according to traditional
      ideas of
      associativity and precedence:
    </p><ul>
      <li><tt>^</tt>
        is exponentiation.
        It right associates and has tightest<footnote>
          This timeline refers to precedence levels as
          <q>tight</q>
          or
          <q>loose</q>.
          The traditional terminology is confusing: tighter
          precedences are
          <q>higher</q>
          but traditionally the
          precendence levels are also numbered and the higher
          the number, the lower the precedence.
        </footnote>
        precedence.
      </li>
      <li>
        Multiplication (<tt>*</tt>) and division (<tt>/</tt>) left associate.
        They have a precedence equal to each other
        and less tight than that of exponentiation.
      </li>
      <li>
        Addition ('+') and subtraction ('-') left associate.
        They have a precedence equal to each other
        and less tight than that of multiplication and division.
      </li>
      <li>
        Parentheses, when present, override the traditional
        associativity and precedence.
      </li>
    </ul>
    <p>
      Rutishauser's language
      is structured line-by-line,
      as will be all languages until LISP.
      No language until ALGOL will be truly block-structured.
    </p>
    <p>
      The line-by-line languages
      are parsed using string manipulations.
      A parsing theory is not helpful for describing these
      ad hoc string manipulations,
      so they don't give rise to one.
      The only logic in these early compilers that really deserves to be called
      a parsing method
      is that which tackles arithmetic expressions.
    </p><p>
    </p>
    <h1>1950: Boehm's compiler</h1>
    <p>During 1950, Corrado Boehm, also at the ETH Zurich,
      develops his own compiler.
      Rutishauser and Boehm are working at the same institution at the same
      time, but Boehm is unaware of Rutishauser's work until his own is
      complete.
      Boehm's is also the first self-compiling compiler -- it is written
      in its own language.
    </p>
    <p>
      Like Rutishauser, Boehm's language is line-by-line and
      parsed ad hoc, except for expressions. Boehm's expression parser
      <em>does</em>
      honor precedence, making it perhaps the first operator precedence
      parser<footnote>
        Some of the
        <q>firsts</q>
        for parsing algorithms in this
        timeline are debatable,
        and the history of operator precedence is especially murky.
        Here I follow
        <bibref>Samuelson and Bauer 1960</bibref>
        in giving the priority to Boehm.
      </footnote>.
      In Norvell's taxonomy<footnote>
        <bibref>Norvell 1999</bibref>.
      </footnote>,
      Boehm's algorithm inaugurates
      the
      <q>classic approach</q>
      to operator parsing.
    </p>
    <p>
      Boehm's compiler also allows parentheses, but the two cannot
      be mixed -- an expression can either be parsed using precedence
      or have parentheses, but not both.
      Also like Rutishauser's, Boehm's compiler is never
      implemented<footnote>
        <bibref>Knuth and Pardo 1976</bibref>,
        pp 35-42.
      </footnote>.
    </p>
    <h1>1952: Grace Hopper uses the term
      <term>compiler</term></h1>
    <p>Grace Hopper writes a linker-loader,
      and calls it a
      <term>compiler</term><footnote>
        <bibref>Knuth and Pardo 1976</bibref>, p. 50.
      </footnote>. Hopper seems to be the first
      person to use this term for a computer program.</p>
    <h1>"Compiler" as of 1952</h1>
    <p>Hopper uses the term
      <term>compiler</term>
      in a meaning it
      has at the time:
      <q>to compose out of materials from other
        documents</q><footnote>
        The quoted definition is from
        <bibref>Moser 1954</bibref>, p. 15,
        as cited in
        <bibref>Knuth and Pardo 1976</bibref>,
        p. 51.
      </footnote>.
      Specifically, in 1952,
      subroutines were new,
      and automated programming
      (what we will come to call
      <q>compiling</q>)
      often is viewed as providing a interface
      for calling a collection of
      carefully chosen assembler subroutines<footnote>
        In 1952, an interface that guided calls to subroutines
        was much more helpful than current programmers might
        imagine:
        "Existing programs for similar problems were unreadable
        and hence could not be adapted to new uses."
        (<bibref>Backus 1980</bibref>, p. 126)
      </footnote>.
      Hopper's new
      program takes this subroutine calling
      one step further -- instead of calling the subroutines
      it expands them (or in Hopper's terms
      <q>compiles</q>
      them) into
      a single program.
    </p>
    <p>
      After Hopper the term
      <term>compiler</term>
      will acquire a different meaning,
      one specific to the computer field.
      By 1956, programs like Hoppers will
      no longer be called
      <term>compilers</term><footnote>
        I hope nobody will read this terminological clarification as in any sense
        detracting from Hopper's achievement.
        Whatever it is called, Hopper's program was a major advance,
        both in terms of insight and execution, and her energetic followup
        did much to move forward the events in this timeline.
        Hopper has a big reputation and it is fully deserved.
      </footnote>.
    </p>
    <h1>1951: Kleene's regular languages</h1>
    <p>Kleene discovers regular languages<footnote>
        <bibref>Kleene 1951</bibref>.
      </footnote>.
      Kleene does not use regular expression notation,
      but his regular languages are the idea behind
      it.
    </p>
    <h1>1952: Glennie's AUTOCODE</h1>
    <p>
      Glennie discovers what Knuth will later
      call the first
      <q>real</q><footnote>
        <bibref>Knuth and Pardo 1976</bibref>,
        p 42.
      </footnote>
      compiler.
      (By this Knuth will mean that
      AUTOCODE was actually implemented and used by someone to translate
      algebraic statements into machine language.)
      Glennie's AUTOCODE
      is very close to the machine -- just above machine language.
      It does not allow operator expressions.
    </p>
    <p>
      AUTOCODE is hard-to-use,
      and apparently sees little use by anybody but
      Glennie himself.
      Because
      Glennie works for the British atomic weapons projects his papers
      are routinely classified,
      so even the indirect influence of AUTOCODE is
      slow to spread.
      Nonetheless, many other
      <term>compilers</term>
      afterward will be named AUTOCODE, probably
      because the authors are
      aware of Glennie's effort<footnote>
        <bibref>Knuth and Pardo 1976</bibref>,
        pp. 42-49.
      </footnote>.
    </p>
    <h1>1954: The FORTRAN project begins</h1>
    <p>At IBM, a team under John Backus begins working on the language which will be called FORTRAN.</p>
    <h1>"Compiler" as of 1954</h1>
    <p>The term
      <term>compiler</term>
      is still being used
      in Hopper's looser sense, instead of its modern, specialized,
      one.
      In particular, there is no implication that the output of a
      <term>compiler</term>
      is ready for execution by a computer.
      The output of one 1954
      <term>compiler</term>, for example, produces
      relative addresses, which need to be translated by hand before
      a machine can execute them<footnote>
        <bibref>Backus 1980</bibref>, pp. 133-134.
      </footnote>.</p>
    <h1>1955: Noam Chomsky graduates</h1>
    <p>
      Noam Chomsky earns his PhD at the University of Pennsylvania.
      His teacher, Zelig Harris, is a prominent Bloomfieldian,
      and Chomsky's early work is thought to be in the Bloomfield school.<footnote>
        <bibref>Harris 1993</bibref>,
        pp 31-34, p. 37.
      </footnote>
      That same year Chomsky accepts
      a teaching post at MIT.
      MIT does not have a linguistics department,
      and Chomsky is free to teach his own
      (highly original and very mathematical)
      approach to linguistics.
    </p>
    <h1>1955: Work begins on the IT compiler</h1>
    <p>At Purdue, a team including Alan Perlis and Joseph Smith begins work
      on the IT compiler<footnote>
        <bibref>Knuth and Pardo 1976</bibref>,
        pp. 83-86.
      </footnote>.
    </p>
    <h1>1956: The IT compiler is released</h1>
    <p>Perlis and Smith, now at the Carnegie Institute of Technology,
      finish the IT compiler<footnote>
        <bibref>Perlis et al 1958</bibref>.
        <bibref>Knuth and Pardo 1976</bibref>, p. 83,
        state that the IT compiler "was put into use
        in October, 1956."
      </footnote>.
      Don Knuth calls this
    </p><blockquote>
      the first really
      <em>useful</em>
      compiler. IT and IT's derivatives were used successfully and
      frequently in hundreds of computer installations until [their
      target] the [IBM] 650 became obsolete. [... P]revious systems
      were important steps along the way, but none of them had the
      combination of powerful language and adequate implementation and
      documentation needed to make a significant impact in the use of
      machines.<footnote>
        <bibref>Knuth and Pardo 1976</bibref>, p. 84.
      </footnote>
    </blockquote>
    <p>The IT language had arithmetic expressions, of a sort --
      parentheses are honored, but otherwise evaluation is always
      right-to-left -- and there is no operator precedence.
      The IT compiler's way of doing arithmetic expressions
      proves very unpopular: Donald Knuth reports that
    </p>
    <blockquote>
      The lack of
      operator priority
      (often called precedence or hierarchy) in the IT
      language was the most frequent single cause of errors by the users
      of that compiler.<footnote>
        <bibref>Knuth 1962</bibref>.
        The 1956 date for IT is from
        <bibref>Padua 2000</bibref>.
      </footnote>
    </blockquote>
    <h1>"Compiler" as of 1956</h1>
    <p>In the 1956 document describing the IT compiler<footnote>
        <bibref>Chipps et al 1956</bibref>.
      </footnote>,
      the IT team uses the term "compiler" in its modern sense:
      a fully automatic procedure, in other words a program,
      which translates from one language
      (the source language)
      to another
      (the target language).
      Most commonly,
      the ultimate target of a compiler is
      an executable.<footnote>
      According to Knuth,
      "a comparison of ONR [Office of Naval Research] 1954
      and ONR 1956
      proceedings makes it clear that the work 'compiler'
      had by now [1956]
      acquired its modern meaning":
      <bibref>Knuth and Pardo 1976</bibref>, p. 83.
      <bibref>Chipps et al 1956</bibref> gives a definition
      of the term "compiler", but its emphasis on flow charts
      and machine instructions makes it very hard to recognize
      as the modern one.
      However, Knuth made a very careful study of the literature
      and I defer to him.
      </footnote>
    </p>
      <p>Compilers in the 1956 sense of the term had been
      envisioned even before Hopper used the term.
      At the time,
      nobody had called these programs compilers -- compiling in
      the 1956 sense of term
      had called
      <q>automatic coding</q>,
      <q>codification automatique</q>
      or
      <q>Rechenplanfertigung</q><footnote>
        <bibref>Knuth and Pardo 1976</bibref>,
        p. 50.
      </footnote>.
    </p>
      </p>
    <h1>1956: The Chomsky hierarchy</h1>
    <p>Chomsky publishes his "Three models" paper,
      which is usually considered the foundation of
      Western formal language theory<footnote>
        <bibref>Chomsky 1956</bibref>.
      </footnote>.
      Chomsky demolishes the idea that natural language grammar can be
      modeled using only Markov chains. Instead, the paper advocates a
      natural language approach that uses three layers:</p>
    <ul>
      <li>Chomsky uses
        Markov's chains
        as his
        <b>bottom layer</b>.
        This becomes the modern compiler's
        <b>lexical phase</b>.</li>
      <li>Chomsky's
        <b>middle layer</b>
        uses context-free
        grammars and context-sensitive grammars.
        These are his own
        discoveries<footnote>
          Chomsky seems
          to have been unaware of Post's work -- he does not cite it.
        </footnote>.
        This middle layer becomes the
        <b>syntactic phase</b>
        of modern
        compilers.</li>
      <li>Chomsky's
        <b>top layer</b>, again his own
        discovery, maps or
        <term>transforms</term>
        the output of the middle
        layer. Chomsky's top layer is the inspiration for
        the AST transformation
        phase of modern compilers.
      </li>
    </ul>
    <h1>Term: "Language" as of 1956</h1>
    <p>In his "Three models" paper,
      Chomsky says that
    </p><blockquote>
      By a language then, we shall mean a set (finite or infinite) of
      sentences, each of finite length, all constructed from a finite
      alphabet of symbols.<footnote>
        <bibref>Chomsky 1956</bibref>, p. 114.
        In case there is any doubt Chomsky's "strings"
        are the same as Bloomfield's utterances,
        Chomsky also calls his strings,
        "utterances".
        For example,
        <bibref>Chomsky 2002</bibref>, p. 15:
        "Any grammar of a language will project the finite and somewhat accidental
        corpus of observed utterances to a set (presumably infinite)
        of grammatical utterances."
      </footnote>
    </blockquote>
    <p>
      This is exactly Bloomfield's definition,
      restated using set theory.
      Nonetheless signs of departure from the behaviorist orthodoxy are
      apparent in "Three Models" --
      Chomsky is quite willing to talk about what sentences mean,
      when it serves his purposes.
    </p>
    <p>
      For a utterance with multiple meanings,
      Chomsky's new model produces multiple syntactic derivations.
      Each of these syntactic derivations
      "looks" like the natural representation
      of one of the meanings.
      Chomsky points out that the insight into semantics
      that his new model provides is a very
      desirable property to have.<footnote>
        <bibref>Chomsky 1956</bibref>, p. 118, p. 123.
      </footnote>
    </p>
    <h1>Term: "Parser"</h1>
    <p>Chomsky is a turning point, so much so that he establishes or settles the
      meaning of many of the terms we are using.
      A
      <term>parser</term>,
      for our purposes, is something or someone that transforms
      a string of symbols into a
      structure,
      according to a description
      of the mapping from strings to structures.
      For our purposes,
      the structures can usually be considered to be parse trees.</p>
    <h1>Term: "Recognizer"</h1>
    <p>In contrast to a parser,
      a
      <term>recognizer</term>
      is a something or someone that
      takes a string and answers
      <q>yes</q>
      or
      <q>no</q>
      --
      <q>yes</q>
      if the string is in the language described by the recognizer,
      <q>no</q>
      otherwise.
      Note that,
      if we intend to do semantics,
      a recognizer alone is not sufficient.
    </p>
    <p>In the strict sense, a recognizer cannot drive a compiler --
      a compiler needs a parser.
      But recognizers can be far easier to write,
      and are often hacked up
      and pressed into service as parsers.
      For example, if your semantics is simple and non-recursive,
      you might be able to drive your semantics phase with
      the output of
      a regex engine, using captures.
    </p>
    <h1>1957: Chomsky publishes
      <cite>Syntactic Structures</cite></h1>
    <p>Noam Chomsky publishes
      <cite>Syntactic Structures</cite><footnote>
        <bibref>Chomsky 1957</bibref>.
      </footnote>, one of the most important books of
      all time.
      The orthodoxy in 1957 is structural linguistics which
      argues, with Sherlock Holmes, that
      <q>it is a capital mistake
        to theorize in advance of the facts</q>.
      Structuralists start
      with the utterances in a language, and build upward.</p>
    <p>But Chomsky claims that without a theory there are no facts: there
      is only noise. The Chomskyan approach is to start with a grammar,
      and use the corpus of the language to check its accuracy. Chomsky's
      approach will soon come to dominate linguistics.</p>
    <h1>Term: "Chomskyan parsing"</h1>
    <p>From here on,
      parsing theory
      divides into Chomskyan and
      non-Chomskyan.
      Chomskyan parsing theory becomes and remains the mainstream.
      But it is far from unchallenged.
    </p><p>
      Above we defined a
      <term>parser</term>
      (<term>recognizer</term>)
      as something or someone that
      parses (recognizes) a string
      according to a description.
      In Chomskyan parsing (recognizing),
      the description is that of Chomsky's middle layer.
      If the description is anything else,
      the parser (recognizer) is non-Chomskyan.
    </p>
    <p>
      As of 1957, we are calling the description
      of a Chomskyan middle layer,
      a
      <term>context-free grammar</term>
      --
      BNF notation for context-free grammars
      has not yet been discovered.
      Once it is,
      we will refer to context-free grammars
      as BNF grammars.
    </p>
    <h1>1957: FORTRAN released</h1>
    <p>Backus's team makes the first FORTRAN compiler available to IBM
      customers. FORTRAN is the first high-level language that will find
      widespread implementation. As of this writing, it is the oldest
      language that survives in practical use.</p>
    <p>FORTRAN I is a line-by-line language.
      Its parsing is non-Chomskyan.
      But it includes one important discovery.
      FORTRAN allows expressions and,
      learning from the
      dissatisfaction with the IT compiler,
      FORTRAN honors associativity
      and precedence.</p>
    <p>The designers of FORTRAN use a strange trick for parsing operator expresssions --
      they hack the expressions by adding parentheses around each
      operator.
      The number of parentheses varied, depending on the operator.
      Surprisingly, this works.
      In fact, once the theoretical
      understanding of operator precedence comes about,
      the FORTRAN I implementation will be recognized
      as a hackish and inefficient way of
      implementing the classic operator precedence algorithm.</p>
    <h1>1958: LISP released</h1>
    <p>John McCarthy's LISP appears. LISP goes beyond the line-by-line
      syntax -- it is recursively structured. But the LISP interpreter does
      not find the recursive structure: the programmer must explicitly
      indicate the structure herself, using parentheses.
      Similarly, LISP does not have operator expressions in the usual sense --
      associativity and precedence must be specified with parentheses.
    </p>
    <h1>1959: Backus's notation</h1>
    <p>Backus discovers a new notation to describe the IAL language<footnote>
        Backus's notation is influenced by his study of Post --
        he seems not to have read Chomsky until later.
        See
        <bibref>Backus 2006</bibref>, p. 25
        and
        <bibref>Backus 1980</bibref>, p. 133.
      </footnote>.
      According to Backus's recollection,
      his paper<footnote>
        <bibref>Backus 1959</bibref>.
      </footnote>
      has only one reader: Peter Naur<footnote>
        <bibref>Backus 1980</bibref>, pp. 132-133.
      </footnote>.
      The IAL language will soon be renamed ALGOL.
    </p>
    <h1>1959: Operator precedence and stacks</h1>
    <p>Samuelson and Bauer<footnote>
        <bibref>Samuelson and Bauer 1960</bibref>.
      </footnote>
      describe the use of stacks to implement
      operator precedence.
      Samuelson and Bauer do not use the word
      <term>stack</term>
      --
      what we call a
      <term>stack</term>,
      they call a
      <term>cellar</term>.
      They explain the idea in great detail --
      apparently, 14 years after Turing's discovery of them,
      stacks are still unfamiliar,
      even to the readers of technical journals.
    </p>
    <p>
      Their algorithm, and its presentation,
      are thoroughly non-Chomskyan.
      Samuelson and Bauer do not provide
      a context-free grammar for their grammar,
      just an operator precedence table.
    </p>
    <h1>The Operator Issue as of 1959</h1>
    <p>Since Boehm,
      many people have been refining operator precedence.
      With Samuelson and Bauer,
      what Norvell<footnote>
        <bibref>Norvell 1999</bibref>.
      </footnote>
      calls "the classic algorithm"
      takes a well-documented form.
      The Samuelson and Bauer paper will be very influential.
    </p>
    <h1>"Language" as of 1959</h1>
    <p>In 1959, Chomsky reviews a book by B.F. Skinner on linguistics.<footnote>
        <bibref>Chomsky 1959</bibref>.
      </footnote>
      Skinner is the most prominent behaviorist of the time.
      This review galvanizes the opposition to behaviorism, and
      establishes Chomsky as behavorism's most
      prominent and effective critic.
      Chomsky makes clear his stand on the role of mental
      states in language study.
      Behaviorist claims that they can eliminate
      "traditional formulations in terms of reference and meaning",
      Chomsky says,
      are "simply not true."<footnote>
        <bibref>Chomsky 1959</bibref>, Section VIII.
        In later years,
        Chomsky will make it clear that he never intended
        to avoid semantics:
        <blockquote>
          [...] it would be absurd to develop
          a general syntactic theory
          without assigning an absolutely
          crucial role to semantic considerations,
          since obviously the necessity to support
          semantic interpretation is one of the primary
          requirements
          that the structures
          generated by the syntactic component of a grammar
          must meet.  (<bibref>Chomsky 1978</bibref>,
          p. 20, in footnote 7 starting on p. 19).
        </blockquote>
      </footnote>
    </p>
    <p>Unfortunately, by this time,
      Chomsky's original definition
      of language as a "set of strings",
      is established in the computer literature.
      Chomsky's clarifications go unnoticed.
      In fact, as the mathematics of parsing theory develops,
      the Bloomfieldian definition will become even more
      firmly entrenched.
    </p>
    <h1 id="text-1960-Oettinger">April 1960: Oettinger discovers pushdown automata</h1>
    <p>
      Mathematical study of stacks as models of computing begins with
      a paper submitted by
      Anthony Oettinger to a symposium in 1960.<footnote>
        <bibref>Oettinger 1960</bibref>
        American Mathematical Society, 1961.
      </footnote>
      Oettinger's paper is full of evidence that stacks
      are still very new.
      For a start, he does not call them stacks --
      he calls them "pushdown stores".
      And Oettinger does not assume his highly sophisticated audience
      knows what the "push"
      and "pop" operations are --
      he defines them based on
      another set of operations --
      one that eventually will form the basis
      of the APL language.
    </p>
    <p>
      Oettinger's definitions all follow the behavorist model --
      they are sets of strings.<footnote>
        <bibref>Oettinger 1960</bibref>, p. 106.
      </footnote>
      Oettinger's mathematical model of stacks
      will come to be called
      a deterministic pushdown automata (DPDA).
      DPDA's will become
      the subject of a substantial literature.
    </p>
    <p>
      Oettinger's own field is Russian translation.
      He hopes that DPDA's
      will be an adequate basis for
      the study of both computer and
      natural language translation.
      DPDA's soon prove totally inadequate
      for natural language translation.
      But for dealing with computing languages,
      DPDA's will have a much longer life.
    </p>
    <p>
      Oettinger challenges the research community to
      develop a systematic method for generating stack-based
      parsers.<footnote>
        "The development of a theory of pushdown algorithms should
        hopefully lead to systematic techniques for generating
        algorithms satisfying given requirements to replace
        the ad hoc invention of each new algorithm."
        (<bibref>Oettinger 1960</bibref>, p. 127.)
      </footnote>
      This search
      quickly becomes identified
      with the search for a theoretical basis for practical parsing.
    </p>
    <h1>Term: "State-driven"</h1>
    <p>A "state-driven" parser is one which tracks the parse using
    a data of a small constant size.
    Regular expressions are the classic state-driven parsers,
    and their state usually can be tracked as an integer.
    Regular expressions have limited power,
    but a parser just does not get any faster or
    more compact.
    A parsing algorithm
    </p>
    <h1>Term: "Stack-driven"</h1>
    <p>
    A "stack-driven" algorithm tracks the parse using
    data which is not of constant size, but
    which needs to access only a small fixed amount of it --
    that is, at any point the parser
    only needs to look at the "top" of the stack.
    By 1961, stacks are becoming understood,
    and the hardware is becoming capable of handling them.
    As of 1961, all of the more powerful algorithms
    with acceptable speed are based
    on stacks in some way.
    </p>
    <h1>May 1960: The ALGOL report</h1>
    <p>The ALGOL 60 report<footnote>
        <bibref>ALGOL 1960</bibref>.
      </footnote>
      specifies, for the first time, a block
      structured language. ALGOL 60 is recursively structured but the
      structure is implicit -- newlines are not semantically significant,
      and parentheses indicate syntax only in a few specific cases. The
      ALGOL compiler will have to find the structure.
    </p>
    <h1>The Parsing Problem</h1>
    <p>With the ALGOL 60 report, a search begins which continues to this day:
      to find a parser that solves the Parsing Problem.
      Ideally such a parser is<footnote>
        The linguistics literature discuss goals, philosophy and motivations,
        sometimes to the detriment of actual research
        (<bibref>Harris 1993</bibref>).
        The Parsing Theory literature, on the other hand, avoids
        non-technical discussions,
        so that a "manifesto" listing the goals of Parsing Theory
        is hard to find.
        But the first two sentences of the pivotal
        <bibref>Knuth 1965</bibref>
        may serve as one:
        <br><br>
        "There has been much recent interest in languages
        whose grammar is sufficiently simple
        that an
        <b>efficient</b>
        left-to-right parsing
        algorithm can be
        <b>mechanically produced</b>
        from the grammar.
        In this paper, we define LR(k) grammars,
        which are perhaps the
        <b>most general</b>
        ones of this type, [...]"
        (p. 607, boldface added.)
        <br><br>
        Here Knuth explcitly refers to goals of efficiency,
        declarativeness,
        and generality,
        announcing a trade-off of the first two against
        the second.
        Note Knuth also refers to "left-to-right"
        as a goal,
        but this he makes clear (pp. 607-608) that
        is because he sees it as a requirement
        for efficiency.
      </footnote>
    </p>
    <ul id="loc-parsing-problem">
      <li>efficient,</li>
      <li>general,</li>
      <li>declarative, and</li>
      <li>practical<footnote>
          <term>Practical</term>
          here is a catch-all term
          for those properties which Parsing Theory
          de-emphasized.
          As such, the literature rarely explicitly refers
          to practicality as a goal.
          And, in some Parsing Theory papers, it is not a goal,
          at least not directly.
          But I think it can be taken as given that,
          when the discussion was about parsers intended for actual
          use, practicality was a goal.
        </footnote>.</li>
    </ul>
    <p>
      It is a case of 1960's
      optimism at its best. As the ALGOL committee is well aware, a parsing
      algorithm capable of handling ALGOL 60 does not yet exist. But the
      risk they are taking has immediate results --
      1961 will see a number of discoveries that are still important
      today.
      On the other hand, the parser they seek will remain elusive for
      decades.
    </p>
    <h1>May 1960: BNF</h1>
    <p>In the ALGOL 60 report<footnote>
        <bibref>ALGOL 1960</bibref>.
      </footnote>,
      Peter Naur improves the Backus notation and uses it to describe
      the language.
      This brings Backus' notation to wide attention.
      The improved notation will become known as Backus-Naur Form
      (BNF).
    </p>
    <h1>Term: "declarative"</h1>
    <p>For our purposes, a parser is
      <term>declarative</term>,
      if it
      will parse directly and automatically from grammars written in BNF.
      Declarative parsers are often called
      <term>syntax-driven</term>
      parsers.
    </p>
    <h1>Term: "procedural"</h1>
    <p>A parser is
      <term>procedural</term>, if it requires procedural
      logic as part of its syntax phase.
    </p>
    <h1>Term: "general"</h1>
    <p>A general parser is a parser that will parse
      any grammar that can be written in BNF<footnote>
        As a pedantic point, a general parser need only parse
        <term>proper</term>
        grammars. A BNF grammar is
        <term>proper</term>
        if it has no useless rules and no infinite loops.
        Neither of these
        have any practical use, so that the restriction to proper grammars
        is unproblematic.
      </footnote>.
    </p>
    <h1 id="text-1960-glennie">July 1960: Glennie's compiler-compiler</h1>
    <p>The first description of a consciously non-Chomskyan compiler
      seems to predate the first description of a Chomskyan parser.
      It is A.E. Glennie's 1960 description of his compiler-compiler<footnote>
        <bibref>Glennie 1960</bibref>.
      </footnote>.
      Glennie's
      <term>universal compiler</term>
      apparently is useable,
      but it is more of a methodology
      than an implementation -- the compilers must be written by
      hand.
    </p>
    <p>
      Glennie uses BNF,
      but he does
      <em>not</em>
      use it in the way
      Chomsky, Backus and Naur intended.
      Glennie is using BNF to describe a
      <b>procedure</b>.
      In true BNF, the order of the rules does not matter --
      in Glennie's pseudo-BNF order matters very much.
      This means that, for most practical grammars,
      a set of rules in the form of BNF describe one
      language when interpreted as intended
      by Backus and Naur,
      and another when interpreted as
      intended by Glennie.
    </p>
    <p>
      Glennie is aware of what he is doing, and
      is not attempting to deceive anyone --
      he points out that the distinction
      between his procedural pseudo-BNF and declarative BNF,
      and warns his reader that the difference is
      <q>important</q><footnote>
        <bibref>Glennie 1960</bibref>.
      </footnote>.
      <comment>
        Is Glennie's non-Chomskyan-ism on theoretical grounds,
        or pragmatic?
      </comment>
    </p>
    <h1>January 1961: The first parsing paper</h1>
    <p>Ned Irons publishes a paper describing his ALGOL
      60 parser.
      It is the first paper to fully describe any parser.
      The Irons algorithm is pure Chomskyan,
      declarative, general,
      and top-down with a bottom-up
      <term>left
        corner</term>
      element -- it is what now would be called a
      <term>left
        corner</term>
      parser<footnote>
        <bibref>Irons 1961</bibref>.
        Among those who state that
        <bibref>Irons 1961</bibref>
        parser is what
        is now called
        <term>left-corner</term>
        is Knuth (<bibref>Knuth 1971</bibref>, p. 109).
      </footnote>.
      Since it is general,
      operator expressions are within the power of
      the Irons parser<footnote>
        Although it seems likely that parsing operator expressions would require
        backtracking,
        and therefore could be inefficient.
      </footnote>.
    </p>
    <h1>Term: "Top-down"</h1>
    <p>A top-down parser deduces the constituents of a rule from the rule.
      That is, it looks at the rule first,
      and then deduces what is on its RHS.
      Thus, it works from the start rule, and works
      <q>top down</q>
      until it arrives at the input tokens.
    </p>
    <p>It is important to note that no useful parser can be purely top-down --
      if a parser worked purely top-down, it would never look at its input.
      So every top-parser we will consider has
      <em>some</em>
      kind of bottom-up element.
      That bottom-up element may be very simple -- for example, one character lookahead.
      The
      <bibref>Irons 1961</bibref>
      parser,
      like most modern top-down parsers,
      has a sophisticated bottom-up element.
    </p>
    <h1>Term: "Bottom-up"</h1>
    <p>A bottom-up parser deduces a rule from its constituents.
      That is, it looks at either the input or at the LHS symbols
      of previously deduced rules,
      and from that deduces a rule.
      Thus, it works from the input tokens, and works
      <q>bottom up</q>
      until it reaches the start rule.
    </p>
    <p>
      But just as no really useful parser is purely top-down,
      no really useful parser is purely bottom-up.
      It it true that
      the
      <b>implementation</b>
      of a useful parser might be 100% bottom-up.
      But a useful
      parser must do more than return all possible partitions of the input --
      it must
      implement some criteria for preferring some parse trees over
      others.
      Implicitly, such criteria come "from the top".
    </p><p>
    </p><p>
      In fact,
      bottom-up parsers will often be pressed into service
      for Chomskyan parsing,
      and the Chomskyan approach is inherently top down.
      Even when it comes to implementation,
      bottom-up parsers will often use
      explicit top-down logic.
      For efficiency it is usually necessary to eliminate unwanted
      parses trees while parsing,
      and culling unwanted parse trees is a job
      for top-down logic.
    </p>
    <h1>Term: "Synthesized attribute"</h1>
    <p><bibref>Irons 1961</bibref>
      also introduces synthesized attributes: the parse creates
      a tree, which is evaluated bottom-up. Each node is evaluated using
      attributes
      <q>synthesized</q>
      from its child nodes<footnote>
        Irons is credited with the discovery of synthesized attributes
        by Knuth (<bibref>Knuth 1990</bibref>).
      </footnote>.
    </p>
    <h1 id="text-1961-sakai">September 1961: Sakai discovers table parsing</h1>
    <p>Sakai publishes<footnote>
    <bibref>Sakai 1961</bibref>
    </footnote>
    publishes a description of a translator,
    illustrating it with two translations
    of brief texts, one Japanese to English,
    and the other English to Japanese.
    Sakai's translation scheme is hopelessly underpowered,
    an example of the linguistic naivety
    prevalent in the field at the time.
    But the parser in Sakai's translator is an important discovery,
    and will remain in use.
    </p>
    <p>
    Sakai's is 
    the first description of a <a href=
    "#text-term-table-driven">table-driven</a>
    parser.
    His algorithm will be rediscovered several times between now and 1969.
    It will more commonly be called the CYK algorithm after the names
    of some of its rediscoverers.<footnote>
      The credited rediscoveries are <bibref>Hayes 1962</bibref>
      (attributed to Cocke);
      <bibref>Younger 1967</bibref>;
      and <bibref>Kasami and Torii 1969</bibref>.
    </footnote>
    </p>
    <p>Sakai's algorithm is bottom-up --
    it works by pairing adjacent symbols
    and selecting pairs according to a table.
    The table entries can be probabilities,
    and this is highly useful in some circumstances.
    If the probabilities other than 0 and 1 are used,
    Sakai's algorithm is non-Chomskyan.
    If the probabilities are restricted to 0 and 1,
    they can be treated as booleans instead,
    and in this special case Sakai's algorithm is Chomskyan.<footnote>
    <bibref>Sakai 1961</bibref> does not give context-free grammars
    for its examples,
    so it is perhaps best called non-Chomskyan.
    On the other hand, Sakai's tables for adjacent pairs
     are restricted to booleans.
    </footnote>
    </p>
    <p>
    Sakai's algorithm is impractically slow for large inputs<footnote>
    Sakai's algorithm runs in will come to be called
    <a href="#text-term-linear">cubic time</a>.
    </footnote>.
    But Sakai's algorithm will remain useful in very special circumstances.
    These are cases where no method is capable of parsing long inputs in reasonable
    time,
    and where the grammar is conveniently described in terms of the frequency of adjacent
    components.
    This will make Sakai's a good fit with some statistically-based approaches
    to Natural Language Processing.
    </p>
    <h1 id="text-term-table-driven">Term: "Table-driven"</h1>
    <p>A parsing algorithm is "table-driven" if tracks the
    parse using random access to data which varies in size
    with the parse.
    Table-driven parsing is a real challenge to 1961 hardware,
    and its memory and speed demands are almost always seen 
    as too great.
    </p>
    <h1>November 1961: Dijkstra's shunting yard algorithm</h1>
    <p>In November 1961, Dijkstra publishes the
      <q>shunting yard</q>
      algorithm<footnote>
        <bibref>Dijkstra 1961</bibref>.
      </footnote>.
      In Norvell's useful classification<footnote>
        <bibref>Norvell 1999</bibref>.
      </footnote>
      of operator expression parsers,
      all
      earlier parsers have been what he calls
      <q>the classic
        algorithm</q>.
    </p>
    <p>
      Dijkstra's approach is new.
      In the classic approach,
      the number
      of levels of precedence is hard-coded into the
      algorithm.
      Dijkstra's algorithm can handle any number of levels
      of precedence without a change in its code,
      and without any effect on its running speed.
    </p>
    <h1>December 1961: Lucas discovers recursive descent</h1>
    <p>Peter Lucas publishes his description of a top-down parser<footnote>
        <bibref>Lucas 1961</bibref>.
      </footnote>.
      Either Irons paper or this one can be considered to be
      the first description of recursive descent<footnote>
        <bibref>Grune and Jacobs 2008</bibref>
        call Lucas the discoverer of recursive descent.
        In fact, both
        <bibref>Irons 1961</bibref>
        and
        <bibref>Lucas 1961</bibref>
        are recursive descent with a major bottom-up element.
        Perhaps Grune and Jacobs based their decision on the Lucas' description of his algorithm,
        which talks about his parser's bottom-up element only briefly,
        while describing the top-down element in detail.
        Also, the Lucas algorithm resembles modern implementations of recursive descent
        much more closely than does
        <bibref>Irons 1961</bibref>.
        <br><br>
        In conversation, Irons described his 1961 parser as a kind of recursive descent.
        Peter Denning
        (<bibref>Denning 1983</bibref>)
        gives priority to Irons and,
        as a grateful former student of Irons,
        that is of course my preference on
        a personal basis.
      </footnote>.
      Except to say that he deals properly with them, Lucas does not say
      how he parses operator expressions.
      But it is easy to believe Lucas'
      claim -- by this time the techniques for
      parsing operator expressions are well understood<footnote>
        <bibref>Lucas 1961</bibref>
        cites
        <bibref>Samuelson and Bauer 1960</bibref>.
      </footnote>.
    </p>
    <h1>The Operator Issue as of 1961</h1>
    <p>The results of 1961 transform the Operator Issue.
      Up until ALGOL,
      parsing has essentially
      been parsing operator expressions.
      After ALGOL, almost all languages will be block-structured
      and ad hoc string manipulatons will no longer be adequate --
      the language as a whole will require a serious parsing technique.
      Parsing operator expressions will be a side show.
      Or so it seems.
    </p>
    <p>
      Why not use the
      algorithms that parse operator expressions for the whole
      language?
      <bibref>Samuelson and Bauer 1959</bibref>
      had suggested
      exactly that.
      But, alas, operator expression parsing is not adequate for
      languages as a whole<footnote>
        But see the entry for 1973 on Pratt parsing
        (<bibref>Pratt 1973</bibref>)
        where the idea of parsing
        entire languages as operator grammars is revisited.
      </footnote>.
    </p>
    <p>Also, as of 1961, we have BNF.
      This gives us a useful notation
      for describing grammars.
      BNF allows us to introduce our Basic Operator Grammar (BASIC-OP):
    </p>
    <pre id="g-basic-op"><tt>
      S ::= E
      E ::= E + T
      E ::= T
      T ::= T * F
      T ::= F
      F ::= number
    </tt></pre>
    <p><a href="#g-basic-op">BASIC-OP</a>
      has two operators, three levels of precedence
      and left associativity.
      This is enough to challenge the primitive parsing techniques in use
      before 1961.
      Surprisingly, this simple grammar will continue to bedevil mainstream parsing theory for the
      next half a century.
    </p><p>
      Recursive descent, it turns out,
      cannot parse
      <a href="#g-basic-op">BASIC-OP</a>
      because it is left recursive.
      And that is not the end of it.
      Making addition and multiplication right-associate
      is unnatural and,
      as the authors of the IT compiler had found out,
      causes users to revolt.
      But suppose we try to use this
      Right-recursive Operator Grammar (RIGHT-OP)
      anyway:
    </p>
    <pre id="g-right-op"><tt>
      S ::= E
      E ::= T + E
      E ::= T
      T ::= F * T
      T ::= F
      F ::= number
    </tt></pre>
    <p>
      Recursive descent, without help,
      cannot parse
      <a href="#g-right-op">RIGHT-OP</a>.
      As of 1961,
      parsing theory has not developed well enough to
      state why in a precise terms.
      Suffice it to say for now
      that
      <a href="#g-rr">RIGHT-OP</a>
      requires too much lookahead.
    </p>
    <p>But recursive descent does have a huge advantage,
      one which, despite its severe limitations,
      will save it from obsolescence time and again.
      Hand-written recursive descent is essentially calling
      subroutines.
      Adding custom modification to recursive descent
      is very straight-forward.
    </p>
    <p>
      In addition,
      while pure recursive descent cannot
      <em>parse</em>
      operator expressions,
      it can
      <em>recognize</em>
      them.
      This means pure recursive descent may not be able to create
      the parse subtree for an operator expression itself,
      but it can recognize the expression and hand control
      over to a specialized operator expression parser.
      This seems to be what Lucas' 1961 algorithm did,
      and it is certainly what many other implementations did afterwards.
      Adding the operator expression subparser makes the implementation
      only quasi-Chomskyan,
      but this is a price the profession
      will be willing to pay.
    </p>
    <p>Alternatively,
      a recursive descent implementation can parse operator expressions
      as lists,
      and add associativity in post-processing.
      This pushes some of the more important parsing
      out of the syntactic phase into the semantics
      but, once again,
      it seems that
      Chomskyan purity will have to be thrown overboard
      if the ship is to stay afloat.
    </p>
    <p>Bottom line: as of 1961 the Operator Issue takes a new form.
      Because of the Operator Issue,
      recursive descent is not
      sufficient for practical grammars -- it must always be part of a
      hybrid.
    </p>
    <p>In this context,
      Dijkstra's new 1961 algorithm is a welcome alternative:
      as an operator expression subparser,
      it can parse operator expressions faster and in less space.
      But Dijkstra's algorithm has no more parsing power
      than the classic operator
      precedence algorithm --
      it does nothing to change the basic tradeoffs.
    </p>
    <h1>1964: The Meta II compiler</h1>
    <p>Schorre publishes a paper on the Meta II
      <q>compiler
        writing language</q>, summarizing the papers of the 1963
      conference. Schorre cites both Backus and Chomsky as sources for
      Meta II's notation.
      Schorre notes that his parser is
      <q>entirely different</q>
      from that of
      <bibref>Irons 1961</bibref>
      --
      in fact, it is non-Chomskyan.
      Meta II is a template, rather than something that
      his readers can use, but in principle it can be turned into a fully
      automated compiler-compiler<footnote>
        <bibref>Schorre 1964</bibref>, p. D1.3-1.
      </footnote>.
    </p>
    <h1 id="text-term-linear">Term: "linear"</h1>
    <p>
      Among
      <a href="#loc-parsing-problem">the goals</a>
      for the ideal
      ALGOL parser was that it be
      <q>efficient</q>.
      By 1965 this notion becomes more precise,
      thanks to a notation that Knuth borrows from
      calculus.
      This
      <q>big O</q>
      notation characterizes algorithms
      using functions, but it treats functions that
      differ by a constant multiple as identical<footnote>
        This timeline is not a mathematics tutorial,
        and I have ignored important complications to
        avoid digression.
        For interested readers,
        the details of "big O"
        notation are worth learning:
        <bibref>Wiki Big O</bibref>.
      </footnote>.
      <q>Ignoring the constant</q>
      means that conclusions
      drawn from
      <q>big O</q>
      results stay relevant in the face of steady improvements
      in technology.
    </p>
    <p>
      These big O functions take as their input some aspect of the algorithm's
      input.
      In the case of parsing, by convention,
      the big O function is usually a function
      of the length of the input<footnote>
        Because constants are ignored, all reasonable measures of
        the length are equivalent for
        <q>big O</q>
        notation.
        Some papers on parsing also consider the size of the grammar,
        but usually size of the grammar is regarded as a fixed constant.
        In this timeline all
        <q>big O</q>
        results will be
        in terms of the input length.
      </footnote>.
      Of the many possible
      <q>big O</q>
      functions,
      only a few will be of interest in this timeline.
    </p><ul>
      <li>A function which grows steadily as the input grows
        is called
        <term>linear</term>.
        In
        <q>big O</q>
        notation,
        <term>linear</term>
        is
        written O(n).
      </li>
      <li>A function which grows as the length of the input times
        its logarithm is almost linear:
        <term>quasi-linear</term>.
        In
        <q>big O</q>
        notation,
        <term>quasi-linear</term>
        can be
        written O(n*log n).
      </li>
      <li>A function which grows as the square of the length
        is called
        <q>quadratic</q>
        -- O(n**2).
      </li>
      <li>A function which grows as the cube of the length
        is called
        <q>cubic</q>
        -- O(n**3).
      </li>
      <li>In extreme cases,
        a function can grow as a constant taken to the power
        of the length, or
        <term>exponentially</term>
        --
        O(c**n).
      </li>
    </ul>
    <p>
      By this time,
      <q>efficient</q>
      for a parser means
      <q>linear</q>
      or
      <q>quasi-linear</q>.
      Parsers which operate in quadratic, cubic, or exponential
      time are
      considered impractical.
      But parsers aimed at practitioners will often push the
      envelope --
      any parser which uses backtracking is potentially exponential
      and is designed in the (often disappointed) hope
      that the backtracking will not
      get out of hand
      for the grammar of interest to the user.
    </p>
    <h1 id="text-1965-knuth">1965: Knuth discovers LR</h1>
    <p>Donald Knuth answers<footnote>
        <bibref>Knuth 1965.</bibref>.
      </footnote>
      the challenge expressed
      a few years earlier by
      <a href="#text-1960-Oettinger">Oettinger</a>.
      Oettinger had hoped for a theory of stack-based
      parsing
      to replace "ad hoc invention".<footnote>
        <bibref>Oettinger 1960</bibref>, p. 127.
      </footnote>
      Knuth responds with a theory that
      encompasses all the "tricks"<footnote>
        Knuth 1965, p. 607, in the abstract.
      </footnote>
      used for efficient parsing up to that time.
      In an exhilarating and exhausting 39-page
      paper,
      Knuth shows that stack-based parsing is
      equivalent to a new class of grammars.
      Knuth calls this new class, LR(k).
      Knuth also provides a parsing algorithm for the
      LR(k) grammars.
    </p>
    <p>
      Knuth's new LR parsing algorithm is deterministic,
      Chomskyan and bottom-up.
      It might be expected to be "the one to rule
      them all".
      Unfortunately, while linear,
      it is not practical.
    </p>
    <p>
      LR(k) is actually a set of grammar classes.
      There is a grammar class for every
      <tt>k</tt>,
      where
      <tt>k</tt>
      is the amount of lookahead used.
      LR(0) requires no lookahead,
      but it is not practical because it is too weak
      to parse most grammars of interest.
      LR(1) is not practical 
      because of the size of the tables it requires --
      well beyond what can be done with 1965
      hardware.<footnote>
        Given the capacity of computer memories in 1965,
        LR(1) was clearly impractical.
        With the huge computer memories of <thisyear>,
        that could be reconsidered,
        but even today LR(1) is rare in practical use.
	LR(1) shares 
	the poor error-handling that
        the LR(k)-based parsers became known for.
	And, since
        LR(1) is still very limited in its power
	compared to LRR,
	it just does not seem to be worth it.
      </footnote>
      </p>
      <p>And, as the
      <tt>k</tt>
      in
      LR(k)
      grows, things get rapidly worse.
      The size of the tables grows exponentially,
      while the value of the additional lookahead rapidly diminishes.
      It is not likely that
      LR(2)
      parsing will ever see much actual use,
      never mind
      LR(k) for any <tt>k</tt>
      greater than 2.
    </p>
    <h1>"Language" as of 1965</h1>
    <p><bibref>Knuth 1965</bibref>
      uses the Bloomfieldian definition of
      language,
      following the rest
      of the parsing literature at this time.
      In other words, Knuth defines a language
      a "set of strings", without regard
      to their meaning.
      The Bloomfieldian definition,
      while severely restrictive,
      has yet to cause any recognizable harm.
    </p>
    <p>
      To keep these things straight,
      I will borrow two terms from linguistics:
      "intension" and "extension".
      For this discussion,
      I will speak of the "set of strings" that make
      up a language as its
      <b>extension</b>.
      If you are a Bloomfieldian,
      a language
      <b>is</b>
      its extension.
    </p>
    <p>The vast majority of people has always thought that,
      to be considered a language,
      a set of strings has to have a semantics --
      that is, the strings must mean something.
      I will call the semantics of a language
      its
      <b>intension</b>.<footnote>
        In this document
        I will usually speak of a language intension as if it was
        a BNF grammar.
	Admittedly,
        this is a very simplified view of semantics.
	Treating semantics as reducible to the tagged trees produced
	by parsing a BNF grammar
        not only assumes that the language is pure context-free,
        it is not even adequate for most computer
        applications.
	Most applications require at least some kind
        of post-processing.
        <br><br>
        But this is not a formal mathematical presentation.
        and for our purposes,
        we do not need to actually represent a semantics,
        just the interface to it.
        And the grammars we consider are almost always
        context-free.
      </footnote>
      A language is extensional
      (or Bloomfieldian) if it consists only of an
      extension.
      A language is intensional
      if it consists of both an intension and
      an extension.
      (All languages have extensions.<footnote>
      The empty set counts as an extension.
      </footnote>)
      For most people, the term "language" means
      an intensional language.
    </p>
    <p>
      As of 1965, you can argue that using the Bloomfieldian definition
      has been helpful.
      It
      <b>is</b>
      easier to do math with an extensional language.
      And the results for its extension sometimes do apply
      to an intensional language.
      For example, Chomsky, to demonstrate the
      superiority of his model over Markov chains,
      showed that the extension of his model of English
      contains strings which clearly are English,
      but which are not predicted by Markov chains.
      Obviously, your model of an intensional language is wrong
      if its extension is wrong,
      and if you can discover that without delving into
      semantics, all the better.
    </p>
    <p>
      Knuth wants to show a relationship
      between his LR grammars,
      and the mathematical literature on
      stack-based parsing (DPDA's).
      The trouble is, the DPDA literature is
      entirely non-Chomskyan --
      all of its results are in terms of sets
      of strings.
      Knuth is forced to
      "compare apples to oranges"
    </p>
    <p>
      How do you show that string-sets
      are the equivalent of grammars?
      What Knuth does is treat them both as string-sets -- extensions.
      Knuth compares the language extensions of the LR grammars
      to the sets of strings recognized by the DPDA's.
    </p>
    <p>The result certainly seems encouraging.
      It turns out that the language extension of
      deterministic stack machines
      is
      <b>exactly</b>
      that of the
      LR
      grammars.
    </p>
    <p>
      If you take language extensions as the proxy for grammars,
      things fall into place very neatly:
      the
      LR-parsers are the deterministic subset of the
      context-free parsers.
      And "deterministic" seems like a very good approximation
      of practical.
      All practical parsers in 1965 are
      deterministic parsers.<footnote>
      As of 1965,
      the Irons parser has fallen out of favor
      and <a href="#text-1961-sakai">Sakai parsers</a>
      are still being forgotten and rediscovered.
      </footnote>
    </p>
    <p>
      Viewed this way,
      LR-parsing looks like the theoretical equivalent
      of practical parsing --
      at least it is
      as close to an exact equivalent of practical parsing
      as theory is likely to get.
      Based on the algorithms of
      <bibref>Knuth 1965</bibref>,
      that means that the theoretical equivalent of "practical
      parsing" is somewhere between LR(0) and LR(1).
    </p>
    <p id="text-LR-hierarchy-collapse">Not all the signs are promising, however.
      In fact, one of them is ominous.
      LR
      grammars form a hierarchy --
      for every
      k&#8805;0,
      there is an
      LR
      grammar which
      is
      LR(k+1), but which is not
      LR(k).
      But if you just look at sets of strings,
      this hierarchy pancakes.
      Every
      LR(k)
      language extension is also
      an
      LR(1)
      language extension,
      as long as
      k&#8805;1.
    </p>
    <p>It gets worse.
      In most practical applications,
      you can add an end-of-input marker to a grammar.<footnote>
        The exception are applications which receive their input "on-line";
        which can not determine the size of their input in advance;
        and which must return a result in a fixed amount of time.
        For this minority of applications,
	adding an end marker to their input
        is not possible.
      </footnote>,
      If you do this,
      every
      LR(k)
      language extension is also an
      LR(0)
      language extension.
      In terms of strings-sets,
      there is no LR hierarchy:
    </p><center>
      LR(0)&nbsp;=&nbsp;LR(1)&nbsp;=&nbsp;LR(2)&nbsp;=&nbsp;&nbsp;&nbsp;...&nbsp;&nbsp;=&nbsp;LR(42)&nbsp;=&nbsp;&nbsp;...
    </center>
    <p>In short,
      as a proxy for LR grammars,
      LR language extensions look like they might be completely worthless.<footnote>
        None of these problematic signs escaped Knuth.
        He discovers and proves them on pp. 630-636.
        But Knuth seemed to consider the LR hierarchy collapse a
        mathematical curiousity,
        and one with no implications for practical parsing.
      </footnote>
    </p>
    <h1 id="text-1965-parsing-problem">The Parsing Problem as of 1965</h1>
    <p>
      While the algorithm of
      <bibref>Knuth 1965</bibref>
      does not solve the Parsing Problem,
      it convinces most that stack-based,
      and therefore LR, parsing
      is the framework for the solution.<footnote>I deal with the implications of
        <bibref>Knuth 1965</bibref>
        for parsing theory
        at greater length in these blog posts:
        <bibref>Kegler Strings 2018</bibref>,
        <bibref>Kegler Solved 2018</bibref>,
        and
        <bibref>Kegler Undershoot 2018</bibref>.
      </footnote>
      To be sure,
      there is no proof,
      but the reasoning is persuasive:
    </p>
    <ul>
      <li>In 1965, every practical parser is stack-driven.<footnote>
      Table-driven Sakai parsers have already been described in the parsing literature,
      but they will keep being rediscovered until 1969.
      That the journal referees keep accepting descriptions of Sakai parsing
      as new research
      suggests that table parsers are seeing little or no
      actual usage.
      </footnote></li>
      <li>An algorithm that combines state transitions and stack operations is
        already a challenge to existing machines.
        In 1965, any more complicated algorithm is likely to be unuseable
        in practice.<footnote>
          In 1964, advocates of stack-based parsing would not
          have been seen themselves as settling for a "safe"
          or "traditional" solution.
          <a href="#text-1960-Oettinger">As
            recently as 1960</a>, readers of technical journals were
          not expected to know what a stack was.
        </footnote>
      </li>
      <li>For LR(k) grammars, practical parsing is bracketed somewhere
        between LR(0) and LR(1).</li>
      <li>In terms of what the parsing literature calls "languages"
        (extensional languages),
        LR(k) parsing is the exact equivalent of deterministic stack-based parsing.</li>
      <li>Determinism is always linear and, at least in terms of speed,
      linear is almost always practical.</li>
      <li>In 1965, every practical parser is deterministic.</li>
      <li>In general, power is a trade-off for speed.</li>
    </ul>
    <p>
      There are also aesthetic reasons to
      think that this theoretical equivalent for practical
      parsing is not all that rough.
      Recall that deterministic stack-based parsing is
      "exactly" LR-parsing.
      It is also the case
      that non-deterministic stack-based parsing is
      "exactly" context-free parsing.
      This symmetry is very elegant,
      and suggests that the theoreticians have uncovered
      the basic laws behind parsing.
    </p>
    <p>
      Of course, "exactly" here means "exactly in terms of extensions".
      Extensions are used in this reasoning,
      while the actual interest is in intensions.
      <a href="#text-LR-hierarchy-collapse">And for extensions
        the LR hierarchy collapses</a>.
      But in 1965 these things that are 
      not considered troubling.
    </p>
    <p>
      After all, there is no exact theoretical equivalent
      of "practical" --
      you always have to settle for a more or less rough equivalent.
      Reasoning in terms of extensions had not bitten anyone yet.
      And, while nobody had been more authoritative about the limits of
      extensions as a definition of language than Chomsky
      (he had literally written the book),
      Chomsky himself had 
      used extensions
      to produce some of his most
      impressive results.
    </p>
    <p>
      After 1965, the consensus
      excludes the idea that algorithms which target supersets of LR(k) might be faster than those that take on LR(k)
      directly.<footnote>
        <bibref>Knuth 1965</bibref>, p. 637.
        Knuth's own language is cautious,
        so it is not 100% clear
        that he believes that the
        future of practical parsing theory lies
        in the pursuit of LR(k) subsets.
        His program for further research
        (Knuth 1961, pp. 637-639)
        also suggests investigation of parsers for superclasses
        of LR(k).
        Indeed,
        Knuth shows (p. 638)
        that he is well aware that some grammars
        beyond LR(k) can be parsed in linear time.
        Knuth also is very much aware (p. 638) that
        it is an open question whether all context-free grammars
        can be parsed in linear time.
        <br><br>
        Knuth even describes a new superclass of his own:
        LR(k,t), which is LR(k) with more aggressive lookahead.
        But Knuth introduces LR(k,t) in dismissive terms:
        "Finally, we might mention another generalization of LR(k)"
        (Knuth 1965, p. 638); and
        "One might choose to call this left-to-right translation,
        although we had to back up a finite amount."
        (p. 639).
        <br><br>
        It is reasonable to suppose
        that Knuth is even more negative about
        the more general approaches that
        he does not bother to mention.
        Knuth's skepticism of more general Chomskyan approaches
        is also suggested by his own plans for his (not yet released) Chapter
        12 of the
        <cite>Art of Computer Programming</cite>,
        in which he planned to use pre-Chomskyan bottom-up methods
        (<bibref>Knuth 1990</bibref>, p. 3).
        <br><br>
        In
        <bibref>Knuth 1965</bibref>
        (pp. 607-608),
        Knuth had emphasized that
        proceeding strictly left-to-right
        is necessary for efficiency reasons.
        So subsequent researchers were probably correct in
        reading into Knuth a prediction that
        research into beyond-LR(k)
        parsing would be not be fruitful.
        Regardless of what Knuth himself believed,
        the consensus of the parsing theorists is not
        in doubt:
        interest in beyond-LR parsing will almost disappear
        after 1965.
        The theorist's attention will be focused almost
        exclusively on Knuth's suggestions for research within the stack-based
        model (p. 637).
        These included grammar rewrites;
        streamlining of the LR(k) tables;
        and research into LR(k) subclasses.
      </footnote>.
      But, what if the LR language hierarchy collapse is a real
      problem?
      If we remove the evidence based on language extensions from the list above,
      all we have left are couple of over-generalizations.
      So the question remains:
    </p><blockquote>
      Is there a non-deterministic parser that is linear for
      the LR(k) grammars, or even a superset of them?
    </blockquote>
    <p>
      This question will be answered
      <a href="#text-1991-Leo">
        by Joop Leo in 1991</a>.
      The answer, surprisingly, will be
      <q>yes</q>.
    </p>
    <h1>The Operator Issue as of 1965</h1>
    <p><bibref>Knuth 1965</bibref>
      is a significant milestone
      in the history of operator expresssion parsing.
      Knuth specifically addresses the parsing of ALGOL
      and he zeroes in on its arithmetic expressions
      as the crucial issue<footnote>
        Knuth also discusses some ambiguities,
        and some intermixing of semantics with syntax,
        in the
        ALGOL report.
        But Knuth (quite appropriately)
        notes that BNF was new when it was written,
        and treats these other issues
        as problems with the ALGOL specification.
        (See
        <bibref>Knuth 1965</bibref>, pp. 622-625.)
      </footnote>.
      Knuth suggests a "typical" grammar<footnote>
        <bibref>Knuth 1965</bibref>, p. 621.
      </footnote>
      which is short,
      but encapsulates the parsing challenges
      presented by ALGOL's arithmetic expressions:
    </p><pre id="g-knuth-op"><tt>
      S ::= E
      E ::= - T
      E ::= T
      E ::= E - T
      T ::= P
      T ::= T * P
      P ::= a
      P ::= ( E )
    </tt></pre>
    <p><a href="#g-knuth-op">KNUTH-OP</a>
      is left-recursive,
      allows parentheses,
      has three levels of precedence,
      and implements both unary and
      binary minus.
      Recursive descent cannot parse
      <a href="#g-knuth-op">KNUTH-OP</a>,
      but <a href="#g-knuth-op">KNUTH-OP</a>
      is LR(1).
      The means that it is well within Knuth's new
      class of grammars and,
      by implication,
      probably within a practical subclass of the
      LR grammars.
    </p>
    <h1>1968: Lewis and Stearns discover LL</h1>
    <p>When Knuth discovered the LR grammars, he announced them to
      the world with a full-blown mathematical description.
      The top-down
      grammars, which arose historically,
      have lacked such a description.
      In 1968,
      Lewis and Stearns fill that gap by defining the LL(k) grammars<footnote>
        <bibref>Lewis and Stearns 1968</bibref>.
        They are credited in
        <bibref>Rosencrantz and Stearns 1970</bibref>
        and
        <bibref>Aho and Ullman 1972</bibref>, p. 368.
      </footnote>.
    </p>
    <h1>Terms: "LL" and "LR"</h1>
    <p>When LL is added to the vocabulary of parsing, the meaning of
      <term>LR</term>
      shifts slightly. In 1965 Knuth defined LR to mean
      <q>translatable from left to right</q><footnote>
        <bibref>Knuth 1965</bibref>, p. 610.
        See also on p. 611
        "corresponds with the intuitive notion of translation
        from left to right looking k characters ahead".
      </footnote>.
      But LL means
      <q>scan from the left, using left reductions</q>
      and, in response, the meaning of LR shifts to become
      <q>scan from the left, using
        right reductions</q><footnote>
        <bibref>Knuth 1971</bibref>, p. 102.
        LL and LR have mirror images: RL means
        <q>scan from the right,
          using left reductions</q>
        and RR acquires its current meaning
        of
        <q>scan from the right, using right reductions</q>.
        Practical use of these
        mirror images is rare, but it may have occurred
        in one of the algorithms in our timeline
        --
        operator expression parsing
        in the IT compiler seems to have been RL(2) with backtracking.
      </footnote>.
    </p><p>If there is a number in parentheses in this notation for
      parsing algorithms, it usually indicates the number of tokens of
      lookahead.
      For example, LL(1) means
      <q>scan from the
        left, using left reductions with one character of lookahead</q>.
      LL(1) will be important in what follows.
    </p>
    <h1>The Operator Issue as of 1968</h1>
    <p>
      With
      <bibref>Knuth 1965</bibref>
      and
      <bibref>Lewis and Stearns 1968</bibref>,
      we can now restate the problem with recursive descent
      and operator expressions in precise terms:
      Recursive descent
      in its pure form,
      is LL(1).
      Arithmetic operator grammars are not LL(1) -- not even close.
      In fact,
      of the grammars
      <a href="#g-basic-op">BASIC-OP</a>,
      <a href="#g-right-op">RIGHT-OP</a>,
      and
      <a href="#g-knuth-op">KNUTH-OP</a>,
      none is LL(k) for any k.
    </p>
    <p>A common work-around is to have recursive descent parse
      arithmetic expressions as lists,
      and add associativity in post-processing.
      We are now able to look at this in more detail.
      An extended BNF grammar to recognize
      <a href="#g-basic-op">BASIC-OP</a>
      as a list is as follows:
    </p><pre id="g-elist-op"><tt>
      S  ::= E
      E  ::= T { TI }*
      TI ::= '+' T
      T  ::= F { FI } *
      FI ::= 'x' F
      F  ::= number
    </tt></pre><p>
      In the above
      <tt>{Z}*</tt>
      means
      <q>zero or more occurences of Z</q>.
      Expanded into pure BNF,
      and avoiding empty right hand sides,
      our operator "list" grammar becomes
      LIST-OP:
    </p><pre id="g-list-op"><tt>
      S  ::= E
      E  ::= T TL
      E  ::= T
      TL ::= TI
      TL ::= TI TL
      TI ::= '+' T
      T  ::= F FL
      T  ::= F
      FL ::= FI
      FL ::= FI FL
      FI ::= 'x' F
      F  ::= number
    </tt></pre>
    <p><a href="g-list=op">LIST-OP</a>
      is LL(1),
      and therefore can be parsed directly
      by recursive descent.
      Note that in
      <a href="g-list-op">LIST-OP</a>,
      although associativity must be provided by a post-processor,
      the grammar enforces precedence.
    </p>
    <h1>1968: Earley's algorithm</h1>
    <p>Jay Earley discovers the algorithm named after him<footnote>
        <bibref>Earley 1968</bibref>.
      </footnote>.
      Like the Irons
      algorithm, Earley's algorithm is Chomskyan, declarative and fully
      general. Unlike the Irons algorithm,
      it does not backtrack. Earley's
      algorithm is both top-down and bottom-up at once -- it uses dynamic
      programming and is table-driven. Earley's approach
      makes a lot of sense and looks very promising indeed, but
      it has
      three serious issues:</p>
    <ul>
      <li>First, there is a bug in the handling of zero-length rules.</li>
      <li>Second, it is quadratic for right recursions.</li>
      <li>Third, table-driven parsing is,
        by the standards of 1968 hardware, daunting.</li>
    </ul>
    <h1>1968: Attribute grammars</h1>
    <p>Irons' synthesized attributes had always been inadequate for many
      tasks.
      Until now, they had been supplemented by side effects or state
      variables.
      In 1968,
      Knuth publishes a paper on a concept he had been working for the
      previous few years: inherited attributes<footnote>
        <bibref>Knuth 1968</bibref>.
      </footnote>.
    </p>
    <h1>Term: "Inherited attributes"</h1>
    <p>Recall that a node in a parse
      gets its synthesized attributes from
      its children. Inherited attributes are attibutes
      that a node gets from
      its parents.
      Of course, if both inherited and synthesized attributes
      are used, there are potential circularities.
      But
      inherited attributes are powerful and, with care, the circularities
      can be avoided.</p>
    <h1>Term: "Attribute grammar"</h1>
    <p>An attribute grammar is a grammar whose nodes may have both inherited and synthesized attributes.</p>
    <h1>1969: LALR</h1>
    <p>Since
      <bibref>Knuth 1965</bibref>,
      many have taken up his challenge to find a
      practically parseable subset of the LR(k) languages.
      In 1969,
      Frank DeRemer describes a new variant of Knuth's LR
      parsing<footnote>
        <bibref>DeRemer 1969</bibref>
      </footnote>.
      DeRemer's LALR algorithm requires only a stack and a state
      table of quite manageable size.
      LALR looks practical,
      and can parse
      <a href="#g-knuth-op">KNUTH-OP</a>.
      LALR will go on to become the most widely used of the LR(k)
      subsets.
    </p>
    <h1>1969: the
      <tt>ed</tt>
      editor</h1>
    <p>Ken Thompson writes the
      <tt>ed</tt>
      editor as one of the
      first components of UNIX<footnote>
        <bibref>Darwin 1984</bibref>,
        Section 3.1, "An old editor made new".
      </footnote>.
      Before 1969,
      regular expressions were an
      esoteric mathematical formalism. Through the
      <tt>ed</tt>
      editor
      and its descendants, regular expressions become an everyday
      part of the working programmer's toolkit.</p>
    <h1>1972: Aho and Ullman is published</h1>
    <p>Alfred Aho and Jeffrey Ullman publish
      the first volume<footnote>
        <bibref>Aho and Ullman 1972</bibref>.
      </footnote>
      of
      their two volume textbook
      summarizing the theory of parsing.
      As of <thisyear>,
        <bibref>Aho and Ullman 1972</bibref>
	will still be important.
	It will also be
      distressingly up-to-date -- progress in parsing theory
      will slow dramatically after 1972.
    </p>
    <p>
      Aho and Ullman's version
      of Earley's algorithm includes
      a straightforward fix to the zero-length rule bug in Earley's
      original<footnote>
        <bibref>Aho and Ullman 1972</bibref>, p 321.
      </footnote>.
      Unfortunately, this fix involves adding even
      more bookkeeping to Earley's.
    </p>
    <p id="text-GTDPL">Under the names TDPL and GTDPL, Aho and Ullman investigate
      the non-Chomksyan parsers in the Schorre lineage<footnote>
        <bibref>Aho and Ullman 1972</bibref>, pp. 456-485.
      </footnote>. They note that
      <q>it can be quite difficult to determine what language is
        defined by a TDPL parser</q><footnote>
        <bibref>Aho and Ullman 1972</bibref>, p. 466.
      </footnote>.
      At or around this time, rumor has it that the main line of
      development for GTDPL parsers is classified secret by the US
      government<footnote>
        <bibref>Simms 2014</bibref>.
      </footnote>.
      Whatever the reason, public interest in GTDPL fades.</p>
    <h1 id="text-1973-LRR">1973: LRR</h1>
    <p>An article by &#268;ulik and Cohen
      extends the idea behind LR to
      grammars with infinite lookahead.<footnote>
        <bibref>&#268;ulik and Cohen 1973</bibref>.
        &#268;ulik and Cohen give an algorithm for parsing LRR,
        but the obstacles to implementation are daunting.
        (See
        <bibref>Grune and Jacobs 2008</bibref>,
        pp. 327-333 and Problem 9.28 on p. 341.)
        Their algorithm did not come into practical use,
        and as of 1991 LRR grammars could be
        handled more easily by
        <a href="#text-1991-Leo">Joop Leo's algorithm</a>.</footnote>
      LR-regular (LRR) grammars are LR with lookahead that is
      infinite but restricted.
      The restriction is that to tell the strings apart,
      you must use a finite set of regular expressions.
    </p>
    <p>LRR seems to be a natural class of grammars,
      coming close to capturing the idea of "eyeball grammars" --
      grammars that humans can spot by "eyeball".
      And, despite computer languages being designed around the idea
      that practical parsing falls short of LR(1), never mind LRR,
      constructs requiring infinite lookahead will come up in real languages.<footnote>
        Haskell list comprehension, for example, requires infinite lookahead --
        see
        <bibref>Kegler Haskell 2018</bibref>.
        (Haskell's native parser deals with this in post-processing.)
      </footnote>
    </p>
    <h1>1973: Pratt parsing</h1>
    <p>As we have noted pure LL(1) cannot parse operator expressions,
      and so operator expression parsers are often called into service
      as subparsers.
      What about
      making the entire grammar an operator grammar?
      This idea had already occurred to Samuelson and Bauer in 1959.
      In 1973, Vaughan Pratt revives it<footnote>
        <bibref>Pratt 1973</bibref>.
      </footnote>.
    </p>
    <p>There are problems with switching to operator
      grammars.
      Operator grammars are non-Chomskyan -- the BNF no longer
      accurately describes the grammar.
      Instead the BNF becomes part of
      a combined notation, and the actual grammar parsed depends also on
      precedence, associativity,
      and semantics.
      And operator grammars have a very restricted
      form -- most practical languages are not operator grammars.</p>
    <p>But many practical grammars are almost operator grammars. And the
      Chomskyan approach has always had its dissenters.
      Vaughn Pratt is one
      of these, and discovers a new approach
      to operator expression parsing:
      Pratt parsing is the third and last approach in
      Theodore
      Norvell's taxonomy of approaches to operator expression
      parsing<footnote>
        <bibref>Norvell 1999</bibref>.
      </footnote>.
      Some have adopted Pratt parsing
      as the overall solution to their parsing problems<footnote>
        <bibref>Pratt 1973</bibref>, p. 51.
      </footnote>.
    </p>
    <p>As of <thisyear>, the Pratt approach
      will not be popular as an overall strategy.
      Under the name precedence climbing,
      it will most often be used
      as a subparser within a recursive descent strategy.
      All
      operator expression subparsers break the Chomskyan paradigm so the
      non-Chomskyan nature of Pratt's parser is not a problem in this
      context.
    </p>
    <h1>1975: The C compiler is converted to LALR</h1>
    <p>Bell Labs converts its C compiler from hand-written recursive
      descent to DeRemer's LALR algorithm<footnote>
        <bibref>Synder 1975</bibref>.
        See, in particular, pp. 67-68.
      </footnote>.
    </p>
    <h1>1977: The first dragon book is published</h1>
    <p>The first
      <q>dragon book</q><footnote>
        <bibref>Aho and Ullman 1977</bibref>.
      </footnote>
      comes out. This soon-to-become
      classic textbook is nicknamed after the drawing on the front cover,
      in which a knight takes on a dragon. Emblazoned on the knight's lance
      are the letters
      <q>LALR</q>. From here on out, to speak lightly
      of LALR will be to besmirch the escutcheon of parsing theory.</p>
    <h1>1979: Yacc is released</h1>
    <p>Bell Laboratories releases Version 7 UNIX<footnote>
        <bibref>McIlroy and Kernighan 1979</bibref>.
      </footnote>.
      V7 includes what is,
      by far, the most comprehensive, useable and easily available compiler
      writing toolkit yet developed.</p>
    <p>Part of the V7 toolkit is Yet Another Compiler Compiler
      (<tt>yacc</tt>)<footnote>
        <bibref>Johnson 1975</bibref>.
      </footnote>.
      <tt>yacc</tt>
      is LALR-powered. Despite its name,
      <tt>yacc</tt>
      is the first
      compiler-compiler in the modern sense.
      For a few useful languages, the
      process of going from Chomskyan specification to executable
      is now fully automated.
      Most practical languages, including the C language and
      <tt>yacc</tt>'s own input language, still require manual hackery<footnote>
        See
        <bibref>McIlroy 1987</bibref>, p. 11,
        for a listing of yacc-powered
        languages in V7 Unix.
      </footnote>.
    </p>
    <h1>The Parsing Problem as of 1979</h1>
    <p>
      Recall
      <a href="#loc-parsing-problem">the criteria</a>
      outlined for a solution
      of the Parsing Problem:
      that the parser be
      efficient, general, declarative and practical.
      LALR is linear and runs fast on 1979 hardware.
      LALR seems practical.
      And LALR is declarative.
      True, LALR is very far from general,
      but
      <a href="g-basic-op">BASIC-OP</a>,
      <a href="g-right-op">RIGHT-OP</a>
      <a href="g-right-op">KNUTH-OP</a>
      and
      <a href="g-right-op">LIST-OP</a>
      are all LALR,
      and LALR can parse
      most operator expressions directly.
    </p>
    <p>
      The criteria
      set in
      <a href="#loc-parsing-problem">
        the original statement of
        the Parsing Problem
      </a>
      have not been
      fully met.
      Nonetheless,
      even if there is a certain amount of
      disappointment,
      it seems as if the Parsing Problem
      and the Operator Issue
      can both be declared solved.
      Two decades of research have paid off.
    </p>
    <h1>1987: Perl 1 is released</h1>
    <p>Larry Wall introduces Perl 1<footnote>
        <bibref>Wiki Perl</bibref>,
        <mla_title>Early versions</mla_title>
        section,
        <mla_url>https://en.wikipedia.org/w/index.php?title=Perl&oldid=837585549#Early_versions</mla_url>.
      </footnote>.
      Perl embraces complexity like no
      previous language.
      Larry uses
      <tt>yacc</tt>
      and LALR very aggressively --
      to my knowledge more aggressively than anyone before or since.</p>
    <h1>1990: Monads</h1>
    <p>
      Wadler starts to introduce monads to the functional programming community.
      As one example he converts his previous efforts at functional parsing
      techniques to monads<footnote>
        <bibref>Wadler 1990</bibref>
      </footnote>.
      The parsing technique is pure recursive descent.
      The examples shown for monadic parsing are very simple,
      and do not include operator expressions.
      In his earlier non-monadic work, Wadler had used a very restricted form of operator expression:
      His grammar had avoided left recursion by using parentheses,
      and operator precedence had not been implemented
      <footnote>
        <bibref>Wadler 1985</bibref>.
      </footnote>.
    </p>
    <h1 id="text-1991-Leo">1991:
      Leo's speed-up of Earley's algorithm</h1>
    <p>Joop Leo discovers a way of speeding up right recursions in
      Earley's algorithm<footnote>
        <bibref>Leo 1991</bibref>.
      </footnote>. Leo's algorithm is linear for
      <a href="#text-1973-LRR">
      LRR, a superset of LR(k)</a>.
      That means it is linear for just about every
      unambiguous grammar of practical interest,
      and many ambiguous ones as well.
      As of 1991,
      hardware is six orders of magnitude faster than
      1968 hardware, so that the issue of bookkeeping overhead has receded
      in importance.
      When it comes to speed,
      the game has changed in favor of the Earley algorithm.</p>
    <h1>The Parsing Problem as of 1991</h1>
    <p>Recall that after
      <bibref>Knuth 1965</bibref>,
      the research consensus
      had excluded the possibility that a parser of a superset of the LR(k) languages
      could be practical and linear.
      <a href="#text-1965-parsing-problem">The argument from Knuth</a>
      had been highly suggestive.
      It was not actually a proof, but by 1991 many effectively take it as one.
    </p>
    <p>Does Leo's algorithm refute the consensus?
      While not linear in general,
      Leo's non-deterministic algorithm
      <b>is</b> linear for a superset of Knuth's LR(k) grammars.
      But is Leo's algorithm practical?
    </p>
    <p>In 1991, almost nobody asks any of those questions.
    Most researchers see the Parsing Problem as "solved" --
      a closed issue.
      Earley parsing is almost forgotten,
      and Leo's discovery is ignored.
      Two decades will pass before anyone
      attempts a practical implementation of
      <bibref>Leo 1991</bibref>.
    </p>
    <p>If Earley's is almost forgotten,
    then everyone in LALR-land is content,
      right? Wrong. In fact, far from it.
    </p>
    <p>
      As of 1979, LALR seemed practical.
      But by the 1990s users of LALR are making
      unpleasant discoveries.
      While LALR automatically generates their
      parsers, debugging them is so hard they could just as easily write the
      parser by hand.
      Once debugged, their LALR parsers are fast for correct
      inputs.
      But almost all they tell the users about incorrect inputs
      is that they are incorrect.
      In Larry Wall's words, LALR is
      <q>fast
        but stupid</q><footnote>
        <bibref>Wall 2014</bibref>.
      </footnote>.
    </p>
    <h1>The Operator Issue as of 1991</h1>
    <p>
      On the written record, the discontent with LALR and
      <tt>yacc</tt>
      is hard to find.
      What programmer wants to announce to colleagues and
      potential employers that he cannot figure
      how to make the standard state-of-the-art tool work?
      But a movement away from LALR has already begun.
      Parsing practice falls back on
      recursive descent.
      The Operator Issue
      is back in full force.
    </p>
    <h1>1992: Combinator parsing</h1>
    <p>
      Combinator parsing
      is introduced in two papers published this year.<footnote>
        Some sources consider
        <bibref>Wadler 1985</bibref>
        an
        early presentation of the ideas of combinator parsing.
        In assigning priority here,
        I follow
        <bibref>Grune and Jacobs 2008</bibref>
        (p. 564).
      </footnote>
      Of more interest
      to us is <bibref>Hutton 1992</bibref>,
	which focuses on combinator parsing<footnote>
        The paper which is devoted to parsing is
        <bibref>Hutton 1992</bibref>.
        The other paper, which centers on combinators as a programming
        paradigm, is
        <bibref>Frost 1992</bibref>.
        Frost only mentions parsing in one paragraph, and
        that focuses on implementation issues.
        Some of Frost's grammars include operator expressions,
        but these avoid left recursion,
        and implement precedence and associativity,
        using parentheses.
      </footnote>.
      As Hutton explains<footnote>
        <bibref>Hutton 1992</bibref>, p. 5.
      </footnote>
      a combinator is an attribute grammar
      with one inherited attribute (the input string)
      and two synthesized attributes (the value of the node
      and the remaining part of the input string).
      Combinators can be
      <q>combined</q>
      to compose other parsers.
      This allows you to have an algebra of parsers.
      It is an extremely attractive idea.
    </p>
    <p>
      Exciting as the new mathematics is,
      the underlying parsing theory contains
      nothing new --
      it is the decades-old recursive descent,
      unchanged.
      Hutton's example language is extremely basic --
      his operator expressions require left association,
      but not precedence.
      Left association is implemented by post-processing.
    </p>
    <p>
      Hutton's main presentation does not use monads.
      In his final pages, however,
      Hutton points out
      <q>combinator parsers give rise to a monad</q>
      and shows
      how his presentation could be rewritten in a form
      closely related to monads<footnote>
        <bibref>Hutton 1992</bibref>, pp. 19-20.
      </footnote>.
    </p>
    <h1>1995: Wadler's monads</h1>
    <p>
      In the adaptation of monads into the world of
      programming,
      <bibref>Wadler 1995</bibref>
      is a turning point.
      One of Wadler's examples is a parser based on
      monads and combinator parsing.
      Combinator parsing becomes the standard
      example of monad programming.
    </p>
    <p>In its monadic form,
      the already attractive technique of combinator parsing is extremely elegant
      and certainly seems as if it
      <em>should</em>
      solve all parsing problems.
      But, once again, it is still recursive descent,
      completely unchanged.
      Wadler handles left recursion by parsing into
      a list, and re-processing that list
      into left recursive form.
      Wadler's example grammar only has one operator,
      so the issue of precedence does not arise.
    </p>
    <p>
      Instead of one paradigm to solve them all,
      Wadler ends up with a two layered approach,
      with a hackish bottom layer and an awkward interface.
      This undercuts
      the simplicity and elegance of the combinator approach.
    </p>
    <h1>1996: Hutton and Meijer on combinator parsing</h1>
    <p>
      <bibref>Wadler 1995</bibref>
      used parsing as an example to motivate
      its presentation of monads.
      Graham Hutton and Erik Meijer<footnote>
        <bibref>Hutton and Meijer 1996</bibref>.
      </footnote>
      take the opposite perspective -- they
      write a paper on combinator parsing that could
      <q>also be viewed as a first introduction to the use
        of monads in programming.</q><footnote>
        <bibref>Hutton and Meijer 1996</bibref>,
        p. 3.
      </footnote>
    </p>
    <p>The most complicated grammar<footnote>
        <bibref>Hutton and Meijer 1996</bibref>, p. 18.
        A simpler arithmetic expression grammar on p. 15 raises no issues
        not present in the more complicated example.
      </footnote>
      for operator expressions in
      <bibref>Hutton and Meijer 1996</bibref>
      has two operators (exponentiation and addition)
      with two levels of precedence
      and two different associativities:
      exponentiation associates right
      and
      addition associates left.
    </p>
    <p>
      The approach to parsing taken in
      <bibref>Hutton and Meijer 1996</bibref>
      will
      be familiar by now:
      Precedence is provided by the combinator parser
      which parses operators and operands of the same
      precedence into lists.
      Associativity is provided by re-processing the
      lists.
    </p>
    <h1>The Operator Issue as of 1996</h1>
    <p>As we have seen,
      the literature introducing monads and combinator
      parsing added nothing to what was already known
      about parsing algorithms.
      We have focused on it for three reasons:
    </p>
    <ul>
      <li>
        Functional programming has had a profound influence
        on the way the profession sees parsing.
        That influence will probably grow.
      </li>
      <li>The literature shows
        the relative popularity among
        one group of highly skilled programmers
        of LALR and recursive descent.
        LALR is not mentioned once in any of the
        articles surveyed.
      </li>
      <li>
        The functional programming literature
        shows that the
        Operator Issue,
        once thought solved,
        is as live an issue in the 1990's
        as it was at the end of 1961.
      </li>
    </ul>
    <h1>2000: The Perl 6 effort begins</h1>
    <p>Larry Wall decides on a radical reimplementation of Perl --
      Perl 6. Larry does not even consider using LALR again.</p>
    <h1>2002: Aycock and Horspool solve Earley's zero-length rule problem</h1>
    <p>John Aycock and R. Nigel Horspool publish their attempt at a
      fast, practical Earley's parser<footnote>
        <bibref>Aycock and Horspool 2002</bibref>.
      </footnote>. Missing from it is Joop Leo's
      improvement -- they seem not to be aware of it. Their own speedup
      is limited in what it achieves and the complications it introduces
      can be counter-productive at evaluation time. But buried in their
      paper is a solution to the zero-length rule bug. And this time the
      solution requires no additional bookkeeping.</p>
    <h1>2004: PEG</h1>
    <p>Implementers by now are avoiding
      <tt>yacc</tt>, but the demand for
      declarative parsers remains.
      In 2004,
      Bryan Ford<footnote>
        <bibref>Ford 2004</bibref>.
        See also
        <bibref>Ford 2002</bibref>.
      </footnote>
      fills this gap by
      repackaging the nearly-forgotten
      <a href="#text=GTDPL">GTDPL</a>.
      Ford's new algorithm,
      PEG,
      is declarative, always linear,
      and has an attractive new syntax.</p>
    <p>
      But PEG, like
      <a href="#text-1960-glennie">Glennie's 1960 syntax formalism</a>,
      is pseudo-declarative.
      PEG uses BNF notation,
      but it does not parse the BNF grammar described by the notation:
      PEG achieves unambiguity by finding only a subset of the parses
      of its BNF grammar.
      And, like its predecessor GTDPL,
      in practice it is usually impossible to determine what the subset
      is.
      The best a programmer
      usually can
      do is to create a test suite and fiddle with the PEG description
      until it passes.
      Problems not covered
      by the test suite will be encountered at runtime.
    </p>
    <p>
      PEG takes the old joke that
      <q>the code is
        the documentation</q>
      one step further --
      with PEG it is often the case that
      nothing documents the grammar,
      not even the code.
      Under this circumstance, creating reliable software is impossible.
      As it is usually used,
      PEG is the nitroglycerin of LL parsing --
      slightly more powerful than LL(1), but too dangerous to be worth it.
    </p>
    <p>
      PEG, in safe use, would essentially be LL(1)<footnote>
        <bibref>Mascrenhas et al 2014</bibref>.
        My account of PEG is negative because almost all
        real-life PEG practice is unsafe,
        and almost all of the literature offers no cautions
        against unsafe use of PEG.
        Ford's PEG is efficient
        and does have specialized uses.
        Programmers interested in the safe use of PEG should
        consult
        <bibref>Mascrenhas et al 2014</bibref>.
      </footnote>.
      Those adventurous souls who parse operator expressions under
      PEG typically seem to parse the operator expressions as lists,
      and re-process them in the semantics.
    </p>
    <h1>2006: GNU C reverts to recursive descent</h1>
    <blockquote>The old Bison-based C and Objective-C parser has been replaced by a new, faster hand-written recursive-descent
      parser.<footnote>
        <bibref>FSF 2006</bibref>.
      </footnote>
    </blockquote>
    <p>
      With this single line
      in the middle of a change list hundreds of lines long,
      GNU announces a major event in parsing history.
      (Bison, an LALR parser, is the direct descendant of Steve Johnson's
      <tt>yacc</tt>.)
    </p>
    <p>
      For three decades, the industry's flagship C compilers have
      used LALR as their parser -- proof of the claim that LALR and serious
      parsing are equivalent.
      Now, GNU replaces LALR with the technology
      that LALR replaced a quarter century earlier: recursive descent.</p>
    <h1>2010: Leo 1991 is implemented</h1>
    <p>Jeffrey Kegler (the author of this timeline) releases the first
      practical implementation of Joop Leo's algorithm<footnote>
        <bibref>Kegler 2010</bibref>.
      </footnote>.
      Named Marpa, the new parser is general, table-driven, declarative,
      and linear for LRR,
      which in turn is a superset of the LR grammars discussed in
      <bibref>Knuth 1965</bibref>.<footnote>
        In fact,
        <bibref>Leo 1991</bibref>,
	and therefore Marpa,
        is linear for a superset of the LRR
        grammars.
        It is not known (in fact it is not decidable, see
        <bibref>Leo 1991</bibref>, p. 175.),
        just how large the class of grammars
        that Marpa parses in linear time is.
	<br><br>
        It is known that there are both ambiguous and unambiguous grammars
        for which <bibref>Leo 1991</bibref> is not linear.
        In the general case, Marpa and <bibref>Leo 1991</bibref>
	obey the bounds of Earley's algorithm --
        they are worst-case O(n**2) for unambiguous grammars;
        and worst-case O(n**3) for ambiguous grammars.
        On the other hand, Marpa follows
        <bibref>Leo 1991</bibref>
        in being linear for many ambiguous grammars,
        including those of most practical interest.
      </footnote>.
      This means it is also linear for most of the grammar classes we have discussed in this
      timeline.
    </p><ul>
      <li>LL(k) grammars for all finite k, including LL(1) grammars.</li>
      <li>LR(k) grammars for all finite k.</li>
      <li>LALR grammars.</li>
      <li>Operator expression grammars<footnote>
          In the literature operator expression grammars are more often
          call simply
          <q>operator grammars</q>.
        </footnote>.
      </li>
    </ul>
    <p>This is a vast class of grammars,
      and it has the important feature that it allows a programmer
      to readily determine if their grammar is linear under Marpa.
      Marpa will parse a grammar in linear time, if
    </p><ul id="loc-linearity-rules">
      <li>It is unambiguous<footnote>
          In the general case, ambiguity is undecidable, but
          in practice it is usually straight-forward for a programmer
          to determine that the grammar he wants is unambiguous.
          Note that while the general case is undecidable,
          Marpa will tell the programmer if a parse
          (a grammar with a particular input)
          is ambiguous and, since Marpa parses ambiguous grammars,
	  it produces an error message showing where the ambiguity is.
        </footnote>.
      </li>
      <li>It has no unmarked middle recursions<footnote>A
          <q>marker</q>, in this sense, is something in the input
          that shows where the middle of a middle recursion is,
          without having to go to the end and count back.
          Whether or not a grammar is unmarked is, in general,
          an undecidable problem.
          But in practice, there is a easy rule:
          if a person can
          <q>eyeball</q>
          the middle of a long
          middle recursion, and does not need to count from both
          ends to find it,
          the grammar is
          <q>marked</q>.
        </footnote>.
      </li>
      <li>It has no ambiguous right recursions<footnote>
          This is a very pedantic requirement,
          which practical programmers can in fact ignore.
          Any programmer who has found and eliminated
          ambiguities in his grammar will usually,
          in the process,
          also have found and
          eliminated ambiguous right recursions,
          since it is far easier to eliminate them than
          to determine if they create a overall ambiguity.
          In fact,
          it is an open question whether there
          <em>are</em>
          any unambiguous
          grammars with ambiguous right recursions --
          neither Joop Leo or I know of any.
        </footnote>.
      </li>
    </ul>
    <p>The ability to ensure that a grammar can
      be parsed in linear time is highly useful for second-order
      languages --
      a programmer can easily ensure that all her
      automatically generated grammars will be practical.
      Marpa's own DSL will make use of second-order programming.
    </p>
    <p>
      <bibref>Leo 1991</bibref>
      did not address the zero-length
      rule problem.
      Kegler solves it by adopting the solution of
      <bibref>Aycock and Horspool 2002</bibref>.
      Finally,
      in an effort to combine the best of declarative and hand-written parsing,
      Kegler reorders Earley's parse engine so that it
      allows procedural logic.
      As a side effect,
      this gives Marpa excellent error-handling properties.
    </p>
    <h1>2012: General precedence parsing</h1>
    <p>
      While the purely
      precedence-driven parsing of
      <bibref>Samuelson and Bauer 1960</bibref>
      and
      <bibref>Pratt 1973</bibref>
      never caught on,
      the use of precedence in parsing remains popular.
      In fact, precedence tables often occur in documentation
      and standards,
      which is a clear sign that they too can play a role
      in human-readable but precise descriptions of grammars.
    </p>
    <p>
      In 2012, Kegler releases a version of Marpa which allows
      the user to mix Chomskyan and precedence parsing at will<footnote>
        <bibref>Kegler 2012a</bibref>.
      </footnote>.
      Marpa's
      <q>precedenced statements</q>
      describe expressions
      in terms of precedence and association.
      If
      <q>precedenced statements</q>
      are added to a grammar that Marpa parses in linear
      time, then the grammar remains linear as long as the precedenced statements
      are (after precedence is taken in consideration) unambiguous<footnote>
        Internally, Marpa rewrites precedenced statements into BNF.
        Marpa's rewrite does not use middle recursions
        and does not introduce any new ambiguities
        so that, following Marpa's
        <a href="#loc-linearity-rules">linearity
          rules</a>, the result must be linear.
      </footnote>.
    </p><p>Here is an example of a Marpa
      <q>precedenced statement</q>:
      <footnote>
        In this, precedence goes from tightest to loosest.
        Single bars (<tt>|</tt>) separate RHS's of equal precedence.
        Double bars (<tt>||</tt>) separate RHS's of different precedence.
        Associativity defaults to left,
        and exceptions are indicated by the value of the
        <tt>assoc</tt>
        adverb.
        Note that these
        <q>precedenced statements</q>,
        like all of Marpa's DSL,
        are parsed by Marpa itself.
        The statement shown has the semantic adverbs removed for clarity.
        The original is part of the
        <bibref>Marpa::R2</bibref>
        test suite.
        It can also be found in the "Synopsis"
	of the "Scanless::DSL" document on
        <bibref>Marpa::R2 MetaCPAN</bibref>:
	<mla_url>https://metacpan.org/pod/release/JKEGL/Marpa-R2-4.000000/pod/Scanless/DSL.pod#Synopsis</mla_url>,
	permalink accessed 4 September 2018.
      </footnote>
    </p>
    <pre><tt>
              Expression ::=
                 Number
              |  '(' Expression ')' assoc => group
              || Expression '**' Expression assoc => right
              || Expression '*' Expression
              |  Expression '/' Expression
              || Expression '+' Expression
              |  Expression '-' Expression
            </tt></pre>
    <p>Previously operator expression parsers had worked by
      comparing adjacent operators.
      This limited them to binary expressions
      (the ternary expressions in most languages are
      implemented using post-parsing hackery).
      Marpa's
      <q>precedenced expressions</q>
      are not operator-driven --
      operators are used only to avoid ambiguity.
      <q>Precedenced statements</q>
      will directly implement any number of ternary,
      quaternary or n-ary operators.
      Ternary and larger expressions are useful in
      financial calculations,
      and are common in calculus.
    </p>
    <h1>The Operator Issue as of 2012</h1>
    <p>Marpa allows operator expressions to be parsed as BNF,
      eliminating the need for them.
      On the other hand,
      Marpa's ability to handle second-order languages
      allows it to take statements which describe expressions
      in terms of precedence and association,
      and rewrite them in a natural way into Chomskyan form.
      In this way the grammar writer has all
      the benefits of Chomskyan parsing,
      but is also allowed to describe his grammar in terms
      of operators
      when that is convenient.
      Once again, the Operator Issue seems to be solved,
      but this time perhaps for real.
    </p>
    <h1>The Parsing Problem as of 2012</h1>
    <p>
      Again recall the four criteria from the original
      statement of the Parsing Problem:
      that a parser be efficient, general, declarative and practical.
      Does Marpa<footnote>
        <bibref>Marpa::R2</bibref>.
      </footnote>
      fulfill them?
    </p>
    <p>At first glance, no.
      While Marpa is general, it is not linear or quasi-linear for the
      general case,
      and in that sense,
      Marpa might be considered not efficient enough.
      But to be general, a parser has to parse
      <b>every</b>
      context-free grammar, including
      some wildly ambiguous ones, for which simply printing the
      list of possible parses takes exponential time.
      With the experience of the decades,
      linearity for a fully general BNF parser seems to
      be an unnecessary requirement for a practical parser.
    </p>
    <p>
      The LRR grammars,
      which Marpa does parse in linear time,
      include every
      other grammar class we have discussed --
      LL(k) for all k,
      LR(k) for all k,
      LALR,
      operator grammars,
      etc.
      If we change our criteria as follows:
    </p>
    <ul>
      <li>linear for all LRR grammars,
        and for all grammars parseable in linear time by any
        other parser in practical use;
      </li>
      <li>declarative; and</li>
      <li>practical.
      </li>
    </ul>
    <p>
      then Marpa qualifies.
    </p>
    <p>My teachers came from the generation which created the ALGOL vision
      and started the search for a solution to the Parsing Problem.
      Alan Perlis was one of them.
      Would he have accepted my claim that I have found the solution to the
      problem he posed?
      I do not know.
      But I am certain,
      as anyone else who knew him can attest,
      that he would given me
      a direct and plain-spoken answer.
      In that spirit, I submit this timeline to the candid reader.
      In any case,
      I hope
      that my reader has found this journey
      through the history of parsing informative.
    </p>
    <h1>Bibliography</h1>
    <p>
      An attempt is made to list the original publication,
      which is not necessarily the one consulted.
      Departures from format are made to include information
      of historical interest, for instance the full author
      list of the ALGOL 1960 report.
      For similar reasons, the date in the tag may be the
      date of the source for purposes of historical priority,
      rather a publication date.
    </p>
    <p>
      <bibid>Aho and Ullman 1972</bibid>:
      Aho, Alfred V., and Jeffrey D. Ullman.
      <mla_container>The theory of parsing, translation, and compiling</mla_container>.
      Vol. 1.  Prentice-Hall, 1972.
    </p>
    <p>
      <bibid>Aho and Ullman 1973</bibid>:
      Aho, Alfred V., and Jeffrey D. Ullman.
      <mla_container>The theory of parsing, translation, and compiling</mla_container>.
      Vol. 2.
      Prentice-Hall, 1973.
    </p>
    <p>
      <bibid>Aho and Ullman 1977</bibid>:
      Aho, Alfred V., and Jeffrey D. Ullman.
      <mla_container>Principles of Compiler Design</mla_container>.
      Addison-Wesley, 1977.
      The dragon on the cover is green,
      and this classic first edition
      is sometimes called the
      <q>green dragon book</q>
      to distinguish
      it from its second edition,
      which had a red dragon on the cover.
    </p>
    <p>
      <bibid>ALGOL 1960</bibid>:
      Backus, John W.,
      F. L. Bauer, J. Green, C. Katz, J. McCarthy, A. J. Perlis, H. Rutishauser,
      K. Samelson, B. Vauquois, J. H. Wegstein, A. van Wijngaarden,
      and M. Woodger.
      <mla_container>Revised report on the algorithmic language
        Algol 60</mla_container>.
      Edited by Peter Naur. Springer, 1969.
      <a href="http://www.algol60.org/reports/algol60_rr.pdf">
        Accessed 23 April 2018</a>.
	Originally published
	in <mla_container>Communications of the ACM</mla_container>
	Volume 3, Issue 5, May 1960, Pages 299-314.
    </p>
    <p>
      <bibid>Aycock and Horspool 2002</bibid>:
      Aycock, John, and R. Nigel Horspool.
      <mla_title>Practical earley parsing.</mla_title>
      <mla_container>The Computer Journal</mla_container>, vol. 45, issue 6, 2002, pp. 620-630.
      <a href="https://wiki.eecs.yorku.ca/course_archive/2013-14/W/6339/_media/practicalearleyparsing.pdf">
        Accessed 23 April 2018</a>.
    </p>
    <p>
      <bibid>Backus 1959</bibid>:
      Backus, John W.
      <mla_title>The syntax and semantics of the proposed
        international algebraic language of the Zurich ACM-GAMM
        conference.</mla_title>
      <mla_container>Proceedings of the International Comference on
        Information Processing</mla_container>, 1959.
      Accessible online
      <a href="http://www.softwarepreservation.org/projects/ALGOL/paper/Backus-Syntax_and_Semantics_of_Proposed_IAL.pdf">
        here</a>
      and
      <a href="http://www.softwarepreservation.org/projects/ALGOL/paper/Backus-ICIP-1959.pdf">
        here</a>
      as of 24 April 2018.
    </p>
    <p>
      <bibid>Backus 1980</bibid>:
      Backus, John.
      <mla_title>Programming in america in the 1950s - Some Personal Impressions.</mla_title>
      <mla_container>A History of Computing in the twentieth century</mla_container>,
      1980, pp. 125-135.
      <a href="http://www.softwarepreservation.org/projects/FORTRAN/paper/Backus-ProgrammingInAmerica-1976.pdf">
        Accessed 24 April 2018.
      </a>
    </p>
    <p>
      <bibid>Bloomfield 1926</bibid>:
      Bloomfield, Leonard.
      <mla_title>A set of Postulates
        for the Science of Language.</mla_title>
      <mla_container>Language</mla_container>,
      Vol. 2, No. 3 (Sep., 1926), pp. 153-164.
    </p>
    <bibid>Bloomfield 1933</bibid>:
      Bloomfield, Leonard.
      <cite>Language</cite>.
      Holt, Rinehart and Winston, 1933.
    </p><p>
      <bibid>Backus 2006</bibid>:
      Booch, Grady.
      <mla_title>Oral History of John Backus.</mla_title>
      Computer History Museum,
      5 September 2006.
      <mla_url>http://archive.computerhistory.org/resources/text/oral_history/backus_john/backus_john_1.oral_history.2006.102657970.pdf</mla_url>
      Accessed 24 April 2018.
    </p>
    <p>
      <bibid>Carpenter and Doran 1977</bibid>:
      Carpenter, Brian E., and Robert W. Doran.
      <mla_title>The other Turing machine.</mla_title>
      <mla_container>The Computer Journal</mla_container>,
      vol. 20, issue 3, 1 January 1977, pp. 269-279.
      <a
      href="https://academic.oup.com/comjnl/article-pdf/20/3/269/2256995/200269.pdf">
        Accessed online 24 April 2018.
      </a>
    </p>
    <p>
      <bibid>Chipps et al 1956</bibid>:
      Chipps, J.; Koschmann, M.; Orgel, S.; Perlis, A.; and Smith, J.
      <mla_title>A mathematical language compiler.</mla_title>
      <mla_container>Proceedings of the 1956 11th ACM national meeting</mla_container>,
      ACM, 1956.
    </p>
    <p>
      <bibid>Chomsky 1956</bibid>:
      Chomsky, Noam.
      <mla_title>Three models for the description of language.</mla_title>
      <mla_container>IRE Transactions on information theory</mla_container>,
      vol. 2, issue 3, September 1956, pp. 113-124.
    </p>
    <p>
      <bibid>Chomsky 1957</bibid>:
      Chomsky, Noam.
      <cite>Syntactic Structures</cite>.
      Mouton & Co., 1957.
    </p>
    <p>
      <bibid>Chomsky 1959</bibid>:
      Chomsky, Noam.
      <mla_title>A Review of B. F. Skinner's Verbal Behavior</mla_title>.
      <mla_container>Language</mla_container>,
      Volume 35, No. 1, 1959, 26-58.
      <mla_url>https://chomsky.info/1967____/</mla_url>.
      Accessed 1 September 2018.
    </p>
    <p>
      <bibid>Chomsky 1978</bibid>:
      Chomsky, Noam.
      <mla_container>Topics in the Theory of Generative Grammar</mla_container>.
      De Gruyter, 1978.
    </p>
    <p>
      <bibid>Chomsky 2002</bibid>:
      Chomsky, Noam.
      <mla_container>Syntactic Structures</mla_container>,
      2nd ed.,
      Mouton de Gruyter, 2002.
    </p>
    <p>
      <bibid>&#268;ulik and Cohen 1973</bibid>:
      &#268;ulik II, Karel and Cohen, Rina.
      <mla_title>LR-regular grammars --
        an extension of LR(k) grammars</mla_title>
      <mla_container>Journal of Computer and System Sciences.</mla_container>
      Volume 7, Issue 1, February 1973, Pages 66-96.
      <mla_url>http://www.sciencedirect.com/science/article/pii/S0022000073800509</mla_url>.
      Accessed 29 August 2018.
    </p><p>
      <bibid>Darwin 1984</bibid>:
      Darwin, Ian F., and Geoffrey Collyer.
      <mla_title>A History of UNIX before
        Berkeley: UNIX Evolution, 1975-1984.</mla_title>
      <mla_container>/sys/doc/</mla_container>,
      1984,
      <mla_url>http://doc.cat-v.org/unix/unix-before-berkeley/</mla_url>.
      Accessed 24 April 2018.
    </p>
    <p>
      <bibid>Denning 1983</bibid>:
      Denning, Peter.
      Untitled introduction to
      <bibref>Irons 1961</bibref>.
      <mla_container>Communications of the ACM</mla_container>,
      25th Anniversary Issue,
      vol. 26, no. 1, 1983, p. 14.
    </p>
    <p>
      <bibid>DeRemer 1969</bibid>:
      DeRemer, Franklin Lewis.
      <mla_container>Practical translators for LR(k) languages</mla_container>.
      September 1969.
      PhD dissertation, Massachusetts Institute of Technology,
      <mla_url>https://dspace.mit.edu/bitstream/handle/1721.1/13628/24228988-MIT.pdf?sequence=2</mla_url>.
      Accessed 24 April 2018.
    </p>
    <p>
      <bibid>Dijkstra 1961</bibid>:
      Dijkstra, E. W.
      <mla_title>Algol 60 translation: An algol 60 translator for
        the x1 and making a translator for algol 60.</mla_title>
      Stichting Mathematisch Centrum,
      Rekenafdeling, MR 34/61, 1961.
    </p>
    <p>
      <bibid>Earley 1968</bibid>:
      Earley, Jay.
      <mla_title>An Efficient Context-free Parsing Algorithm.</mla_title>
      August 1968.
      PhD dissertation, Carnegie-Mellon University,
      <mla_url>http://reports-archive.adm.cs.cmu.edu/anon/anon/usr0/ftp/scan/CMU-CS-68-earley.pdf</mla_url>.
      Accessed 24 April 2018.
    </p>
    <p>
      <bibid>Ford 2002</bibid>:
      Ford, Bryan.
      <mla_title>Packet parsing: a Practical Linear-Time Algorithm with
        Backtracking.</mla_title>
      September 2002.
      PhD dissertation, Massachusetts Institute of Technology,
      <mla_url>https://dspace.mit.edu/bitstream/handle/1721.1/87310/51972156-MIT.pdf;sequence=2</mla_url>.
      Accessed 24 April 2018.
    </p>
    <p>
      <bibid>Ford 2004</bibid>:
      Ford, Bryan.
      <mla_title>Parsing expression grammars: a recognition-based
        syntactic foundation.</mla_title>
      <mla_container>ACM SIGPLAN Notices</mla_container>,
      vol. 39, no. 1, January 2004.
      <mla_url>https://pdos.csail.mit.edu/papers/parsing:popl04.pdf</mla_url>.
      Accessed 24 April 2018.
    </p>
    <p>
      <bibid>Frost 1992</bibid>:
      Frost, Richard A.
      <mla_title>Constructing Programs as Executable Attribute Grammars.</mla_title>
      <mla_container>The Computer Journal</mla_container>,
      vol. 35, issue 4, 1 August 1992, pp. 376-389.
      <mla_url>https://academic.oup.com/comjnl/article/35/4/376/348233</mla_url>.
    </p>
    <p>
      <bibid>FSF 2006</bibid>:
      "GCC 4.1 Release Series: Changes, New Features, and Fixes."
      Free Software Foundation,
      <mla_url>http://gcc.gnu.org/gcc-4.1/changes.html</mla_url>.
      Accessed 25 April 2018.
      The release date of GCC 4.1 was February 28, 2006.
    </p>
    <p>
      <bibid>Glennie 1960</bibid>:
      Glennie, A. E.
      <mla_title>On the syntax machine and the construction of a
        universal compiler,</mla_title>
      TR-2.
      Carnegie Institute of Technology,
      Computation Center, 1960.
      <mla_url>http://www.chilton-computing.org.uk/acl/literature/reports/p024.htm</mla_url>.
      The paper is dated 10 July 1960.
      Accessed 24 April 2018.
    </p>
    <p>
      <bibid>Grune and Jacobs 2008</bibid>:
      Grune, D. and Jacobs, C. J. H.
      <cite>Parsing Techniques: A Practical
        Guide, 2nd edition</cite>.
      Springer, 2008.
      When it comes to determining who first discovered an idea,
      the literature often disagrees.
      In such cases, I have often deferred
      to the judgement of Grune and Jacobs.
    </p>
    <p>
      <bibid>Harris 1993</bibid>:
      Harris, Randy Allen.
      <cite>The Linguistics Wars</cite>.
      Oxford University Press, 1993
    </p>
    <p>
      <bibid>Hayes 2013</bibid>:
      Hayes, Brian.
      <mla_title>First links in the Markov chain.</mla_title>
      <mla_container>American Scientist</mla_container>,
      vol. 101, no .2, 2013, p. 252.
      <a href="https://raichev.net/markov/misc/markov_chain.pdf">
        Accessed online as of 24 April 2018.</a>
    </p>
    <p>
      <bibid>Hayes 1962</bibid>:
      Hayes, David G.
      <mla_title>Automatic language-data processing</mla_title>.
      Pp. 394-423 in <mla_container>Computer Applications in the Behavioral Sciences</mla_container>,
      H. Borko, editor,
      Prentice Hall, 1962.
      Describes two algorithms, the first of which,
      attributed to J Cocke,
      is a CYK parser.
    </p>
    <p>
      <bibid>Hilgers and Langville 2006</bibid>:
      Hilgers, Philipp, and Amy N. Langville.
      <mla_title>The five greatest applications of Markov Chains.</mla_title>
      <mla_container>Proceedings of the Markov Anniversary Meeting</mla_container>,
      Boston Press, 2006.
      <mla_url>http://langvillea.people.cofc.edu/MCapps7.pdf</mla_url>.
      Accessed 24 April 2018.
      Slide presentation:
      <mla_url>https://www.csc2.ncsu.edu/conferences/nsmc/MAM2006/langville.pdf</mla_url>.
      Accessed 24 April 2018.
    </p>
    <p>
      <bibid>Hutton 1992</bibid>:
      Hutton, Graham.
      <mla_title>Higher-order functions for parsing.</mla_title>
      <mla_container>Journal of functional programming</mla_container>,
      vol. 2, no. 3, July 1992, pp. 323-343.
      <mla_url>http://eprints.nottingham.ac.uk/221/1/parsing.pdf</mla_url>.
      Accessed 24 April 2018.
    </p>
    <p>
      <bibid>Hutton and Meijer 1996</bibid>:
      Hutton, Graham and Erik Meijer.
      <mla_title>Monadic parser combinators</mla_title>,
      Technical Report NOTTCS-TR-96-4.
      Department of Computer Science, University of Nottingham,
      1996.
      <mla_url>http://eprints.nottingham.ac.uk/237/1/monparsing.pdf</mla_url>.
      Accessed 24 April 2018.
    </p>
    <p>
      <bibid>Irons 1961</bibid>:
      Irons, Edgar T.
      <mla_title>A syntax directed compiler for ALGOL 60.</mla_title>
      <mla_container>Communications of the ACM</mla_container>,
      vol. 4, no. 1, January 1961, pp. 51-55.
    </p>
    <p>
      <bibid>Johnson 1975</bibid>:
      Johnson, Stephen C.
      <mla_title>Yacc: Yet another compiler-compiler</mla_title>,
      Technical Report.
      Bell Laboratories, Murray Hill, NJ, 1975.
      <mla_url>https://www.isi.edu/~pedro/Teaching/CSCI565-Fall15/Materials/Yacc.pdf</mla_url>.
      Accessed 24 April 2018.
    </p>
    <p>
      <bibid>Kasami and Torii 1969</bibid>:
      Kasami, T. and Torii, K.
      <mla_title>A syntax-analysis procedure for unambiguous context-free grammars</mla_title>.
      <mla_container>Journal of the ACM</mla_container>,
      vol. 16, issue 3, July 1969, pp. 423-431.
    </p>
    <p>
      <bibid>Kegler 2010</bibid>:
      Kegler, Jeffrey.
      <mla_title>Marpa is now O(n) for Right Recursions.</mla_title>
      <mla_container>Ocean of Awareness</mla_container>,
      June 5, 2010.
      <mla_url>http://jeffreykegler.github.io/Ocean-of-Awareness-blog/individual/2010/06/marpa-is-now-on-for-right-recursions.html</mla_url>.
      Accessed 24 April 2018.
      This is the initial announcement,
      and its examples and links are obsolete.
      The latest stable version of Marpa is
      <bibref>Marpa::R2</bibref>.
    </p>
    <p>
      <bibid>Kegler 2012a</bibid>:
      Kegler, Jeffrey.
      <mla_title>Precedence parsing made simpler.</mla_title>
      <mla_container>Ocean of Awareness</mla_container>,
      August 22, 2012.
      <mla_url>http://jeffreykegler.github.io/Ocean-of-Awareness-blog/individual/2012/08/precedence-parsing-made-simpler.html</mla_url>.
      Accessed 24 April 2018.
      This is the initial announcement,
      and its examples and links are obsolete.
      The latest stable version of Marpa is
      <bibref>Marpa::R2</bibref>.
    </p>
    <p>
      <bibid>Kegler 2012b</bibid>:
      Kegler, Jeffrey.
      <mla_title>Marpa, A Practical General Parser: The Recognizer.</mla_title>
      <mla_url>http://dinhe.net/~aredridel/.notmine/PDFs/Parsing/KEGLER,%20Jeffrey%20-%20Marpa,%20a%20practical%20general%20parser:%20the%20recognizer.pdf</mla_url>.
      Accessed 24 April 2018.
      The link is to the 19 June 2013 revision of the 2012 original.
    </p>
    <p>
      <bibid>Kegler Strings 2018</bibid>:
      Kegler, Jeffrey.
      <mla_title>Is a language just a set of strings?</mla_title>
      <mla_container>Ocean of Awareness</mla_container>,
      May 28, 2018.
      <mla_url>http://jeffreykegler.github.io/Ocean-of-Awareness-blog/individual/2018/05/chomsky_1956.html</mla_url>.
      Accessed 2 September 2018.
    </p>
    <p>
      <bibid>Kegler Solved 2018</bibid>:
      Kegler, Jeffrey.
      <mla_title>Why is parsing considered solved?</mla_title>
      <mla_container>Ocean of Awareness</mla_container>,
      4 June, 2018.
      <mla_url>http://jeffreykegler.github.io/Ocean-of-Awareness-blog/individual/2018/05/knuth_1965.html</mla_url>.
      Accessed 2 September 2018.
    </p>
    <p>
      <bibid>Kegler Undershoot 2018</bibid>:
      Kegler, Jeffrey.
      <mla_title>Undershoot: Parsing theory in 1965</mla_title>.
      <mla_container>Ocean of Awareness</mla_container>,
      August 8, 2018.
      <mla_url>http://jeffreykegler.github.io/Ocean-of-Awareness-blog/individual/2018/07/knuth_1965_2.html</mla_url>.
      Accessed 2 September 2018.
    </p>
    <p>
      <bibid>Kegler Haskell 2018</bibid>:
      Kegler, Jeffrey.
      <mla_title>A Haskell challenge.</mla_title>
      <mla_container>Ocean of Awareness</mla_container>,
      August 28, 2018.
      <mla_url>http://jeffreykegler.github.io/Ocean-of-Awareness-blog/individual/2018/08/rntz.html</mla_url>.
      Accessed 28 August 2018.
    </p>
    <p>
      <bibid>Kleene 1951</bibid>:
      Kleene, Stephen Cole.
      <mla_title>Representation of events in nerve nets and
        finite automata.</mla_title>,
      RM-704.
      Rand Corporation, 15 December 1951.
      <mla_url>https://www.rand.org/content/dam/rand/pubs/research_memoranda/2008/RM704.pdf</mla_url>.
      Accessed 24 April 2018.
    </p>
    <p>
      <bibid>Knuth 1962</bibid>:
      Knuth, Donald E.
      <mla_title>A history of writing compilers.</mla_title>
      <mla_container>Computers and Automation</mla_container>,
      vol. 11, no. 12, 1962, pp. 8-18.
    </p>
    <p>
      <bibid>Knuth 1965</bibid>:
      Knuth, Donald E.
      <mla_title>On the translation of languages from left to right.</mla_title>
      <mla_container>Information and Control</mla_container>,
      vol. 8, issue 6, December 1965, pp. 607-639.
      <mla_url>https://ac.els-cdn.com/S0019995865904262/1-s2.0-S0019995865904262-main.pdf?_tid=dcf0f8a0-d312-475e-a559-be7714206374&acdnat=1524066529_64987973992d3a5fffc1b0908fe20b1d</mla_url>
      Accessed 24 April 2018.
    </p>
    <p>
      <bibid>Knuth 1968</bibid>:
      Knuth, Donald E.
      <mla_title>Semantics of context-free languages.</mla_title>
      <mla_container>Mathematical Systems Theory</mla_container>,
      vol. 2, no. 2, 1968, pp. 127-145.
      <mla_url>https://www.csee.umbc.edu/courses/331/fall16/01/resources/papers/Knuth67AG.pdf</mla_url>.
      Accessed 24 April 2018.
    </p>
    <p>
      <bibid>Knuth 1971</bibid>:
      Knuth, Donald E.
      <mla_title>Top-down syntax analysis.</mla_title>
      <mla_container>Acta Informatica</mla_container>
      vol. 1, issue 2, 1971, pp. 79-110.
      <mla_url>http://www.dcc.ufrj.br/~fabiom/comp20122/knuth_topdown.pdf</mla_url>.
      Accessed 24 April 2018.
    </p>
    <p>
      <bibid>Knuth 1990</bibid>:
      Knuth, Donald E.
      <mla_title>The genesis of attribute grammars.</mla_title>
      <mla_container>Attribute Grammars and Their Applications</mla_container>,
      Springer, September 1990, pp. 1-12.
      <mla_url>http://www.cs.miami.edu/home/odelia/teaching/csc419_spring17/syllabus/Knuth_AttributeHistory.pdf</mla_url>.
      Accessed 24 April 2018.
    </p>
    <p>
      <bibid>Knuth and Pardo 1976</bibid>:
      Knuth, Donald E., and Luis Trabb Pardo.
      <mla_title>The Early Development of Programming Languages,</mla_title>
      STAN-CS-76-562.
      Computer Science Department, Stanford University, August 1976.
      <mla_url>http://bitsavers.trailing-edge.com/pdf/stanford/cs_techReports/STAN-CS-76-562_EarlyDevelPgmgLang_Aug76.pdf</mla_url>.
      Accessed 24 April 2018.
    </p>
    <p>
      <bibid>Leo 1991</bibid>:
      Leo, Joop M. I. M.
      <mla_title>A general context-free parsing algorithm
        running in linear time on every LR (k) grammar without using
        lookahead.</mla_title>
      <mla_container>Theoretical computer science</mla_container>
      vol. 82, issue 1, 22 May 1991, pp. 165-176.
      <mla_url>https://www.sciencedirect.com/science/article/pii/030439759190180A</mla_url>
      Accessed 24 April 2018.
    </p>
    <p>
      <bibid>Lewis and Stearns 1968</bibid>:
      <comment>There is a 1966 paper with the same authors and title.
        but Aho and Ullman 1972, p. 268 says that the 1968 paper is the
        first definition of LL(k).
      </comment>
      Lewis II, Philip M., and Richard Edwin Stearns.
      <mla_title>Syntax-directed transduction.</mla_title>
      <mla_container>Journal of the ACM</mla_container>,
      vol. 15, issue 3, 1968, pp. 465-488.
    </p>
    <p>
      <bibid>Lucas 1961</bibid>:
      Lucas, Peter.
      <mla_title>Die Strukturanalyse von
        Formel&uuml;bersetzern/analysis of the structure of formula
        translators.</mla_title>
      <mla_container>Electronische Rechenlagen</mla_container>,
      vol. 3, 11.4, December 1961, pp. 159-167.
    </p>
    <p>
      <bibid>Marpa::R2</bibid>:
      <br>
      Home website:
      <mla_url>http://savage.net.au/Marpa.html</mla_url>.
      Accessed 25 April 2018.
      <br>
      Kegler's Marpa website:
      <mla_url>https://jeffreykegler.github.io/Marpa-web-site/</mla_url>.
      Accessed 25 April 2018.
      <br>
      Github:
      <mla_url>https://github.com/jeffreykegler/Marpa--R2</mla_url>.
      Accessed 25 April 2018.
      <br>
      See also
      <bibref>Kegler 2012b</bibref>
      and
      <bibref>Marpa::R2 MetaCPAN</bibref>.
    </p>
    <p>
      <bibid>Marpa::R2 MetaCPAN</bibid>:
      <mla_url>https://metacpan.org/pod/Marpa::R2</mla_url>.
      Accessed 30 April 2018.
    </p>
    <p>
      <bibid>Markov 1906</bibid>:
      Markov, Andrey Andreyevich.
      <mla_title>Rasprostranenie zakona bol'shih chisel na velichiny, zavisyaschie drug ot druga</mla_title>.
      <mla_container>Izvestiya Fiziko-matematicheskogo obschestva pri Kazanskom universitete</mla_container>,
      2-ya seriya, tom 15, 1906, pp. 135-156.
      In English, the title translates to
      "Extension of the law of large numbers to quantities, depending on each other".
    </p>
    <p>
      <bibid>Markov 1913</bibid>:
      Markov, Andrey Andreyevich.
      <mla_title>Primer statisticheskogo issledovaniya nad tekstom 'Evgeniya Onegina',
        illyustriruyuschij svyaz' ispytanij v cep'</mla_title>.
      <mla_container>Izvestiya Akademii Nauk</mla_container>,
      Sankt-Peterburg,
      VI seriya,
      tom 7, 9(3), 1913, pp. 153-162.
      An English translation is
      <mla_title>An example of statistical investigation of the text Eugene Onegin concerning the connection of samples in chains</mla_title>,
      <mla_container>Science in Context</mla_container>,
      vol. 19, no. 4, December 2006, pp. 591-600.
      <mla_url>http://www.alpha60.de/research/markov/DavidLink_AnExampleOfStatistical_MarkovTrans_2007.pdf</mla_url>.
      Accessed 25 April 2018.
    </p>
    <p>
      <bibid>Mascrenhas et al 2014</bibid>:
      Mascarenhas, Fabio, S&egrave;rgio Medeiros, and Roberto Ierusalimschy.
      <mla_title>On the relation between context-free grammars and parsing expression grammars.</mla_title>
      <mla_container>Science of Computer Programming</mla_container>,
      volume 89, part C, 1 September 2014, pp. 235-250.
      <mla_url>https://arxiv.org/abs/1304.3177</mla_url>.
      Accessed 25 April 2018.
    </p>
    <p>
      <bibid>McIlroy 1987</bibid>:
      McIlroy, M. Douglas.
      "A Research Unix reader: annotated excerpts from the Programmer's Manual, 1971-1986,"
      AT&T Bell Laboratories Computing Science Technical Report #139, 1987.
      <mla_url>http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.692.4849&rep=rep1&type=pdf</mla_url>.
      Accessed 25 April 2018.
    </p>
    <p>
      <bibid>McIlroy and Kernighan 1979</bibid>:
      McIlroy, M. D. and B. W. Kernighan.
      <mla_title>Unix Time-Sharing System: Unix Programmer's Manual.</mla_title>
      Seventh Edition, Bell Telephone Laboratories, January 1979.
      <mla_url>https://s3.amazonaws.com/plan9-bell-labs/7thEdMan/index.html</mla_url>.
      Accessed 25 April 2018.
    </p>
    <p>
      <bibid>Moser 1954</bibid>:
      Moser, Nora B.
      <mla_title>Compiler method of automatic programming.</mla_title>
      <mla_container>Proceedings of the Symposium on Automatic Programming for Digital Computers</mla_container>,
      Office of Naval Research,
      1954, pp. 15-21.
      This conference, held 13-14 May and
      organized by Grace Hopper, was
      the first symposium devoted to software.
    </p>
    <p>
      <bibid>Norvell 1999</bibid>:
      Norvell, Theodore.
      <mla_title>Parsing Expressions by Recursive Descent.</mla_title>
      1999,
      <mla_url>https://www.engr.mun.ca/~theo/Misc/exp_parsing.htm</mla_url>.
      Accessed 25 April 2018.
    </p>
    <p>
      <bibid>Oettinger 1960</bibid>:
      Oettinger, Anthony.
      <mla_title>Automatic Syntactic Analysis and the Pushdown Store.</mla_title>
      <mla_container>Proceedings of Symposia in Applied Mathematics</mla_container>,
      Volume 12, American Mathematical Society, 1961.
      From the Proceedings of the Twelfth Symposium in
      Applied Mathematics held in New York City, April 14-15, 1960.
    </p>
    <p>
      <bibid>Padua 2000</bibid>:
      Padua, David.
      <mla_title>The Fortran I compiler.</mla_title>
      <mla_container>Computing in Science & Engineering</mla_container>,
      volume 2, issue 1, Jan-Feb 2000, pp. 70-75.
      <mla_url>https://web.stanford.edu/class/archive/cs/cs339/cs339.2002/fortran.pdf</mla_url>.
      Accessed 25 April 2018.
    </p>
    <p>
      <bibid>Perlis et al 1958</bibid>:
      Perlis, Alan J., J. W. Smith, and H. R. Van Zoeren.
      <mla_title>Internal Translator (IT): A compiler for the 650.</mla_title>
      Computation Center,
      Carnegie Institute of Technology.
      Publication date is given as March 1957 in
      <bibref>Knuth and Pardo 1976</bibref>, p. 105.
      <mla_url>https://ia801904.us.archive.org/11/items/bitsavers_ibm650Carntor_16304233/CarnegieInternalTranslator.pdf</mla_url>.
      Accessed 25 April 2018.
    </p>
    <p>
      <bibid>Post 1943</bibid>:
      Post, Emil L.
      <mla_title>Formal Reductions of the General Combinatorial Decision Problem.</mla_title>
      <mla_container>American Journal of Mathematics</mla_container>,
      vol. 65, no .2, April 1943, pp. 197-215.
    </p>
    <p>
      <bibid>Pratt 1973</bibid>:
      Pratt, Vaughan R.
      <mla_title>Top down operator precedence.</mla_title>
      <mla_container>Proceedings
        of the 1st annual ACM SIGACT-SIGPLAN symposium on Principles of
        programming languages</mla_container>,
      ACM, 1973.
    </p>
    <p>
      <bibid>Rosencrantz and Stearns 1970</bibid>:
      Rosenkrantz, Daniel J., and Richard Edwin Stearns.
      <mla_title>Properties of deterministic top-down grammars.</mla_title>
      <mla_container>Information and Control</mla_container>,
      volume 17, no. 3, October 1970, pp. 226-256.
      <mla_url>https://s3.amazonaws.com/academia.edu.documents/43093758/Properties_of_Deterministic_Top-Down_Gra20160226-4294-1dzfmgn.pdf?AWSAccessKeyId=AKIAIWOWYYGZ2Y53UL3A&Expires=1524516488&Signature=EQ9rs7iGKORIoxa%2F1jGEzOI5pOQ%3D&response-content-disposition=inline%3B%20filename%3DProperties_of_deterministic_top_down_gra.pdf</mla_url>.
      Accessed 23 April 2018.
    </p>
    <p>
      <bibid>Sakai 1961</bibid>:
      Sakai, Itiroo.
      <mla_title>Syntax in Universal Translation</mla_title>
      <mla_container>International Conference on Machine Translation of Languages and Applied Language Analysis</mla_container>,
      National Physical Laboratory, Teddington, UK, 5-8 September 1961.
      <mla_url>http://www.mt-archive.info/50/NPL-1961-Sakai.pdf</mla_url>.
      Accessed 6 October 2018.
    </p>
    <p>
      <bibid>Samuelson and Bauer 1959</bibid>:
      Samelson, Klaus, and Friedrich L. Bauer.
      "Sequentielle formel&uuml;bersetzung."
      it-Information Technology 1.1-4 (1959): 176-182.
    </p>
    <p>
      <bibid>Samuelson and Bauer 1960</bibid>:
      Samelson, Klaus, and Friedrich L. Bauer.
      <mla_title>Sequential formula translation.</mla_title>
      <mla_container>Communications of the ACM</mla_container>,
      vol. 3, no. 2, February 1960, pp. 76-83.
      A translation of
      <bibref>Samuelson and Bauer 1959</bibref>.
    </p>
    <p>
      <bibid>Schorre 1964</bibid>:
      Schorre, D. V.
      <mla_title>Meta ii a syntax-oriented compiler writing language.</mla_title>
      <mla_container>Proceedings of the 1964 19th ACM national conference</mla_container>,
      ACM, 1964.
      <mla_url>http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.695.4636&rep=rep1&type=pdf</mla_url>.
      Accessed 23 April 2018.
    </p>
    <p>
      <bibid>Shannon 1948</bibid>:
      Shannon, Claude E.
      <mla_title>A Mathematical Theory of Communication.</mla_title>
      <mla_container>Bell System Technical Journal</mla_container>,
      vol. 27, pp. 379-423, 623-656, July, October, 1948.
      <mla_url>http://cs-www.cs.yale.edu/homes/yry/readings/general/shannon1948.pdf</mla_url>.
      Accessed 23 April 2018.
    </p>
    <p>
      <bibid>Simms 2014</bibid>:
      Simms, Damon.
      <mla_title>Further discussion related to request for arbitration.</mla_title>
      <mla_container>Talk:Metacompiler</mla_container>,
      Archive 2,
      Wikipedia,
      9 October 2014,
      <mla_url>https://en.wikipedia.org/wiki/Talk:Metacompiler/Archive_2#Further_discussion_related_to_request_for_arbitration</mla_url>.
      Accessed 25 April 2018.
    </p>
    <p>
      <bibid>Snyder 1975</bibid>:
      Snyder, Alan.
      <mla_title>A portable compiler for the language C.</mla_title>
      No. MAC-TR-149. Massachusetts Institute of Technology, Project MAC,
      1975.
    </p>
    <p>
      <bibid>Wadler 1985</bibid>:
      Wadler, Philip.
      <mla_title>How to replace failure by a list of successes a
        method for exception handling, backtracking, and pattern matching
        in lazy functional languages.</mla_title>
      <mla_container>Conference on Functional Programming
        Languages and Computer Architecture</mla_container>,
      Springer,
      1985.
      <mla_url>https://rkrishnan.org/files/wadler-1985.pdf</mla_url>.
      Accessed 23 April 2018.
    </p>
    <p>
      <bibid>Wadler 1990</bibid>:
      Wadler, Philip.
      <mla_title>Comprehending monads.</mla_title>
      <mla_container>Proceedings of the 1990 ACM conference on LISP and
        functional programming</mla_container>,
      ACM, 1990.
      <mla_url>http://www.diku.dk/hjemmesider/ansatte/henglein/papers/wadler1992.pdf</mla_url>.
      Accessed 23 April 2018.
    </p>
    <p>
      <bibid>Wadler 1995</bibid>:
      Wadler, Philip.
      <mla_title>Monads for functional programming.</mla_title>
      <mla_container>International
        School on Advanced Functional Programming</mla_container>,
      Springer, 1995.
      <mla_url>http://roman-dushkin.narod.ru/files/fp__philip_wadler_001.pdf</mla_url>.
      Accessed 23 April 2018.
    </p>
    <p>
      <bibid>Wall 2014</bibid>:
      Wall, Larry.
      <mla_container>IRC log for #perl6</mla_container>, 30 August 2014,
      <mla_url>https://irclog.perlgeek.de/perl6/2014-08-30#i_9271280</mla_url>.
      Accessed 25 April 2018.
    </p>
    <p>
      <bibid>Wiki Big O</bibid>:
      <mla_title>Big O Notation</mla_title>,
      <mla_container>Wikipedia</mla_container>,
      29 April 2018,
      <mla_url>https://en.wikipedia.org/w/index.php?title=Big_O_notation&oldid=838856464</mla_url>.
      Accessed 29 April 2018.
    </p>
    <p>
      <bibid>Wiki Perl</bibid>:
      <mla_title>Perl</mla_title>,
      <mla_container>Wikipedia</mla_container>,
      21 April 2018,
      <mla_url>https://en.wikipedia.org/w/index.php?title=Perl&oldid=837585549</mla_url>.
      Accessed 26 April 2018.
    </p>
    <p>
      <bibid>Younger 1967</bibid>:
      Younger, Daniel M.
      <mla_title>Recognition and Parsing of Context-Free Languages in Time n<sup>3</sup></mla_title>
      <mla_container>Information and Control</mla_container> 10, pp 189-208,
      1967.
      <mla_url>https://core.ac.uk/download/pdf/82305262.pdf</mla_url>.
      Accessed 6 October 2018.
    </p>
    <comment>FOOTNOTES HERE</comment>
    <script>!function(d,s,id){var js,fjs=d.getElementsByTagName(s)[0];if(!d.getElementById(id)){js=d.createElement(s);js.id=id;js.src="//platform.twitter.com/widgets.js";fjs.parentNode.insertBefore(js,fjs);}}(document,"script","twitter-wjs");</script>
    <script type="text/javascript">
            var gaJsHost = (("https:" == document.location.protocol) ? "https://ssl." : "http://www.");
            document.write(unescape("%3Cscript src='" + gaJsHost + "google-analytics.com/ga.js' type='text/javascript'%3E%3C/script%3E"));
          </script>
    <script type="text/javascript">
            try {
              var pageTracker = _gat._getTracker("UA-33430331-1");
            pageTracker._trackPageview();
            } catch(err) {}
          </script>
  </body>
</html>
