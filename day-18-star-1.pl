#!/usr/bin/perl
use warnings;
use 5.036;

use List::Util qw(min);

chomp(my @lines = <>);

my @digs = map { [ split(/ /) ] } @lines;

(my $minX, my $maxX, my $minY, my $maxY) = (0, 0, 0, 0);
(my $x, my $y) = (0, 0);

foreach my $digRef (@digs) {
    (my $dir, my $len) = @{$digRef};

    if ($dir eq 'R') {
        $x += $len;
    } elsif ($dir eq 'L') {
        $x -= $len;
    } elsif ($dir eq 'U') {
        $y -= $len;
    } elsif ($dir eq 'D') {
        $y += $len;
    } else {
        die "Wrong dir: $dir";
    }

    if ($x > $maxX) { $maxX = $x }
    if ($x < $minX) { $minX = $x }
    if ($y > $maxY) { $maxY = $y }
    if ($y < $minY) { $minY = $y }
}

# say "upper left: ($minX, $minY), lower right: ($maxX, $maxY)";

(my $width, my $height) = (($maxX - $minX), ($maxY - $minY));

(my $startX, my $startY) = (-$minX, -$minY);

say "Start ($startX, $startY)";

my @lagoonMap;

for my $y (0..$height) {
    push(@lagoonMap, [map { '.' } (0..$width)]);
}

# dig the perimeter

($x, $y) = ($startX, $startY);
$lagoonMap[$y][$x] = '#';

foreach my $digRef (@digs) {
    (my $dir, my $len) = @{$digRef};

    if ($dir eq 'R') {
        for my $i (1..$len) {
            $x++;
            $lagoonMap[$y][$x] = '#';
        }
    } elsif ($dir eq 'L') {
        for my $i (1..$len) {
            $x--;
            $lagoonMap[$y][$x] = '#';
        }
    } elsif ($dir eq 'U') {
        for my $i (1..$len) {
            $y--;
            $lagoonMap[$y][$x] = '#';
        }
    } elsif ($dir eq 'D') {
        for my $i (1..$len) {
            $y++;
            $lagoonMap[$y][$x] = '#';
        }
    } else {
        die "Wrong dir: $dir";
    }
}

# foreach my $lineRef (@lagoonMap) {
#     my $s;
#     foreach my $c (@{$lineRef}) {
#         print "$c";
#     }
#     print "\n";
# }

# dig out the interior
my @queue = &pack($startX + 1, $startY + 1);
my %mem;

while (@queue) {
    my $p = shift @queue;
    $mem{$p} = 1;
    (my $x, my $y) = &unpack($p);

    $lagoonMap[$y][$x] = '#';

    # up
    my $up = &pack($x, $y - 1);
    if (!(defined $mem{$up}) && $lagoonMap[$y - 1][$x] eq '.') {
        push(@queue, $up);
        $mem{$up} = 1;
    }
    # down
    my $down = &pack($x, $y + 1);
    if (!(defined $mem{$down}) && $lagoonMap[$y + 1][$x] eq '.') {
        push(@queue, $down);
        $mem{$down} = 1;
    }
    # left
    my $left = &pack($x - 1, $y);
    if (!(defined $mem{$left}) && $lagoonMap[$y][$x - 1] eq '.') {
        push(@queue, $left);
        $mem{$left} = 1;
    }
    # right
    my $right = &pack($x + 1, $y);
    if (!(defined $mem{$right}) && $lagoonMap[$y][$x + 1] eq '.') {
        push(@queue, $right);
        $mem{$right} = 1;
    }
}

# count what was digged
my $count = 0;
foreach my $lineRef (@lagoonMap) {
    foreach my $c (@{$lineRef}) {
        if ($c eq '#') {
            $count += 1;
        }
    }
}

# foreach my $lineRef (@lagoonMap) {
#     my $s;
#     foreach my $c (@{$lineRef}) {
#         print "$c";
#     }
#     print "\n";
# }

say $count;

sub pack($x, $y) {
    return ($x << 16) | $y;
}

sub unpack($p) {
    return (($p >> 16), $p & 0xffff);
}
