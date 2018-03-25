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

my ($input, $footnotes) = @ARGV;
open my $fh_in, '<', $input;
open my $fh_fn_out, '>', $footnotes;

while ( my $line = <$fh_in> ) {
    chomp $line;
    if ( $line =~ /<footnote>/ ) {
        do_footnote($line);
    }
    if ( $line =~ /<biblio>/ ) {
        do_biblio($line);
    }
    say $line;
}

my $fn_number = 0;

sub do_footnote {
    my ($line) = @_;
    my $pre_footnote = $line;
    $pre_footnote =~ s/<footnote>.*$//;
    say $pre_footnote if $pre_footnote =~ m/\S/;
    $fn_number++;
    my $fn_ref = join '-', 'footnote', $fn_number, 'ref';
    my $fn_href = join '-', '#footnote', $fn_number;
    say qq{<a id="$fn_ref" href="$fn_href">[$fn_number]</a>};
    my @fn_lines = (qq{<p id="$fn_ref">});
    $line =~ s/^.*<footnote>//;
    push @fn_lines, $line if $line =~ m/\S/;
  FN_LINE: while ( my $line = <$fh_in> ) {
        chomp $line;
        if ( $line =~ m[<\/footnote>] ) {
	    my $post_footnote = $line;
	    $post_footnote =~ s[^.*<\/footnote>][];
	    $line =~ s[</footnote>.*$][];
	    push @fn_lines, $line if $line =~ m/\S/;
	    push @fn_lines, qq{ <a href="$fn_href">&#8617;</a></p>};
	    last FN_LINE;
        }
	push @fn_lines, $line;
    }
    say $fh_fn_out join "\n", @fn_lines;
}

sub do_bibio { die 'NYI' }
