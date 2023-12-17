#!/usr/bin/perl
use warnings;
use 5.036;

chomp(my @lines = <>);

# preprocess the map to account for expansion
my @columnsEmptiness = map { 0 } (0..(length($lines[0]) - 1));

my @partialMap;
my @galaxyMap;

# check for empty columns and add empty rows
# number the galaxies as we go along
foreach my $line (@lines) {
    my $isEmpty = 1;
    while ($line =~ /\#/g) {
        $isEmpty = 0;
        my $startIndex = (pos $line) - 1;
        $columnsEmptiness[$startIndex] += 1;
    }
    push(@partialMap, $line);
    if ($isEmpty) {
        push(@partialMap, $line);
    }
}

# say "@columnsEmptiness";

my @emptyColumns = grep { $columnsEmptiness[$_] == 0 } 0..$#columnsEmptiness;

say "@emptyColumns";

# add empty columns
foreach my $line (@partialMap) {
    my @row = split(//, $line);
    # we need to increase the offset by one for each added column
    # since we push them to the right when adding new columns
    my $offset = 0;
    foreach my $emptyColumn (@emptyColumns) {
        $offset++;
        splice(@row, ($emptyColumn + $offset), 0, '.');
    }
    push(@galaxyMap, \@row);
}

for my $rowRef (@galaxyMap) {
    say "@{$rowRef}";
}

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
    my $left = abs($x1 - $x2);
    my $down = abs($y1 - $y2);
    return $left + $down;
}

