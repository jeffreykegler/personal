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
    if ( $line =~ /<footnote>/ ) {
        do_footnote($line);
	next LINE;
    }
    push @lines, $line;
}

my $output = join "\n", map { do_bib($_) } @lines;
my $footnotes = join "\n", '<h1>Footnotes</h1>', map { do_bib($_) } @fn_lines;
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

sub do_footnote {
    my ($line) = @_;
    $fn_number++;
    my $fn_ref = join '-', 'footnote', $fn_number, 'ref';
    my $fn_href = join '-', 'footnote', $fn_number;
    my $footnoted_line = $line;
    $footnoted_line =~ s/<footnote>.*$//;
    $footnoted_line .= qq{<a id="$fn_ref" href="#$fn_href">[$fn_number]</a>};
    push @fn_lines, qq{<p id="$fn_href">$fn_number.};
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

