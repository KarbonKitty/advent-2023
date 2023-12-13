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
        # say "@steps";
        next;
    }

    my @tmp = $line =~ /(\w{3}) = \((\w{3})\, (\w{3})\)/;
    $nodes{$tmp[0]} = { 'L' => $tmp[1], 'R' => $tmp[2] };
}

my $i = 0;
my @currentNodes = grep { /A\z/ } keys %nodes;

say "@currentNodes";

# look for loops instead
# and calculate the least common multiple

my @loopLengths;

foreach my $cn (@currentNodes) {
    my $currentNode = $cn;
    my $i = 0;
    my $previousDiff = 0;
    my $diff = 0;
    my $lastI = 0;
    # say $currentNode;
    while (1) {
        my $stepNumber = $i % ($#steps + 1);
        my $step = $steps[$stepNumber];
        my $nextNode = $nodes{$currentNode}->{$step};
        # say "Current: $cn, next: $nextNode";
        $currentNode = $nextNode;
        $i++;
        if ($currentNode =~ /Z\z/) {
            $previousDiff = $diff;
            $diff = $i - $lastI;
            last if $previousDiff == $diff;
            $lastI = $i;
            push(@loopLengths, $diff);
            # say $diff;
        }
    }
}

sub gcd($x, $y) {
    while ($x) { ($x, $y) = ($y % $x, $x) }
    return $y;
}
 
sub lcm($x, $y) {
    return ((($x && $y) and $x / &gcd($x, $y) * $y) or 0);
}

my $x = 1;
foreach my $ll (@loopLengths) {
    $x = lcm($x, $ll);
}

say $x;
