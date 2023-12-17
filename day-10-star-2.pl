#!/usr/bin/perl
use warnings;
use 5.036;

# up -> 1000
# right -> 0100
# down -> 0010
# left -> 0001

my %pipes = (
    '|' => 0b1010,
    '-' => 0b0101,
    'L' => 0b1100,
    'F' => 0b0110,
    '?' => 0b0011,
    'J' => 0b1001,
    '.' => 0b0000,
    '' => 0b0000
);

my %connections = (
    0b1000 => 0b0010,
    0b0100 => 0b0001,
    0b0010 => 0b1000,
    0b0001 => 0b0100,
    0b0000 => 0b0000
);

chomp(my @lines = <>);

# we replace '7' with '?' in the map, to make it easier later
my @map;
foreach my $line (@lines) {
    $line =~ s/7/\?/g;
    # say $line;
    my @splitLine = split(//, $line);
    push(@map, \@splitLine);
}

# find S
my ($xs, $ys);
for my $y (0..$#map) {
    for my $x (0..$#{$map[$y]}) {
        if ($map[$y][$x] eq 'S') {
            ($xs, $ys) = ($x, $y);
        }
    }
}

# replace S with actual character
my $n;
my $sConnections = 0;
# top character
my ($xn, $yn) = ($xs, $ys - 1);
$n = $map[$yn][$xn];
$sConnections |= $connections{$pipes{$n} & 0b0010};
# left character
($xn, $yn) = ($xs - 1, $yn);
$n = $map[$yn][$xn];
$sConnections |= $connections{$pipes{$n} & 0b0100};
# down character
($xn, $yn) = ($xs, $ys + 1);
$n = $map[$yn][$xn];
$sConnections |= $connections{$pipes{$n} & 0b1000};
# right character
($xn, $yn) = ($xs + 1, $ys);
$n = $map[$yn][$xn];
$sConnections |= $connections{$pipes{$n} & 0b0001};

$map[$ys][$xs] = $sConnections;

my $firstDir;
for my $i (0..3) {
    if (($sConnections >> $i) & 1 == 1) {
        $firstDir = 1 << $i;
        last;
    }
}

my ($x, $y) = &moveInDirection($xs, $ys, $firstDir);
my $cameFromDir = $connections{$firstDir};

# replace the main loop pipes with connection numbers
while ($x != $xs || $y != $ys) {
    my $currentPipe = $pipes{$map[$y][$x]};
    my $nextDir = $currentPipe ^ $cameFromDir;

    $map[$y][$x] = $pipes{$map[$y][$x]};

    ($x, $y) = &moveInDirection($x, $y, $nextDir);
    $cameFromDir = $connections{$nextDir};
}

# clean up everything that isn't a number
for my $i (0..$#map) {
    for my $j (0..$#{$map[$i]}) {
        unless ($map[$i][$j] =~ /\d/) {
            $map[$i][$j] = 0;
        }
    }
}

# mark each top-left corner as either inside or outside
my @corners;
for my $yi (0..$#map) {
    my $inside = 0;
    my @row;
    for my $xi (0..$#{$map[$yi]}) {
        my $char = $map[$yi][$xi];
        # if the tile has a pipe "up", we are crossing
        # from outside to inside or vice versa
        if (($char & 0b1000) == 0b1000) {
            if ($inside == 0) {
                $inside = 1;
            } else {
                $inside = 0;
            }
        }
        push(@row, $inside);
    }
    # add "outside" corner at the top right
    push(@row, 0);
    push(@corners, \@row);
}
# add entire row of "outside" corners to the bottom
push(@corners, [map { 0 } (0..($#{$map[0]} + 1))]);

## debug display of corners
# foreach my $t (@corners) {
#     say "@{$t}";
# }

# count chars inside
my $charsInside = 0;

for my $yi (0..$#map) {
    for my $xi (0..$#{$map[$yi]}) {
        $charsInside += &isInside($xi, $yi, \@corners);
    }
}

say $charsInside;

# return a pair of values that are the coordinates
# in the direction passed
# (see the table of directions at the top)
sub moveInDirection($x, $y, $dir) {
    if ($dir == 0b1000) {
        return ($x, $y - 1);
    } elsif ($dir == 0b0100) {
        return ($x + 1, $y);
    } elsif ($dir == 0b0010) {
        return ($x, $y + 1);
    } elsif ($dir == 0b0001) {
        return ($x - 1, $y);
    } else {
        return ($x, $y);
    }
}

# check if all four corners are marked "inside"
# if at least one is not, we return 0
# otherwise, we return 1
sub isInside($x, $y, $cornersRef) {
    if (${$cornersRef}[$y][$x] == 0) {
        return 0;
    } elsif (${$cornersRef}[$y + 1][$x] == 0) {
        return 0;
    } elsif (${$cornersRef}[$y][$x + 1] == 0) {
        return 0;
    } elsif (${$cornersRef}[$y + 1][$x + 1] == 0) {
        return 0;
    }
    return 1;
}
