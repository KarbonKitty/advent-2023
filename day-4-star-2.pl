#!/usr/bin/perl
use warnings;
use 5.036;

use List::Util qw(sum);

chomp(my @lines = <>);

my $sum = 0;
my %cardCopies;
my $i = 1;

foreach my $line (@lines) {
    my ($card, $winNumbers, $myNumbers) = split(/\s?[\:\|]\s?/, $line);

    # get winning numbers
    my @winNumbers = split(/\s+/, $winNumbers);
    my %winNumbers = map { $_ => 1 } grep { $_ ne '' } @winNumbers;

    # get your numbers
    my @myNumbers = split(/\s+/, $myNumbers);
    @myNumbers = grep { $_ ne '' } @myNumbers;

    my $cardValue = 0;
    my @numbersMatched;

    my $copiesOfCurrentCard = $cardCopies{$i};

    # count points per card
    for my $number (@myNumbers) {
        if (exists $winNumbers{$number}) {
            push(@numbersMatched, $number);
        }
    }

    $cardCopies{$i} += 1;
    $i++;

    for (my $j = 0; $j <= $#numbersMatched; $j++) {
        $cardCopies{$i + $j} += $cardCopies{$i - 1};
    }

    # print "$_ $cardCopies{$_}; " for (sort keys %cardCopies);
    # print "\n";
}

my @counts = values %cardCopies;
$sum = sum(@counts);
say $sum;
