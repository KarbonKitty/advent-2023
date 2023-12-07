#!/usr/bin/perl
use warnings;
use 5.036;

chomp(my @lines = <>);

# get stars from every line into an array of arrays
my @symbolsInLine;
foreach my $line (@lines) {
    push(@symbolsInLine, &symbols($line));
}

# get all numbers from each line into an array of arrays of hashes
# the hashes are { startPosition, endPosition, value }

my @numbersInLine;
foreach my $line (@lines) {
    push(@numbersInLine, &numbers($line));
}

# get numbers from line-1, line and line+1 into a single array
my @lineNumbers = (0..$#lines);
my @hoodNumbers;
foreach my $i (@lineNumbers) {
    my @previousLine;
    my @nextLine;
    if ($i > 0) {
        @previousLine = @{$numbersInLine[$i-1]};
    }
    my @currentLine = @{$numbersInLine[$i]};
    if ($i < $#lines) {
        @nextLine = @{$numbersInLine[$i+1]};
    }

    my $lineNumbers = [@previousLine, @currentLine, @nextLine];

    push(@hoodNumbers, $lineNumbers);
}

# iterate over stars checking if they touch a number

my $sum = 0;
my $i = 0;

foreach my $lineOfStarsRef (@symbolsInLine) {
    my $lineOfNumbersRef = $hoodNumbers[$i];
    $i++;
    foreach my $star (@{$lineOfStarsRef}) {
        my @touches;
        foreach my $numberHashRef (@{$lineOfNumbersRef}) {
            if ($star > %{$numberHashRef}{'startPos'} - 2 && $star < %{$numberHashRef}{'endPos'} + 1) {
                my $numValue = %{$numberHashRef}{'value'};
                push(@touches, $numValue);
            }
        }
        if ($#touches == 1) {
            $sum += $touches[0] * $touches[1];
        }
    }
}

say $sum;

# returns a reference to an array with positions of the symbols
sub symbols($line) {
    my @matches;
    while ($line =~ m/([\*])/g) {
        push(@matches, (pos $line) - 1);
    }
    return \@matches;
}

sub numbers($line) {
    my @matches;
    while ($line =~ m/(\d+)/g) {
        my $endIndex = pos $line;
        my $startIndex = $endIndex - length($&);
        push(@matches, { startPos => $startIndex, endPos => $endIndex, value => int($&) });
    }
    return \@matches;
}
