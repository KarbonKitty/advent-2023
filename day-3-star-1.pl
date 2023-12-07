#!/usr/bin/perl
use warnings;
use 5.036;

chomp(my @lines = <>);

# get symbols from every line into an array of arrays
my @symbolsInLine;
foreach my $line (@lines) {
    push(@symbolsInLine, &symbols($line));
}

# get symbols from line-1, line and line+1 into a single array
my @lineNumbers = (0..$#lines);
my @hoodSymbols;
foreach my $i (@lineNumbers) {
    my @previousLine;
    my @nextLine;
    if ($i > 0) {
        @previousLine = @{$symbolsInLine[$i-1]};
    }
    my @currentLine = @{$symbolsInLine[$i]};
    if ($i < $#lines) {
        @nextLine = @{$symbolsInLine[$i+1]};
    }

    my $lineSymbols = [@previousLine, @currentLine, @nextLine];

    push(@hoodSymbols, $lineSymbols);
}

# get all numbers from each line into an array of arrays of hashes
# the hashes are { startPosition, endPosition, value }

my @numbersInLine;
foreach my $line (@lines) {
    push(@numbersInLine, &numbers($line));
}

# iterate over numbers checking if they touch a symbol

my $sum = 0;
my $i = 0;
foreach my $lineOfNumbersRef (@numbersInLine) {
    my $lineSymbolsRef = $hoodSymbols[$i];
    $i++;
    foreach my $numberHashRef (@{$lineOfNumbersRef}) {
        # say %{$numberHashRef};
        foreach my $symbol (@{$lineSymbolsRef}) {
            if ($symbol > %{$numberHashRef}{'startPos'} - 2 && $symbol < %{$numberHashRef}{'endPos'} + 1) {
                #say "startIndex: " . %{$numberHashRef}{'startPos'} . "value: " . %{$numberHashRef}{'value'} . " symbol position: " . $symbol;
                $sum += %{$numberHashRef}{'value'};
                last;
            }
        }
    }
}

say $sum;

# returns a reference to an array with positions of the symbols
sub symbols($line) {
    my @matches;
    while ($line =~ m/([^\d\.])/g) {
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
        # say "start: " . $matches[-1]{'startPos'} . " end: " . $matches[-1]{'endPos'};
    }
    return \@matches;
}
