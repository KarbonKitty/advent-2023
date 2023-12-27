#!/usr/bin/perl
use warnings;
use 5.036;

chomp(my @lines = <>);

my @map = map { [ split(//, $_) ] } @lines;
my @energyMap = map { [ map { 0 } @{$_} ] } @map;
my %beamsStarted;

# say "@{$map[0]}";
# say "@{$energyMap[0]}";

# beam: { x, y, dir }
# right = 0001,
# down = 0010,
# left = 0100,
# up = 1000

my @beams = ( { 'x' => 0, 'y' => 0, 'dir' => 0b0001 } );

while (@beams) {
    my %beam = %{shift @beams};

    # say "New beam - x: $beam{'x'}, y: $beam{'y'}, dir: $beam{'dir'}";

    # foreach my $b (@beams) {
    #     say "x: %{$b}{'x'}, y: %{$b}{'y'}, dir: %{$b}{'dir'}";
    # }

    while (1) {
        my $nextTile = $map[$beam{'y'}][$beam{'x'}];

        last unless $beam{'y'} >= 0 && $beam{'x'} >= 0;
        last unless $nextTile;

        # say "x: $beam{'x'}, y: $beam{'y'}, dir: $beam{'dir'}, next tile: $nextTile";

        if ($nextTile eq '.') {
            $energyMap[$beam{'y'}][$beam{'x'}] = 1;
            (my $x, my $y) = &moveDir(\%beam);
            $beam{'x'} = $x;
            $beam{'y'} = $y;
        } elsif ($nextTile eq '/') {
            $energyMap[$beam{'y'}][$beam{'x'}] = 1;
            $beam{'dir'} = &mirrorDir($beam{'dir'}, '/');
            (my $x, my $y) = &moveDir(\%beam);
            $beam{'x'} = $x;
            $beam{'y'} = $y;
        } elsif ($nextTile eq '\\') {
            $energyMap[$beam{'y'}][$beam{'x'}] = 1;
            $beam{'dir'} = &mirrorDir($beam{'dir'}, '\\');
            (my $x, my $y) = &moveDir(\%beam);
            $beam{'x'} = $x;
            $beam{'y'} = $y;
        } elsif ($nextTile eq '|') {
            if ($beam{'dir'} == 0b0010 || $beam{'dir'} == 0b1000) {
                $energyMap[$beam{'y'}][$beam{'x'}] = 1;
                (my $x, my $y) = &moveDir(\%beam);
                $beam{'x'} = $x;
                $beam{'y'} = $y;
            } elsif ($beam{'dir'} == 0b0100 || $beam{'dir'} == 0b0001) {
                $energyMap[$beam{'y'}][$beam{'x'}] = 1;
                &tryStartBeam(\@beams, $beam{'x'}, $beam{'y'} - 1, 0b1000);
                # push(@beams, { 'x' => $beam{'x'}, 'y' => $beam{'y'} - 1, 'dir', => 0b1000 });
                &tryStartBeam(\@beams, $beam{'x'}, $beam{'y'} + 1, 0b0010);
                # push(@beams, { 'x' => $beam{'x'}, 'y' => $beam{'y'} + 1, 'dir' => 0b0010 });
                last;
            }
        } elsif ($nextTile eq '-') {
            if ($beam{'dir'} == 0b0010 || $beam{'dir'} == 0b1000) {
                $energyMap[$beam{'y'}][$beam{'x'}] = 1;
                &tryStartBeam(\@beams, $beam{'x'} + 1, $beam{'y'}, 0b0001);
                # push(@beams, { 'x' => $beam{'x'} - 1, 'y' => $beam{'y'}, 'dir', => 0b0001 });
                &tryStartBeam(\@beams, $beam{'x'} - 1, $beam{'y'}, 0b0100);
                # push(@beams, { 'x' => $beam{'x'} + 1, 'y' => $beam{'y'}, 'dir' => 0b0100 });
                last;
            } elsif ($beam{'dir'} == 0b0100 || $beam{'dir'} == 0b0001) {
                $energyMap[$beam{'y'}][$beam{'x'}] = 1;
                (my $x, my $y) = &moveDir(\%beam);
                $beam{'x'} = $x;
                $beam{'y'} = $y;
            }
        } else {
            die "Unknown tile: $nextTile";
        }
    }
}

my $sum = 0;
foreach my $lineRef (@energyMap) {
    # say "@{$lineRef}";
    foreach my $v (@{$lineRef}) {
        $sum += $v;
    }
}
say $sum;

sub tryStartBeam($beamsRef, $x, $y, $dir) {
    my $hash = $x . $y . $dir;
    unless ($beamsStarted{$hash}) {
        $beamsStarted{$hash} = 1;
        push(@{$beamsRef}, { 'x' => $x, 'y' => $y, 'dir' => $dir });
    }
}

sub moveDir($beamRef) {
    (my $x, my $y, my $dir) = (${$beamRef}{'x'}, ${$beamRef}{'y'}, ${$beamRef}{'dir'});
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

sub mirrorDir($dir, $mirror) {
    if ($mirror eq '/') {
        if ($dir == 0b0001) {
            return 0b1000;
        } elsif ($dir == 0b0010) {
            return 0b0100;
        } elsif ($dir == 0b0100) {
            return 0b0010;
        } elsif ($dir == 0b1000) {
            return 0b0001;
        } else {
            die "Unknown dir: $dir in mirror: $mirror";
        }
    } elsif ($mirror eq '\\') {
        if ($dir == 0b0001) {
            return 0b0010;
        } elsif ($dir == 0b0010) {
            return 0b0001;
        } elsif ($dir == 0b0100) {
            return 0b1000;
        } elsif ($dir == 0b1000) {
            return 0b0100;
        } else {
            die "Unknown dir: $dir in mirror: $mirror";
        }
    } else {
        die "Unknown mirror: $mirror";
    }
}

