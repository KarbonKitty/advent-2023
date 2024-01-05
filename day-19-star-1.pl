#!/usr/bin/perl
use warnings;
use 5.036;

chomp(my @lines = <>);

my @w;
my @p;

my $w = 1;
foreach my $line (@lines) {
    if ($w) {
        push(@w, $line);
    } else {
        push(@p, $line);
    }
    if ($line eq '') {
        $w = 0;
    }
}

# parse workflows
my %workflows;
foreach my $w (@w) {
    $w =~ /(\w+)\{(.*)\}/;
    my @rules = split(/,/, $2);
    my @workflow = map { &parseRule($_) } @rules ;
    $workflows{$1} = \@workflow;
}

# say "@workflows";

# parse parts
my @parts;
foreach my $p (@p) {
    $p =~ /\{x=(\d*),m=(\d*),a=(\d*),s=(\d*)\}/;
    push(@parts, { 'x' => $1, 'm' => $2, 'a' => $3, 's' => $4 });
}

# say "@parts";

my @accepted;

foreach my $partRef (@parts) {
    my @inWorkflow = @{$workflows{'in'}};

    my @currentWorkflow = @inWorkflow;

    my $processing = 1;
    while ($processing) {
        foreach my $ruleRef (@currentWorkflow) {
            my $result = &processRule($ruleRef, $partRef);
            if ($result eq 'A') {
                $processing = 0;
                push(@accepted, $partRef);
                last;
            } elsif ($result eq 'R') {
                $processing = 0;
                last;
            } elsif ($result) {
                @currentWorkflow = @{$workflows{$result}};
                last;
            }
        }
    }
}

my $sum = 0;
foreach my $partRef (@accepted) {
    $sum += ($partRef->{'x'} + $partRef->{'s'} + $partRef->{'a'} + $partRef->{'m'});
}
say $sum;

sub processRule($ruleRef, $partRef) {
    if ($ruleRef->{'test'} eq '>') {
        if ($partRef->{$ruleRef->{'prop'}} > $ruleRef->{'value'}) {
            return $ruleRef->{'target'};
        }
    } else {
        if ($partRef->{$ruleRef->{'prop'}} < $ruleRef->{'value'}) {
            return $ruleRef->{'target'};
        }
    }
    return 0;
}

sub parseRule($rule) {
    if ($rule =~ /\:/) {
        my @r1 = split(/\:/, $rule);
        if ($r1[0] =~ /\>/) {
            my @r2 = split(/\>/, $r1[0]);
            return { 'prop' => $r2[0], 'test' => '>', 'value' => $r2[1], 'target' => $r1[1] };
        } else {
            my @r2 = split(/\</, $r1[0]);
            return { 'prop' => $r2[0], 'test' => '<', 'value' => $r2[1], 'target' => $r1[1] };
        }
    } else {
        return { 'prop' => 'x', 'test' => '>', 'value' => 0, 'target' => $rule };
    }
}
