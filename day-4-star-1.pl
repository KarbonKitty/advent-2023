#!/usr/bin/perl
use warnings;
use 5.036;

chomp(my @lines = <>);

my $sum = 0;

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
    # count points per card
    for my $number (@myNumbers) {
        if (exists $winNumbers{$number}) {
            push(@numbersMatched, $number);
            if ($cardValue == 0) {
                $cardValue = 1;
            } else {
                $cardValue *= 2;
            }
        }
    }
    # say $card . ": " . $cardValue . " " . "@numbersMatched";
    # say $card . " win numbers: @winNumbers" . " value: " . $cardValue;

    $sum += $cardValue;
}

say $sum;