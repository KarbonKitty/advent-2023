#!/usr/bin/perl
use warnings;
use 5.036;

use List::Util qw(any);

chomp(my @lines = <>);

my $sum = 0;

foreach my $line (@lines) {
    my @sequences;
    my @sequence = split(/ /, $line);
    push(@sequences, \@sequence);
    while (1) {
        my @s = @{$sequences[-1]};
        my @s1 = @{$sequences[-1]}[0..($#{$sequences[-1]} - 1)];
        my @nextSequence = map { $s[$_ + 1] - $s1[$_] } (0..$#s1);
        if (any { $_ != 0 } @nextSequence) {
            push(@sequences, \@nextSequence);
        } else {
            # push(@sequences, \@nextSequence);
            last;
        }
    }

    @sequences = reverse @sequences;

    my $newElement = 0;
    foreach my $seqRef (@sequences) {
        my $lastElement = @$seqRef[-1];
        $newElement += $lastElement;
    }
    say $newElement;
    $sum += $newElement;
}

say $sum;
