#!/usr/bin/perl
use warnings;
use 5.036;

chomp(my @lines = <>);
my @numbers;
my $sum = 0;

foreach (@lines) {
    /[^\d]?(\d)/;
    my $first = $1;
    /.*(\d)/;
    my $second = $1;

    $sum += int($first . $second);
}

say $sum;
