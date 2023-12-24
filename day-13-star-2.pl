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
    my @pattern = @{$patternRef};

    my $mirrorValue = 0;
    # we need to ignore the original mirror, even if it's still viable...
    my $originalValue = &checkPattern(\@pattern, 0);

    # make a new pattern with a single position flipped and test it
    for my $ln (0..$#pattern) {
        for my $x (0..((length $pattern[$ln]) - 1)) {
            my @modifiedPattern = @pattern;
            $modifiedPattern[$ln] = &swap($modifiedPattern[$ln], $x);

            # ...and we need to do it inside the checkPattern...
            $mirrorValue = &checkPattern(\@modifiedPattern, $originalValue);

            if ($mirrorValue > 0 && $mirrorValue != $originalValue) {
                # say "Pattern number: $patternNumber, value: $mirrorValue, changed: ($x, $ln)";
                # foreach my $line (@modifiedPattern) {
                #     say $line;
                # }
                last;
            }
        }
        if ($mirrorValue > 0 && $mirrorValue != $originalValue) {
            last;
        }
    }

    if ($mirrorValue == $originalValue) {
        say "Pattern number: $patternNumber, new mirror not found";
    }
    $sum += $mirrorValue;
}

say $sum;

sub swap($str, $idx) {
    my $c = substr($str, $idx, 1);
    if ($c eq '.') {
        substr($str, $idx, 1, '#');
    } elsif ($c eq '#') {
        substr($str, $idx, 1, '.');
    } else {
        die "what?";
    }
    return $str;
}

sub checkPattern($patternRef, $originalValue) {
    # find horizontal mirrors
    my @pattern = @{$patternRef};
    my $mirror = 0;

    # look for potential horizontal mirrors
    for my $i (1..$#pattern) {
        if ($pattern[$i - 1] eq $pattern[$i]) {
            # check all the other rows
            (my $top, my $bottom) = ($i - 2, $i + 1);
            $mirror = 1;
            while ($top >= 0 && $bottom <= $#pattern) {
                if ($pattern[$top--] ne $pattern[$bottom++]) {
                    $mirror = 0;
                    $top = 0;
                }
            }
            # ...because we need to keep looking if the first mirror
            # we find is an old one...
            if ($mirror && ($i * 100 != $originalValue)) {
                return $i * 100;
            }
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
                # say "L: $left, R: $right";
                push(@goodMirrors, $vMirror);
            }
        }
        @vMirrors = @goodMirrors;
    }
    if (@vMirrors) {
        # ...and sometimes we might have two viable vertical
        # mirrors in the same pattern
        @vMirrors = grep { $_ != $originalValue } @vMirrors;
        if ($#vMirrors > 0) {
            say "Error: $patternNumber";
        } elsif (@vMirrors) {
            return $vMirrors[0];
        }
    } else {
        # say "Pattern: $patternNumber, mirror not found";
        return 0;
    }
}
