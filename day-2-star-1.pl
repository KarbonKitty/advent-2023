#!/usr/bin/perl
use warnings;
use 5.036;

chomp(my @lines = <>);
my @numbers;
my $sum = 0;

foreach (@lines) {
    my @gameParts = split(":");
    $gameParts[0] =~ /\d+/;
    my $gameNumber = $&;

    my @draws = split(";", $gameParts[1]);
    my $drawLegit = 1;
    foreach (@draws) {
        $drawLegit *= &checkDraw($_);
    }

    $sum += ($gameNumber * $drawLegit);

    say $sum;
}

sub checkDraw {
    my ($draw) = @_;
    my @cubes = split(",", $draw);
    foreach (@cubes) {
        /(\d+) (blue|red|green)/;
        #say "$1" . " $2";
        if ($2 eq "blue" && $1 > 14) {
            return 0;
        } elsif ($2 eq "red" && $1 > 12) {
            return 0;
        } elsif ($2 eq "green" && $1 > 13) {
            return 0;
        }
    }
    return 1;
}
