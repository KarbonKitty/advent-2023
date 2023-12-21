#!/usr/bin/perl
use warnings;
use 5.036;

use List::Util qw(sum);

my $sum;
my %cache;

while(<>) {
    chomp;
    (my $springs, my $groups) = split(/ /);

    $springs = join('?', $springs, $springs, $springs, $springs, $springs);
    $groups = join(',', $groups, $groups, $groups, $groups, $groups);

    my @groups = map { int $_ } split(/,/, $groups);

    my $key = "$springs,@groups";
    $cache{$key} = 

    $sum += &countOptions($springs, \@groups);
}

say $sum;

sub countOptions($springs, $groupsRef) {
    my @groups = @{$groupsRef};

    my $key = "$springs,@groups";
    if (exists $cache{$key}) {
        return $cache{$key};
    }

    while (1) {
        if ($#groups < 0) {
            # say "Springs: $springs, groups: @groups";
            my $hasSprings = $springs =~ /\#/;
            return $hasSprings ? &save($key, 0) : &save($key, 1);
        } elsif ((length $springs) <= 0) {
            return &save($key, 0);
        } elsif (substr($springs, 0, 1) eq '.') {
            $springs =~ s/^\.//;
            next;
        } elsif (substr($springs, 0, 1) eq '?') {
            substr($springs, 0, 1, '.');
            # say "Left: $springs";
            my $left = &countOptions($springs, \@groups);
            substr($springs, 0, 1, '#');
            # say "Right: $springs";
            my $right = &countOptions($springs, \@groups);
            return &save($key, $left + $right);
        } elsif (substr($springs, 0, 1) eq '#') {
            if ($#groups < 0) {
                return &save($key, 0);
            } elsif ((length $springs) < $groups[0]) {
                return &save($key, 0);
            } elsif (substr($springs, 0, $groups[0]) =~ /\./) {
                return &save($key, 0);
            } elsif ($#groups == 0) {
                $springs = substr($springs, $groups[0]);
                shift @groups;
                next;
            } else {
                if (length $springs < $groups[0] + 1) {
                    return &save($key, 0);
                } elsif (substr($springs, $groups[0], 1) eq '#') {
                    return &save($key, 0);
                }

                $springs = substr($springs, $groups[0]+1);

                shift @groups;
                next;
            }
        } else {
            say "Wrong input: $springs";
            return 0;
        }
    }
}

sub save($key, $value) {
    $cache{$key} = $value;
    return $value;
}
