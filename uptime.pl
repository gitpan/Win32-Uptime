#!/usr/env perl -w

use strict;
use Win32::Uptime;
use integer;

my $uptime = Win32::Uptime::uptime();
my $d   = $uptime / 86400000; # days
$uptime = $uptime % 86400000;
my $h   = $uptime / 3600000; # hours
$uptime = $uptime % 3600000;
my $m   = $uptime / 60000; # minutes
$uptime = $uptime % 60000;
my $s   = $uptime / 1000; # seconds

print 'Your system has been up for: ',
      $d, ' day(s), ',
      $h, ' hour(s), ',
      $m, ' minute(s), ',
      $s, " second(s)\n";
