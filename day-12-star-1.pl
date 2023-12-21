#!/usr/bin/perl
use warnings;
use 5.036;

use List::Util qw(sum);

my $sum;

while(<>) {
    chomp;
    (my $springs, my $groups) = split(/ /);
    my @groups = split(/,/, $groups);

    my $totalSprings = sum @groups;
    # say "Total springs: $totalSprings";

    my @queue = ($springs);

    while (@queue) {
        my $current = shift @queue;
        my $brokenSprings = $current =~ tr/#//;
        my $springsLeft = $totalSprings - $brokenSprings;
        my $slotsLeft = $current =~ tr/?//;
        # my $slotsLeft = ($#slotsLeft + 1);

        # say "Slots: $slotsLeft, springs: $springsLeft";

        # check if legal
        if ($springsLeft < 0 || $slotsLeft < $springsLeft) {
            next;
        }
        # next unless &isLegal($current, \@groups);

        # if legal, check if leaf
        if ($slotsLeft == 0 && $springsLeft == 0) {
            $sum += &isGoodLeaf($current, \@groups);
            next;
        }

        # if not leaf, add two new ones
        my $left = $current =~ s/\?/\#/r;
        my $right = $current =~ s/\?/\./r;
        # say $left;
        # say $right;
        push(@queue, $left, $right);
    }

    # say @queue;
}

say $sum;

sub isGoodLeaf($springs, $groupsRef) {
    my @springs = $springs =~ /(\#+)/g;
    my @springGroups = map { length($_) } @springs;

    if ($#springGroups != $#{$groupsRef}) {
        return 0;
    }
    for my $i (0..$#springs) {
        if ($springGroups[$i] != ${$groupsRef}[$i]) {
            return 0;
        }
    }
    return 1;
}

