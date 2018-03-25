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

my $output = join "\n", @lines;
my $footnotes = join "\n", '<h1>Footnotes</h1>', @fn_lines, '</body>';
$output =~ s[</body>][$footnotes];

say $output;

sub do_footnote {
    my ($line) = @_;
    $fn_number++;
    my $fn_ref = join '-', 'footnote', $fn_number, 'ref';
    my $fn_href = join '-', 'footnote', $fn_number;
    my $footnoted_line = $line;
    $footnoted_line =~ s/<footnote>.*$//;
    $footnoted_line .= qq{<a id="$fn_ref" href="#$fn_href">[$fn_number]</a>};
    push @lines, $footnoted_line if $footnoted_line =~ m/\S/;
    push @fn_lines, qq{<p id="$fn_href">$fn_number.};
    $line =~ s/^.*<footnote>//;
    push @fn_lines, $line if $line =~ m/\S/;
  FN_LINE: while ( my $line = <> ) {
        chomp $line;
        if ( $line =~ m[<\/footnote>] ) {
	    my $post_footnote = $line;
	    $post_footnote =~ s[^.*<\/footnote>][];
	    $line =~ s[</footnote>.*$][];
	    push @fn_lines, $line if $line =~ m/\S/;
	    push @fn_lines, qq{ <a href="#$fn_ref">&#8617;</a></p>};
	    last FN_LINE;
        }
	push @fn_lines, $line;
    }
}

