#!/usr/bin/perl
use warnings;
use 5.036;

use List::Util qw(min);

chomp(my @lines = <>);

my @colors = map { [ split(/ /) ] } @lines;
my @processed = map { [ ${$_}[2] =~ /\(\#([0-9a-f]{5})(.)\)/ ] } @colors;

my @digs = map { [ ${$_}[1], hex ${$_}[0] ] } @processed;

(my $x, my $y) = (0, 0);

my @points = ([0, 0]);

my $b = 0;
foreach my $digRef (@digs) {
    (my $dir, my $len) = @{$digRef};

    $b += $len;

    if ($dir eq '0') { # R
        $x += $len;
    } elsif ($dir eq '2') { # L
        $x -= $len;
    } elsif ($dir eq '3') { # U
        $y -= $len;
    } elsif ($dir eq '1') { # D
        $y += $len;
    } else {
        die "Wrong dir: $dir";
    }

    push(@points, [$x, $y]);
}

# my @a = map { "(${$_}[0], ${$_}[1])" } @points;
# say "@a";

# shoelace formula

my $sum = 0;
for my $i (0..($#points - 1)) {
    my $xi = ${$points[$i]}[0];
    my $yprev = ${$points[$i-1]}[1];
    my $ynext = ${$points[$i+1]}[1];

    $sum += $xi * ($ynext - $yprev);
}

my $area = $sum / 2;

# pick's theorem
# A = i + b/2 - 1
# i = A - b/2 + 1

my $i = $area + ($b / 2) + 1;

say $i;
