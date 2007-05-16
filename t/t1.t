#!/usr/bin/env perl -w

use strict;
use Test;
BEGIN { plan tests => 1 }

use Win32::Uptime;

my $x = Win32::Uptime::uptime();

ok(1);

exit;
