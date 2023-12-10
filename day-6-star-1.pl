#!/usr/bin/perl
use warnings;
use 5.036;

use List::Util qw(reduce);

chomp(my @lines = <>);

my @times = $lines[0] =~ /(\d+)/g;
my @distances = $lines[1] =~ /(\d+)/g;

my @races;
for my $i (0..$#times) {
    push(@races, { 'time' => $times[$i], 'distance' => $distances[$i] });
}

foreach my $raceRef (@races) {
    my $waysToWin = 0;
    for my $timeHeld (0..$raceRef->{'time'}) {
        my $timeLeft = $raceRef->{'time'} - $timeHeld;
        my $myDistance = $timeHeld * $timeLeft;
        if ($myDistance > $raceRef->{'distance'}) {
            $waysToWin++;
        } elsif ($timeHeld > $timeLeft) {
            last;
        }
    }
    say $waysToWin;
    $raceRef->{'waysToWin'} = $waysToWin;
}

say reduce { $a * $b } (map { $_->{'waysToWin'} } @races);
