#!/usr/bin/perl
use warnings;
use 5.036;

use List::Util qw(min);

chomp(my @lines = <>);

# to ensure that the last set of ranges get processed correctly
if ($lines[-1] ne '') {
    push(@lines, '');
}

my @seeds = $lines[0] =~ /(\d+)/g;
my @processedSeeds;

my $gettingRanges = 0;
my $processingRanges = 0;
my @ranges;

# range is a hash of { start, end, offset }

for my $line (@lines[2..$#lines]) {
    if ($line eq '') {
        $gettingRanges = 0;
        $processingRanges = 1;
    }
    if ($line =~ /\:/) {
        $gettingRanges = 1;
        next;
    }
    if ($gettingRanges) {
        my ($destinationStart, $sourceStart, $rangeLength) = $line =~ /(\d+)/g;
        push(@ranges, { 'start' => $sourceStart, 'end' => $sourceStart + $rangeLength, 'offset' => $destinationStart - $sourceStart });
        # say $#ranges;
    }
    if ($processingRanges) {
        for my $i (0..$#seeds) {
            my $seed = $seeds[$i];
            for my $rangeRef (@ranges) {
                if ($seed >= $rangeRef->{'start'} && $seed < $rangeRef->{'end'}) {
                    $seeds[$i] += $rangeRef->{'offset'};
                    last;
                }
            }
        }
        say "@seeds";
        @ranges = ();
        $processingRanges = 0;
    }
}

say "@seeds";
say min(@seeds);
