#!/usr/bin/perl
use warnings;
use 5.036;

chomp(my @lines = <>);
my @numbers;
my $sum = 0;

foreach (@lines) {
    /(\d|one|two|three|four|five|six|seven|eight|nine)/;
    my $first = &parse($1);
    /.*(\d|one|two|three|four|five|six|seven|eight|nine)/;
    my $second = &parse($1);

    $sum += int($first . $second);
}

sub parse {
    my ($word) = @_;
    if ($word =~ /\d/) {
        return int($word);
    }
    if ($word eq "one") {
        return 1;
    } elsif ($word eq "two") {
        return 2;
    } elsif ($word eq "three") {
        return 3;
    } elsif ($word eq "four") {
        return 4;
    } elsif ($word eq "five") {
        return 5;
    } elsif ($word eq "six") {
        return 6;
    } elsif ($word eq "seven") {
        return 7;
    } elsif ($word eq "eight") {
        return 8;
    } elsif ($word eq "nine") {
        return 9;
    } else {
        say "No idea: " . $word;
    }
}

say $sum;
