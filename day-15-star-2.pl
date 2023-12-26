#!/usr/bin/perl
use warnings;
use 5.036;

chomp(my @lines = <>);

my $line = $lines[0];

my @boxes = map { [] } (0..255);

foreach my $s (split(/,/, $line)) {
    (my $label, my $cmd, my $focal) = $s =~ /([a-z]+)([=-])(\d*)/;
    my $boxNumber = &hashString($label);
    my $boxRef = \@{$boxes[$boxNumber]};
    if ($cmd eq '=') {
        my $replaced = &replaceInBox($boxRef, $label, $focal);
        unless ($replaced) {
            # say "Added [$label: $focal]";
            push(@{$boxRef}, [$label, $focal]);
        }
    }
    if ($cmd eq '-') {
        $boxes[$boxNumber] = [ grep { $$_[0] ne $label } @{$boxes[$boxNumber]} ];
    }

    # &printBoxes();
}

&countValues();

sub countValues {
    my $sum = 0;
    for my $i (0..255) {
        my @box = @{$boxes[$i]};
        for my $j (0..$#box) {
            $sum += ($i + 1) * ($j + 1) * $box[$j][1];
        }
    }
    say $sum;
}

sub printBoxes {
    for my $i (0..255) {
        my @box = @{$boxes[$i]};
        if (@box) {
            print "Box number: $i";
        }
        foreach my $lensRef (@box) {
            print " [$$lensRef[0]: $$lensRef[1]]";
        }
        if (@box) {
            print "\n";
        }
    }
    say " ";
}

sub replaceInBox($boxRef, $label, $focal) {
    foreach my $lensRef (@{$boxRef}) {
        if (${$lensRef}[0] eq $label) {
            # say "replaced ${$lensRef}[0]: ${$lensRef}[1] with $focal";
            ${$lensRef}[1] = $focal;
            return 1;
        }
    }
    return 0;
}

sub hashString($str) {
    my $val = 0;
    foreach my $c (split(//, $str)) {
        $val = &hash($val, $c);
    }
    return $val;
}

sub hash($value, $char) {
    $value += ord($char);
    $value *= 17;
    return $value % 256;
}
