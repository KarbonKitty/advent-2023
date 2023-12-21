#!/usr/bin/perl
use warnings;
use 5.036;

chomp(my @lines = <>);

# preprocess the map to account for expansion
my @columnsEmptiness = map { 0 } (0..(length($lines[0]) - 1));

my @galaxyMap;
my @emptyRows;
my @emptyColumns;

# check for empty columns and add empty rows
# number the galaxies as we go along
my $rowNumber = 0;
foreach my $line (@lines) {
    my $isEmpty = 1;
    while ($line =~ /\#/g) {
        $isEmpty = 0;
        my $startIndex = (pos $line) - 1;
        $columnsEmptiness[$startIndex] += 1;
    }
    # my @x = split(//, $line);
    push(@galaxyMap, [ split(//, $line) ] );
    if ($isEmpty) {
        push(@emptyRows, $rowNumber);
    }
    $rowNumber++;
}

# say "@columnsEmptiness";

@emptyColumns = grep { $columnsEmptiness[$_] == 0 } 0..$#columnsEmptiness;

# say "@emptyColumns";

# for my $rowRef (@galaxyMap) {
#     say "@{$rowRef}";
# }

# find coordinates for the galaxies
my %galaxyCoords;
my $galaxyNumber = 0;

for my $y (0..$#galaxyMap) {
    for my $x (0..$#{$galaxyMap[$y]}) {
        my $char = $galaxyMap[$y][$x];
        if ($char eq '#') {
            $galaxyCoords{++$galaxyNumber} = { 'x' => $x, 'y' => $y };
        }
    }
}

# for my $t (keys %galaxyCoords) {
#     say "$t -> $galaxyCoords{$t}{'x'}, $galaxyCoords{$t}{'y'}";
# }

# calculate each distance and it up
my $sum = 0;
for my $i (1..$galaxyNumber) {
    for my $j (($i+1)..$galaxyNumber) {
        $sum += &distance($galaxyCoords{$i}{'x'}, $galaxyCoords{$i}{'y'}, $galaxyCoords{$j}{'x'}, $galaxyCoords{$j}{'y'});
    }
}

say $sum;

sub distance($x1, $y1, $x2, $y2) {
    my $extraDistance = 1_000_000 - 1;
    my ($xa, $xb) = $x1 < $x2 ? ($x1, $x2) : ($x2, $x1);
    my $left = $xb - $xa;
    my $extraCols = grep { $xa < $_ < $xb } @emptyColumns;
    $left += ($extraCols * $extraDistance);

    my ($ya, $yb) = $y1 < $y2 ? ($y1, $y2) : ($y2, $y1);
    my $down = $yb - $ya;
    my $extraRows = grep { $ya < $_ < $yb} @emptyRows;
    $down += ($extraRows * $extraDistance);
    return $left + $down;
}

