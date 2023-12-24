#!/usr/bin/perl
use warnings;
use 5.036;

chomp(my @lines = <>);

my @platform;
my %mem;

my $numberOfCycles = 1_000_000_000;


foreach my $line (@lines) {
    push(@platform, [split(//, $line)]);
}

for my $i (1..$numberOfCycles) {
    &moveCycle(\@platform);

    my $hash = &hashPlatform(\@platform);
    if ($mem{$hash}) {
        my $startPoint = $mem{$hash};
        my $cycleLength = $i - $mem{$hash};

        my $remainder = $numberOfCycles - $startPoint;
        my $position = $remainder % $cycleLength;
        $numberOfCycles = $position;

        # say "Iteration: $i, hash: $mem{$hash}";
        last;
    }
    $mem{&hashPlatform(\@platform)} = $i;
}

for my $i (1..$numberOfCycles) {
    &moveCycle(\@platform);
}

my $rows = scalar @platform;
my $sum = 0;
for my $i (0..$#platform) {
    foreach my $c (@{$platform[$i]}) {
        if ($c eq 'O') {
            $sum += ($rows - $i);
        }
    }
}

say $sum;

sub moveCycle($platformRef) {
    my @platform = @{$platformRef};

    # move north
    my $moved = 1;
    while ($moved) {
        $moved = 0;

        for my $i (1..$#platform) {
            my $aboveRef = $platform[$i - 1];
            my $thisRef = $platform[$i];
            $moved += &moveLine($aboveRef, $thisRef);
        }
    }

    # move west
    $moved = 1;
    while ($moved) {
        $moved = 0;

        for my $x (1..$#{$platform[0]}) {
            for my $y (0..$#platform) {
                $moved += &moveChar(\$platform[$y][$x - 1], \$platform[$y][$x]);
            }
        }
    }

    # move south
    $moved = 1;
    while ($moved) {
        $moved = 0;

        for my $i (0..($#platform - 1)) {
            my $belowRef = $platform[$i + 1];
            my $thisRef = $platform[$i];
            $moved += &moveLine($belowRef, $thisRef);
        }
    }

    # move east
    $moved = 1;
    while ($moved) {
        $moved = 0;

        for my $x (0..($#{$platform[0]} - 1)) {
            for my $y (0..$#platform) {
                $moved += &moveChar(\$platform[$y][$x + 1], \$platform[$y][$x]);
            }
        }
    }
}

sub moveLine($targetRef, $thisRef) {
    my $moved = 0;
    for my $i (0..$#{$thisRef}) {
        my $c = ${$thisRef}[$i];
        if ($c eq 'O' && ${$targetRef}[$i] eq '.') {
            ${$targetRef}[$i] = 'O';
            ${$thisRef}[$i] = '.';
            $moved = 1;
        }
    }
    return $moved;
}

sub moveChar($targetCharRef, $sourceCharRef) {
    my $moved = 0;
    # say "target: $targetCharRef, source: $sourceCharRef";
    if ($$sourceCharRef eq 'O' && $$targetCharRef eq '.') {
        $$targetCharRef = 'O';
        $$sourceCharRef = '.';
        $moved = 1;
    }
    return $moved;
}

sub hashPlatform($platformRef) {
    my @platform = @{$platformRef};

    my $t = '';
    foreach my $lineRef (@platform) {
        foreach my $c (@{$lineRef}) {
            $t .= $c;
        }
    }

    return $t;
}
