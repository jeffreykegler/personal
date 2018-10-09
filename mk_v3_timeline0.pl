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

LINE: while ( my $line = <> ) {
    chomp $line;
    $line =~ s/<thisyear>/2018/g;
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
  FN_LINE: while ( my $fn_line = <> ) {
        chomp $fn_line;
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

