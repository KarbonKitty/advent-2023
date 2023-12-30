#!/usr/bin/perl
use warnings;
use 5.036;

use List::Util qw(min);

chomp(my @lines = <>);

my @map = map { [ split(//, $_) ] } @lines;

(my $goalX, my $goalY) = ($#{$map[0]}, $#map);
my $minPath = $goalX * 9 + $goalY * 9;

say "goal: ($goalX, $goalY)";

my @nodes;

for my $x (0..$#map) {
    my @line;
    for my $y (0..$#{$map[0]}) {
        push(@line, &newNode($x, $y));
    }
    push(@nodes, \@line);
}

my $currentNodeRef = $nodes[0][0];

$currentNodeRef->{'n'} = 0;
$currentNodeRef->{'s'} = 0;
$currentNodeRef->{'e'} = 0;
$currentNodeRef->{'w'} = 0;

my @unprocessedNodes = (&packNode(0, 0, 0b11));

while (1) {
    my @nodesToProcess = @unprocessedNodes;

    # say "$#nodesToProcess";

    last unless @nodesToProcess;

    @unprocessedNodes = ();

    foreach my $p (@nodesToProcess) {
        (my $x, my $y, my $allowed) = &unpackNode($p);
        if (($allowed & 0b01) == 0b01) {
            # say "vertical";
            &walkVertical($x, $y, \@unprocessedNodes, 'n');
            &walkVertical($x, $y, \@unprocessedNodes, 's');
        }
        if (($allowed & 0b10) == 0b10) {
            &walkHorizontal($x, $y, \@unprocessedNodes, 'e');
            &walkHorizontal($x, $y, \@unprocessedNodes, 'w');
        }
        # say "unprocessed Nodes: $#unprocessedNodes";
    }
}

my %goalNode = %{$nodes[$goalY][$goalX]};

say "n: $goalNode{'n'}, s: $goalNode{'s'}, e: $goalNode{'e'}, w: $goalNode{'w'}";

# foreach my $line (@nodes) {
#     my $l;
#     foreach my $node (@{$line}) {
#         printf("%3d ", &minDist($node));
#     }
#     print "\n";
# }

my $minDistance = &minDist(\%goalNode);

say $minDistance;

sub minDist($nodeRef) {
    return min($nodeRef->{'n'}, $nodeRef->{'s'}, $nodeRef->{'e'}, $nodeRef->{'w'});
}

# allowed: 01 vertical, 10 horizontal
sub packNode($x, $y, $allowed) {
    return ($x << 17) | ($y << 2) | $allowed;
}

sub unpackNode($p) {
    return ($p >> 17, ($p >> 2) & 0b0111_1111_1111_1111, $p & 0b11);
}

sub newNode($x, $y) {
    return { 'x' => $x, 'y' => $y, 'n' => $minPath, 's' => $minPath, 'e' => $minPath, 'w' => $minPath };
}

sub walkVertical($x, $y, $unprocessedNodesRef, $dir) {
    my %baseNode = %{$nodes[$y][$x]};
    my $column = $x;
    my $l = $dir eq 'n' ? 's' : 'n';

    my $heatLoss = min($baseNode{'w'}, $baseNode{'e'});

    for my $i (1..10) {
        my $row = $y + ($i * ($dir eq 'n' ? -1 : 1));
        # say "($column, $row) dir: $dir, heat loss: $heatLoss";
        last if $row < 0 && $dir eq 'n';
        last if $row > $goalY && $dir eq 's';
        $heatLoss += $map[$row][$column];
        next if $i < 4;
        next if $nodes[$row][$column]->{$l} <= $heatLoss;
        # {
        #     # say "($x, $y) - ($column, $row): heat loss: $heatLoss";# if ($column == $goalX || $row == $goalY);
        # }
        $nodes[$row][$column]->{$l} = $heatLoss;
        push(@{$unprocessedNodesRef}, &packNode($column, $row, 0b10));
    }
}

sub walkHorizontal($x, $y, $unprocessedNodesRef, $dir) {
    my %baseNode = %{$nodes[$y][$x]};
    my $row = $y;
    my $l = $dir eq 'e' ? 'w' : 'e';

    my $heatLoss = min($baseNode{'n'}, $baseNode{'s'});

    for my $i (1..10) {
        my $col = $x + ($i * ($dir eq 'w' ? -1 : 1));
        # say "($col, $row) dir: $dir, heat loss: $heatLoss";
        last if $col < 0 && $dir eq 'w';
        last if $col > $goalX && $dir eq 'e';
        $heatLoss += $map[$row][$col];
        next if $i < 4;
        next if $nodes[$row][$col]->{$l} <= $heatLoss;
        # {
        #     # say "($x, $y) - ($col, $row): heat loss: $heatLoss";# if ($col == $goalX || $row == $goalY);
        # }
        $nodes[$row][$col]->{$l} = $heatLoss;
        push(@{$unprocessedNodesRef}, &packNode($col, $row, 0b01));
    }
}
