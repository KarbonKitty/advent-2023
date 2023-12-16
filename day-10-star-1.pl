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
    '7' => 0b0011,
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

my @map;
foreach my $line (@lines) {
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
# say $n;
$sConnections |= $connections{$pipes{$n} & 0b0010};
# say $sConnections;
# left character
($xn, $yn) = ($xs - 1, $yn);
$n = $map[$yn][$xn];
$sConnections |= $connections{$pipes{$n} & 0b0100};
# say $sConnections;
# down character
($xn, $yn) = ($xs, $ys + 1);
$n = $map[$yn][$xn];
# say "test: " . ($pipes{$n} & 0b1000);
$sConnections |= $connections{$pipes{$n} & 0b1000};
# say $sConnections;
# right character
($xn, $yn) = ($xs + 1, $ys);
$n = $map[$yn][$xn];
$sConnections |= $connections{$pipes{$n} & 0b0001};
# say $sConnections;

foreach my $c (keys %pipes) {
    if ($pipes{$c} == $sConnections) {
        # say $c;
        $map[$ys][$xs] = $c;
        last;
    }
}

my $firstDir;
for my $i (0..3) {
    if (($sConnections >> $i) & 1 == 1) {
        $firstDir = 1 << $i;
        last;
    }
}

my ($x, $y) = &moveInDirection($xs, $ys, $firstDir);
my $i = 1;
my $cameFromDir = $connections{$firstDir};

while ($x != $xs || $y != $ys) {
    $i++;
    my $currentChar = $map[$y][$x];
    # say "($x,$y): $currentChar";
    # last;
    my $currentPipe = $pipes{$map[$y][$x]};
    my $nextDir = $currentPipe ^ $cameFromDir;
    ($x, $y) = &moveInDirection($x, $y, $nextDir);
    $cameFromDir = $connections{$nextDir};
}

say ($i / 2);

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
