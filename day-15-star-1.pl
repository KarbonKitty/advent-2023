#!/usr/bin/perl
use warnings;
use 5.036;

chomp(my @lines = <>);

my $line = $lines[0];

my $sum = 0;

foreach my $s (split(/,/, $line)) {
    $sum += &hashString($s);
}

say $sum;

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
