#!/usr/bin/perl

use strict;
use warnings;
use pdldump;

use Carp;

$SIG{__WARN__} = sub {
    confess($_[0]);
};

$SIG{__DIE__} = sub {
    confess($_[0]);
};

use Shlomif::FCS::CalcMetaScan::CmdLine;

my $iface = Shlomif::FCS::CalcMetaScan::CmdLine->new();
$iface->run_flares();

