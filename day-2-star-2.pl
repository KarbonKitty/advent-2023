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
    my @cubeCounts;
    my %minimumSet = ( "red" => 0, "green" => 0, "blue" => 0 );

    foreach (@draws) {
        my %cubeCounts = &countCubes($_);
        if ($cubeCounts{'red'} > $minimumSet{'red'}) {
            $minimumSet{'red'} = $cubeCounts{'red'}
        }
        if ($cubeCounts{'green'} > $minimumSet{'green'}) {
            $minimumSet{'green'} = $cubeCounts{'green'}
        }
        if ($cubeCounts{'blue'} > $minimumSet{'blue'}) {
            $minimumSet{'blue'} = $cubeCounts{'blue'}
        }
    }

    my $power = $minimumSet{'red'} * $minimumSet{'green'} * $minimumSet{'blue'};

    $sum += $power;

    say $sum;
}

# returns hash of cube counts
sub countCubes {
    my ($draw) = @_;
    my @cubes = split(",", $draw);
    my %cubeCounts = ( "red" => 0, "green" => 0, "blue" => 0 );
    foreach (@cubes) {
        /(\d+) (blue|red|green)/;
        $cubeCounts{$2} = $1;
    }
    return %cubeCounts;
}
