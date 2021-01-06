#!/usr/bin/perl

use strict;
use warnings;

my %opcode = (
    nop => 0,
    copy => 1,
    add => 2,
    sub => 3,
    xor => 4,
    and => 5,
    or => 6,
    not => 7,
    jmp => 8,
    jz => 9,
    out => 10,
    in => 11,
);

my %nargs = (
    nop => 0,
    copy => 2,
    add => 2,
    sub => 2,
    xor => 2,
    and => 2,
    or => 2,
    not => 1,
    jmp => 1,
    jz => 2,
    out => 2,
    in => 2,
);

my %labels;

my @prog;

while (<>) {
    s/^\s+//; s/\s+$//; # strip leading/trailing whitespace

    s/[#;].*//; # strip comments

    if (s/^([a-zA-Z_][a-zA-Z_0-9]+):\s*//) {
        my $label = $1;
        die "duplicate label: $label\n" if $labels{$label};
        $labels{$label} = @prog;
    }

    s/^\s+//; s/\s+$//; # strip leading/trailing whitespace
    next if $_ eq '';
    my ($op, @args) = split /\s+/;

    die "incorrect number of args for $op (expected $nargs{$op}, got " . scalar(@args) . ")\n" if defined $opcode{$op} && $nargs{$op} != @args;

    push @prog, $opcode{$op}||$op, @args;
}

for my $i (0 .. $#prog) {
    if ($prog[$i] =~ /^0x[0-9a-f]+$/i) {
        $prog[$i] = hex($prog[$i]);
    }
    if ($prog[$i] !~ /^\d+$/) {
        my $l = $prog[$i];
        my $add = 0;
        if ($l =~ s/\+(\d+)$//) {
            $add = $1;
        }
        die "unrecognised label: $l\n" if !exists $labels{$l};
        $prog[$i] = $labels{$l}+$add;
    }
}

print chr($_) for @prog;
