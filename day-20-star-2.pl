#!/usr/bin/perl
use warnings;
use 5.036;

chomp(my @lines = <>);

my %modules;
my %conMemory;

foreach my $line (@lines) {
    my $m = &parseModule($line);
    $modules{$m->{'name'}} = $m;
}

my @cons = grep { $_->{'type'} eq '&' } (values %modules);
my @conNames = map { $_->{'name'} } @cons;
my @modsWithConOutputs;
foreach my $modRef (values %modules) {
    foreach my $output (@{$modRef->{'outputs'}}) {
        # say $output;
        my @x = grep { $_ eq $output } @conNames;
        foreach my $conName (@x) {
            $modules{$conName}{'state'}{$modRef->{'name'}} = 0;
            # say "input: $modRef->{'name'}, output: $conName";
        }
    }
}

# foreach my $m (values %modules) {
#     &printModule($m);
# }

###

# my %startingStates;

# my $lowPulses = 0;
# my $highPulses = 0;

# my $stateHash;
# foreach my $modName (sort keys %modules) {
#     $stateHash .= &hashModuleState($modules{$modName});
# }

my $count = 0;
while (1) {
    $count++;
    my $r = &processPulse(\%modules, $count);
    # say $r;
    if ($r == 1) {
        last;
    }
    # foreach my $modName (sort keys %modules) {
    #     $stateHash .= &hashModuleState($modules{$modName});
    # }

    # my $nextHash;
    # my $pulseCount;
    # if (defined $startingStates{$stateHash}) {
    #     $lowPulses += $startingStates{$stateHash}[0];
    #     $highPulses += $startingStates{$stateHash}[1];
    #     $stateHash = $startingStates{$stateHash}[2];
    #     next;
    # } else {
    #     $pulseCount = &processPulse(\%modules);
    #     $lowPulses += $pulseCount->[0];
    #     $highPulses += $pulseCount->[1];
    #     foreach my $modName (sort keys %modules) {
    #         $nextHash .= &hashModuleState($modules{$modName});
    #     }
    # }

    # # say "hash: $stateHash, low: $pulseCount->[0], high: $pulseCount->[1], next hash: $nextHash";

    # $startingStates{$stateHash} = [ $pulseCount->[0], $pulseCount->[1], $nextHash ];

    # $stateHash = $nextHash;
}

say $count;

# say "high: $highPulses, low: $lowPulses, product: " . $lowPulses * $highPulses;

###

sub parseModule($line) {
    (my $p1, my $outputs) = split(' -> ', $line);
    (my $type, my $name, my @outputs);
    if ($p1 eq 'broadcaster') {
        $type = 'broadcaster';
        $name = 'broadcaster';
    } else {
        $type = substr($p1, 0, 1);
        if ($type eq '%' || $type eq '&') {
            $name = substr($p1, 1);
        } else {
            $type = 'test';
            $name = $p1;
        }
    }

    @outputs = split(', ', $outputs);
    my %module = ( 'type' => $type, 'name' => $name, 'outputs' => \@outputs );

    if ($type eq '%') {
        $module{'state'} = 0;
    }

    if ($type eq '&') {
        $module{'state'} = {};
    }

    return \%module;
}

sub hashModuleState($modRef) {
    if ($modRef->{'type'} eq '%') {
        return $modRef->{'name'} . $modRef->{'state'};
    } elsif ($modRef->{'type'} eq '&') {
        my %s = %{$modRef->{'state'}};
        my $state;
        foreach my $k (sort keys %s) {
            $state .= "$k => $s{$k} ";
        }
        return $modRef->{'name'} . $state;
    } else {
        return '';
    }
}

sub processPulse($modulesRef, $count) {
    my @pulseQueue;
    my $rxLowPulseCount = 0;
    my $rxPulseCount = 0;
    # my $lowPulseCount = 0;
    # my $highPulseCount = 0;

    push(@pulseQueue, { 'origin' => 'button', 'module' => 'broadcaster', 'type' => 0 });

    while (@pulseQueue) {
        my $pulseRef = shift @pulseQueue;

        # say "origin: $pulseRef->{'origin'}, target: $pulseRef->{'module'}, type: $pulseRef->{'type'}";

        # if ($pulseRef->{'type'}) {
        #     $highPulseCount++;
        # } else {
        #     $lowPulseCount++;
        # }

        if ($pulseRef->{'module'} eq 'rx') {
            $rxPulseCount++;
            if ($pulseRef->{'type'} == 0) {
                $rxLowPulseCount++;
            }
        }

        # find module
        my $modRef = $modulesRef->{$pulseRef->{'module'}};

        # process module

        # ignore pulses sent to "output" modules
        next unless defined $modRef;

        if ($modRef->{'type'} eq 'broadcaster') {
            foreach my $out (@{$modRef->{'outputs'}}) {
                push(@pulseQueue, { 'origin' => $modRef->{'name'}, 'module' => $out, 'type' => 0 });
            }
        } elsif ($modRef->{'type'} eq '%') {
            if ($pulseRef->{'type'} == 0) {
                if ($modRef->{'state'} == 0) {
                    $modRef->{'state'} = 1;
                } else {
                    $modRef->{'state'} = 0;
                }
                foreach my $out (@{$modRef->{'outputs'}}) {
                    push(@pulseQueue, { 'origin' => $modRef->{'name'}, 'module' => $out, 'type' => $modRef->{'state'} });
                }
            }
        } elsif ($modRef->{'type'} eq '&') {
            # update memory
            $modRef->{'state'}{$pulseRef->{'origin'}} = $pulseRef->{'type'};
            # send pulse
            my @memory = values %{$modRef->{'state'}};
            my $signal = 0;
            if (grep { $_ == 0 } @memory) {
                $signal = 1;
            }
            if ($signal == 1 && ($modRef->{'name'} eq 'mk' || $modRef->{'name'} eq 'fp' || $modRef->{'name'} eq 'xt' || $modRef->{'name'} eq 'zc')) {
                say "name: $modRef->{'name'}, count: $count";
            }
            foreach my $out (@{$modRef->{'outputs'}}) {
                # &printModule($modRef);
                # say "signal: $signal";
                push(@pulseQueue, { 'origin' => $modRef->{'name'}, 'module' => $out, 'type' => $signal });
            }
        }
    }

    # return [$lowPulseCount, $highPulseCount];
    return $rxLowPulseCount;
}

sub printModule($modRef) {
    if ($modRef->{'type'} eq '%') {
        say "type: $modRef->{'type'}, name: $modRef->{'name'}, outputs: @{$modRef->{'outputs'}}, state: $modRef->{'state'}";
    } elsif ($modRef->{'type'} eq '&') {
        my %s = %{$modRef->{'state'}};
        my $state;
        foreach my $k (keys %s) {
            $state .= "$k => $s{$k} ";
        }
        say "type: $modRef->{'type'}, name: $modRef->{'name'}, outputs: @{$modRef->{'outputs'}}, state: " . "$state";
    } else {
        say "type: $modRef->{'type'}, name: $modRef->{'name'}, outputs: @{$modRef->{'outputs'}}";
    }
}
