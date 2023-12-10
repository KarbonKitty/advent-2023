#!/usr/bin/perl
use warnings;
use 5.036;

use List::Util qw(min);

chomp(my @lines = <>);

# to ensure that the last set of ranges get processed correctly
if ($lines[-1] ne '') {
    push(@lines, '');
}

my @seedRanges = $lines[0] =~ /(\d+)/g;
my @seeds;

# say "@seedRanges";

for my $i (0..$#seedRanges) {
    next if ($i % 2 == 1);
    my $start = $seedRanges[$i];
    my $end = $seedRanges[$i] + $seedRanges[$i+1];
    # say "Start: " . $start . " end: " . $end;
    push(@seeds, { 'start' => $start, 'end' => $end });
}

my $gettingRanges = 0;
my $processingRanges = 0;
my @ranges;

my @processedSeeds;

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
        @ranges = sort { $a->{'start'} <=> $b->{'start'} } @ranges;
        push(@ranges, { 'start' => $ranges[-1]->{'end'}, 'end' => ~0, 'offset' => 0 });
        for my $i (0..$#seeds) {
            my $seedRangeRef = $seeds[$i];
            # say "Seed range: $seedRangeRef->{'start'} - $seedRangeRef->{'end'}";

            for my $rangeRef (@ranges) {
                # say "Processing range: $rangeRef->{'start'} - $rangeRef->{'end'}";

                if ($seedRangeRef->{'start'} > $rangeRef->{'end'}) {
                    next;
                }
                if ($seedRangeRef->{'start'} < $rangeRef->{'start'}) {
                    if ($seedRangeRef->{'end'} < $rangeRef->{'start'}) {
                        push(@processedSeeds, $seedRangeRef);
                        last;
                    } else {
                        my $newZeroRange = { 'start' => $seedRangeRef->{'start'}, 'end' => $rangeRef->{'start'} - 1 };
                        push(@processedSeeds, $newZeroRange);
                        $seedRangeRef->{'start'} = $rangeRef->{'start'};
                        redo;
                    }
                }
                if ($seedRangeRef->{'start'} >= $rangeRef->{'start'}) {
                    if ($seedRangeRef->{'end'} <= $rangeRef->{'end'}) {
                        my $newOffsetRange = { 'start' => $seedRangeRef->{'start'} + $rangeRef->{'offset'}, 'end' => $seedRangeRef->{'end'} + $rangeRef->{'offset'}};
                        push(@processedSeeds, $newOffsetRange);
                        last;
                    } else {
                        my $newOffsetRange = { 'start' => $seedRangeRef->{'start'} + $rangeRef->{'offset'}, 'end' => $rangeRef->{'end'} + $rangeRef->{'offset'}};
                        push(@processedSeeds, $newOffsetRange);
                        $seedRangeRef->{'start'} = $rangeRef->{'end'};
                    }
                }
            }
        }
        @seeds = @processedSeeds;
        say "Number of seed ranges: ($#seeds + 1)";
        @processedSeeds = ();
        @ranges = ();
        $processingRanges = 0;
    }
}

my @sortedSeeds = sort { $a->{'start'} <=> $b->{'start'} } @seeds;
say $sortedSeeds[0]->{'start'};
