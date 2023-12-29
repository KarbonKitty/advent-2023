#!/usr/bin/perl
use warnings;
use 5.036;

use List::Util qw(min);

chomp(my @lines = <>);

my @map = map { [ split(//, $_) ] } @lines;

(my $goalX, my $goalY) = ($#{$map[0]}, $#map);
my $minPath = $goalX * 9 + $goalY * 9;

my @nodes;

for my $x (0..$#map) {
    my @line;
    for my $y (0..$#{$map[0]}) {
        push(@line, &newNode($x, $y));
    }
    push(@nodes, \@line);
}

my $currentNodeRef = $nodes[0][0];

$currentNodeRef->{'n1'} = 0;
$currentNodeRef->{'n2'} = 0;
$currentNodeRef->{'n3'} = 0;
$currentNodeRef->{'s1'} = 0;
$currentNodeRef->{'s2'} = 0;
$currentNodeRef->{'s3'} = 0;
$currentNodeRef->{'e1'} = 0;
$currentNodeRef->{'e2'} = 0;
$currentNodeRef->{'e3'} = 0;
$currentNodeRef->{'w1'} = 0;
$currentNodeRef->{'w2'} = 0;
$currentNodeRef->{'w3'} = 0;

my @unprocessedNodes = (&packNode(0, 0));

my $roundNumber = 0;

while (1) {
    $roundNumber++;

    my @nodesToProcess = @unprocessedNodes;

    last unless @nodesToProcess;

    @unprocessedNodes = ();

    foreach my $p (@nodesToProcess) {
        (my $x, my $y) = &unpackNode($p);
        &processNode($x, $y, 0b0001, \@unprocessedNodes, $roundNumber);
        &processNode($x, $y, 0b0010, \@unprocessedNodes, $roundNumber);
        &processNode($x, $y, 0b0100, \@unprocessedNodes, $roundNumber);
        &processNode($x, $y, 0b1000, \@unprocessedNodes, $roundNumber);
    }
}

my %goalNode = %{$nodes[$goalY][$goalX]};

my $minDistance = min($goalNode{'n1'}, $goalNode{'n2'}, $goalNode{'n3'}, $goalNode{'s1'}, $goalNode{'s2'}, $goalNode{'s3'},
                      $goalNode{'e1'}, $goalNode{'e2'}, $goalNode{'e3'}, $goalNode{'w1'}, $goalNode{'w2'}, $goalNode{'w3'});

say $minDistance;

sub packNode($x, $y) {
    return ($x << 16) | $y;
}

sub unpackNode($p) {
    return ($p >> 16, $p & 0xffff);
}

sub newNode($x, $y) {
    return {
        'x' => $x, 'y' => $y, 'selectedRound' => 0,
        'n1' => $minPath, 'n2' => $minPath, 'n3' => $minPath,
        's1' => $minPath, 's2' => $minPath, 's3' => $minPath,
        'e1' => $minPath, 'e2' => $minPath, 'e3' => $minPath,
        'w1' => $minPath, 'w2' => $minPath, 'w3' => $minPath };
}

sub processNode($x, $y, $dir, $unprocessedNodesRef, $roundNumber) {
    (my $newX, my $newY) = &moveDir($x, $y, $dir);

    if ($newX < 0 || $newY < 0 || $newX > $goalX || $newY > $goalY) {
        return;
    }

    my $previousRef = $nodes[$y][$x];
    my $nextRef = $nodes[$newY][$newX];

    my $heatLoss = $map[$newY][$newX];

    my $best = ($dir == 0b0001 || $dir == 0b0100)
        ? min($previousRef->{'n1'}, $previousRef->{'n2'}, $previousRef->{'n3'}, $previousRef->{'s1'}, $previousRef->{'s2'}, $previousRef->{'s3'})
        : min($previousRef->{'e1'}, $previousRef->{'e2'}, $previousRef->{'e3'}, $previousRef->{'w1'}, $previousRef->{'w2'}, $previousRef->{'w3'});

    &updateNode($nextRef, $previousRef, $heatLoss, $best, $dir, $unprocessedNodesRef);
}

sub moveDir($x, $y, $dir) {
    if ($dir == 0b0001) {
        return ($x + 1, $y);
    } elsif ($dir == 0b0010) {
        return ($x, $y + 1);
    } elsif ($dir == 0b0100) {
        return ($x - 1, $y);
    } elsif ($dir == 0b1000) {
        return ($x, $y - 1);
    } else {
        die "Unknown dir: $dir";
    }
}

sub updateNode($nextNodeRef, $previousNodeRef, $heatLoss, $best, $dir, $unprocessedNodesRef) {
    my $changed = 0;
    (my $one, my $two, my $three);
    if ($dir == 0b1000) {
        ($one, $two, $three) = ('n1', 'n2', 'n3');
    } elsif ($dir == 0b0010) {
        ($one, $two, $three) = ('s1', 's2', 's3');
    } elsif ($dir == 0b0001) {
        ($one, $two, $three) = ('e1', 'e2', 'e3');
    } elsif ($dir == 0b0100) {
        ($one, $two, $three) = ('w1', 'w2', 'w3');
    }

    if ($heatLoss + $best < $nextNodeRef->{$one}) {
        $nextNodeRef->{$one} = $heatLoss + $best;
        $changed = 1;
    }
    if ($heatLoss + $previousNodeRef->{$one} < $nextNodeRef->{$two}) {
        $nextNodeRef->{$two} = $heatLoss + $previousNodeRef->{$one};
        $changed = 1;
    }
    if ($heatLoss + $previousNodeRef->{$two} < $nextNodeRef->{$three}) {
        $nextNodeRef->{$three} = $heatLoss + $previousNodeRef->{$two};
        $changed = 1;
    }

    if ($changed && $nextNodeRef->{'selectedRound'} != $roundNumber) {
        $nextNodeRef->{'selectedRound'} = $roundNumber;
        push(@{$unprocessedNodesRef}, &packNode($nextNodeRef->{'x'}, $nextNodeRef->{'y'}));
    }
}
