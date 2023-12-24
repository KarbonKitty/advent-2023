#!/usr/bin/perl
use warnings;
use 5.036;

chomp(my @lines = <>);

my @platform;

foreach my $line (@lines) {
    push(@platform, [split(//, $line)]);
}

my $moved = 1;
while ($moved) {
    $moved = 0;

    for my $i (1..$#platform) {
        my $aboveRef = $platform[$i - 1];
        my $thisRef = $platform[$i];
        $moved += &moveLine($aboveRef, $thisRef);
    }
}


# foreach my $r (@platform) {
#     say "@{$r}";
# }

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

sub moveLine($aboveRef, $thisRef) {
    my $moved = 0;
    for my $i (0..$#{$thisRef}) {
        my $c = ${$thisRef}[$i];
        if ($c eq 'O' && ${$aboveRef}[$i] eq '.') {
            ${$aboveRef}[$i] = 'O';
            ${$thisRef}[$i] = '.';
            $moved = 1;
        }
    }
    return $moved;
}
