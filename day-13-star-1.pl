#!/usr/bin/perl
use warnings;
use 5.036;

my @patterns = ([]);

chomp(my @lines = <>);

while (@lines) {
    my $line = shift @lines;
    if (length $line) {
        push(@{$patterns[-1]}, $line);
    } else {
        push(@patterns, []);
    }
}

my $sum;
my $patternNumber = 0;

for my $patternRef (@patterns) {
    $patternNumber++;
    # find horizontal mirrors
    my @pattern = @{$patternRef};

    # look for potential horizontal mirrors
    for my $i (1..$#pattern) {
        if ($pattern[$i - 1] eq $pattern[$i]) {
            # check all the other rows
            (my $top, my $bottom) = ($i - 2, $i + 1);
            my $mirror = 1;
            while ($top >= 0 && $bottom <= $#pattern) {
                if ($pattern[$top--] ne $pattern[$bottom++]) {
                    $mirror = 0;
                    $top = 0;
                }
            }
            if ($mirror) {
                say "Pattern: $patternNumber, horizontal mirror: $i";
            }
            $sum += $i * 100 * $mirror;
        }
    }

    # find vertical mirrors

    my @vMirrors;
    # check first line for potential mirror sites
    my $lineLength = length $pattern[0];
    for my $i (1..($lineLength - 1)) {
        my $len = $i < ($lineLength - $i) ? $i : $lineLength - $i;
        my $left = reverse substr($pattern[0], $i - $len, $len);
        my $right = substr($pattern[0], $i, $len);
        # say "Left: $left, right: $right";
        if ($left eq $right) {
            push(@vMirrors, $i);
        }
    }
    # say "@vMirrors";

    # for each following line
    foreach my $line (@pattern) {
        # check if the potential sites are mirror sites
        my @goodMirrors;
        for my $i (0..$#vMirrors) {
            my $vMirror = $vMirrors[$i];
            my $len = $vMirror < $lineLength - $vMirror ? $vMirror : $lineLength - $vMirror;
            my $left = reverse substr($line, $vMirror - $len, $len);
            my $right = substr($line, $vMirror, $len);
            # say "Mirror: $vMirror, left: $left, right: $right";
            if ($left eq $right) {
                push(@goodMirrors, $vMirror);
            }
        }
        @vMirrors = @goodMirrors;
    }
    if (@vMirrors) {
        say "Pattern: $patternNumber, vertical mirror: $vMirrors[0]";
        $sum += $vMirrors[0];
    }
}

say $sum;
