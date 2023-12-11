#!/usr/bin/perl
use warnings;
use 5.036;

chomp(my @lines = <>);

my %labelValues = ( 'A' => 13, 'K' => 12, 'Q' => 11, 'J' => 10, 'T' => 9, '9' => 8, '8' => 7, '7' => 6, '6' => 5, '5' => 4, '4' => 3, '3' => 2, '2' => 1 );
my %valuedHands;

for my $line (@lines) {
    my ($hand, $bet) = split(/\s+/, $line);
    my $handValue = &handValue($hand);
    $valuedHands{$handValue} = $bet;
}

# hash key is a string, so make it a number before sorting
my @sortedHandValues = sort { $a <=> $b } keys %valuedHands;

my $sum = 0;

for my $i (1..($#sortedHandValues + 1)) {
    my $bet = $valuedHands{$sortedHandValues[$i - 1]};
    $sum += ($bet * $i);
}

say $sum;

sub handValue($hand) {
    my $value = 0;
    my @cards = split(//, $hand);
    my %cards;
    foreach my $card (@cards) {
        $cards{$card} += 1;
    }

    my @cardCounts = sort { $b <=> $a } values %cards;

    if ($cardCounts[0] == 5) {
        $value = (6 << 20);
    } elsif ($cardCounts[0] == 4) {
        $value = (5 << 20);
    } elsif ($cardCounts[0] == 3) {
        if ($cardCounts[1] == 2) {
            $value = (4 << 20);
        } else {
            $value = (3 << 20);
        }
    } elsif ($cardCounts[0] == 2) {
        if ($cardCounts[1] == 2) {
            $value = (2 << 20);
        } else {
            $value = (1 << 20);
        }
    } else {
        $value = 0;
    }

    for my $i (0..$#cards) {
        my $card = $cards[$i];
        my $cardValue = $labelValues{$card};
        my $shiftValue = (4 - $i) * 4;
        $value |= ($cardValue << $shiftValue);
    }

    return $value;
}
