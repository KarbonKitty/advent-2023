#!/usr/bin/perl
use warnings;
use 5.036;

chomp(my @lines = <>);

my @w;
foreach my $line (@lines) {
    if ($line eq '') {
        last;
    } else {
        push(@w, $line);
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

my @accepted;

my @ranges = ({
    'startx' => 1,
    'endx' => 4000,
    'startm' => 1,
    'endm' => 4000,
    'starta' => 1,
    'enda' => 4000,
    'starts' => 1,
    'ends' => 4000,
    'workflow' => 'in',
    'rule' => 0
});

while (@ranges) {
    my $rangeRef = shift @ranges;

    if ($rangeRef->{'workflow'} eq 'A') {
        push(@accepted, $rangeRef);
        next;
    } elsif ($rangeRef->{'workflow'} eq 'R') {
        next;
    }

    # say $rangeRef->{'workflow'};
    my @currentWorkflow = @{$workflows{$rangeRef->{'workflow'}}};

    for my $i ($rangeRef->{'rule'}..$#currentWorkflow) {
        my %rule = %{$currentWorkflow[$i]};

        $rangeRef->{'rule'} = $i + 1;

        if ($rule{'test'} eq 'X') {
            if ($rule{'target'} eq 'A') {
                push(@accepted, $rangeRef);
                last;
            } elsif ($rule{'target'} eq 'R') {
                last;
            } else {
                $rangeRef->{'workflow'} = $rule{'target'};
                $rangeRef->{'rule'} = 0;
                push(@ranges, $rangeRef);
                last;
            }
        } elsif ($rule{'test'} eq '>') {
            if ($rangeRef->{'start' . $rule{'prop'}} > $rule{'value'}) {
                # entire range qualifies
                $rangeRef->{'workflow'} = $rule{'target'};
                $rangeRef->{'rule'} = 0;
                push(@ranges, $rangeRef);
                last;
            } elsif ($rangeRef->{'end' . $rule{'prop'}} < $rule{'value'}) {
                # entire range does not qualify
                next;
            } else {
                # split range
                my $lowerRangeEnd = $rule{'value'};
                my $lowerRangeProp = 'end' . $rule{'prop'};
                my $upperRangeStart = $lowerRangeEnd + 1;
                my $upperRangeProp = 'start' . $rule{'prop'};
                my $lowerRangeRef = &cloneHash($rangeRef);
                $lowerRangeRef->{$lowerRangeProp} = $lowerRangeEnd;
                push(@ranges, $lowerRangeRef);
                my $upperRangeRef = &cloneHash($rangeRef);
                $upperRangeRef->{$upperRangeProp} = $upperRangeStart;
                $upperRangeRef->{'workflow'} = $rule{'target'};
                $upperRangeRef->{'rule'} = 0;
                push(@ranges, $upperRangeRef);
                last;
            }
        } elsif ($rule{'test'} eq '<') {
            if ($rangeRef->{'end' . $rule{'prop'}} < $rule{'value'}) {
                #entire range qualifies
                $rangeRef->{'workflow'} = $rule{'target'};
                $rangeRef->{'rule'} = 0;
                push(@ranges, $rangeRef);
                last;
            } elsif ($rangeRef->{'start' . $rule{'prop'}} > $rule{'value'}) {
                # entire range does not qualify
                next;
            } else {
                # split range
                my $lowerRangeEnd = $rule{'value'} - 1;
                my $lowerRangeProp = 'end' . $rule{'prop'};
                my $upperRangeStart = $lowerRangeEnd + 1;
                my $upperRangeProp = 'start' . $rule{'prop'};
                my $lowerRangeRef = &cloneHash($rangeRef);
                $lowerRangeRef->{$lowerRangeProp} = $lowerRangeEnd;
                $lowerRangeRef->{'workflow'} = $rule{'target'};
                $lowerRangeRef->{'rule'} = 0;
                push(@ranges, $lowerRangeRef);
                my $upperRangeRef = &cloneHash($rangeRef);
                $upperRangeRef->{$upperRangeProp} = $upperRangeStart;
                push(@ranges, $upperRangeRef);
                last;
            }
        }
    }
}

my $sum = 0;
foreach my $ac (@accepted) {
    say "x: ($ac->{'startx'}, $ac->{'endx'}) " . "m: ($ac->{'startm'}, $ac->{'endm'}) " . "a: ($ac->{'starta'}, $ac->{'enda'}) " . "s: ($ac->{'starts'}, $ac->{'ends'})";

    my $x = $ac->{'endx'} - $ac->{'startx'} + 1;
    my $m = $ac->{'endm'} - $ac->{'startm'} + 1;
    my $a = $ac->{'enda'} - $ac->{'starta'} + 1;
    my $s = $ac->{'ends'} - $ac->{'starts'} + 1;

    $sum += ($x * $m * $a * $s);
}

say $sum;

sub cloneHash($hashRef) {
    my %newHash;
    foreach my $key (keys %{$hashRef}) {
        $newHash{$key} = $hashRef->{$key};
    }
    return \%newHash;
}

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
        return { 'prop' => '-', 'test' => 'X', 'value' => 0, 'target' => $rule };
    }
}
