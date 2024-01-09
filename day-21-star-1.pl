#!/usr/bin/perl
use warnings;
use 5.036;

chomp(my @lines = <>);

my @map;

foreach my $line (@lines) {
    push(@map, [ split(//, $line) ]);
}

(my $startX, my $startY);
(my $maxX, my $maxY) = ($#{$map[0]}, $#map);

for my $y (0..$#map) {
    if (grep { $_ eq 'S' } @{$map[$y]}) {
        $startY = $y;
        for my $x (0..$#{$map[$y]}) {
            if (${$map[$y]}[$x] eq 'S') {
                $startX = $x;
                last;
            }
        }
    }
}

${$map[$startY]}[$startX] = 'O';

for my $i (1..64) {
    # mark every possible next step
    for my $y (0..$#map) {
        for my $x (0..$#{$map[$y]}) {
            &nextStep($x, $y) if ${$map[$y]}[$x] eq 'O';
        }
    }

    # remove marks for current step
    for my $y (0..$#map) {
        for my $x (0..$#{$map[$y]}) {
            &cleanCurrentStep($x, $y);
        }
    }
}

my $count = 0;
# count the marked plots
for my $y (0..$#map) {
    for my $x (0..$#{$map[$y]}) {
        $count++ if ${$map[$y]}[$x] eq 'O';
    }
}
say $count;

# say "start: ($startX, $startY)";

sub nextStep($x, $y) {
    &tryMarkAsNextStep($x - 1, $y);
    &tryMarkAsNextStep($x + 1, $y);
    &tryMarkAsNextStep($x, $y - 1);
    &tryMarkAsNextStep($x, $y + 1);
}

sub tryMarkAsNextStep($x, $y) {
    if ($x < 0 || $x > $maxX || $y < 0 || $y > $maxY) {
        return;
    }

    my $char = ${$map[$y]}[$x];
    my $newChar = 'N';
    if ($char eq '#' || $char eq 'N' || $char eq 'B') {
        return;
    } elsif ($char eq 'O') {
        $newChar = 'B';
    }

    ${$map[$y]}[$x] = $newChar;
}

sub cleanCurrentStep($x, $y) {
    my $char = ${$map[$y]}[$x];
    my $newChar;

    if ($char eq 'B') {
        $newChar = 'N';
    } elsif ($char eq 'O') {
        $newChar = '.';
    } elsif ($char eq 'N') {
        $newChar = 'O';
    } else {
        return;
    }

    ${$map[$y]}[$x] = $newChar;
}
