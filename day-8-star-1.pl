#!/usr/bin/perl
use warnings;
use 5.036;

chomp(my @lines = <>);

my @steps;
my %nodes;
foreach my $line (@lines) {
    next if $line eq '';

    if ($#steps < 0) {
        @steps = split(//, $line);
        say "@steps";
        next;
    }

    my @tmp = $line =~ /(\w{3}) = \((\w{3})\, (\w{3})\)/;
    $nodes{$tmp[0]} = { 'L' => $tmp[1], 'R' => $tmp[2] };
}

my $i = 0;
my $currentNode = 'AAA';
while (1) {
    my $stepNumber = $i % ($#steps + 1);
    my $step = $steps[$stepNumber];
    my $nextNode = $nodes{$currentNode}->{$step};
    say "Current: $currentNode, next: $nextNode";
    $currentNode = $nextNode;
    $i++;
    if ($currentNode eq 'ZZZ') {
        last;
    }
}

say $i;
