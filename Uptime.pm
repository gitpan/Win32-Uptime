# Win32/Uptime.pm
#
# Copyright (c) 2007 Serguei Trouchelle. All rights reserved.
#
# This program is free software; you can redistribute it and/or modify it
# under the same terms as Perl itself.

# History:
#  1.01  2007/05/16 Initial revision

=head1 NAME

Win32::Uptime - Calculate uptime for Win32 systems

=head1 SYNOPSIS

 use Win32::Uptime;
 print Win32::Uptime::uptime(); # in milliseconds

=head1 DESCRIPTION

Win32::Uptime

=head1 METHODS

=head2 uptime

This method retrieves the number of milliseconds that have elapsed since the
system was started.

If uptime is more than notorious 49.7 days, and you have pagefile in your
system, it will be calculated correctly. If not, you lose.

Takes no parameters.

=head1 AUTHORS

Serguei Trouchelle E<lt>F<stro@railways.dp.ua>E<gt>

=head1 COPYRIGHT

Copyright (c) 2007 Serguei Trouchelle. All rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

package Win32::Uptime;

require Exporter;
use Config;

use strict;
use warnings;

our @EXPORT    = qw/ /;
our @EXPORT_OK = qw/ /;
our %EXPORT_TAGS = ();
our @ISA = qw/Exporter/;

$Win32::Uptime::VERSION = "1.01";
our $INT_VALUE = 4294967296; # GetTickCount uses this value

our $Registry;

use Win32::API;
use Win32::TieRegistry 0.20 (
  'TiedRef' => \$Registry,
  'Delimiter' => "/",
  'ArrayValues' => 1,
  'SplitMultis' => 1,
  'AllowLoad' => 1,
  qw( REG_SZ REG_EXPAND_SZ REG_DWORD REG_BINARY REG_MULTI_SZ
      KEY_READ KEY_ALL_ACCESS ),
);

sub uptime {
  my $GetTickCount;

  # Check GetTickCount64 (Vista/Longhorn), if your machine have it.
  # I didn't test it because I have no Vista, so let me know if something go wrong.

  $GetTickCount = Win32::API->new("kernel32", "int GetTickCount64()");

  my $swap;

  unless ($GetTickCount) {
    # Not a Vista, will use old GetTickCount 
    $GetTickCount = Win32::API->new("kernel32", "int GetTickCount()");
    # And check swap file to see maybe uptime is more than 49 day
    $swap = $Registry->{"LMachine/SYSTEM/CurrentControlSet/Control/Session Manager/Memory Management/PagingFiles"};
    if ($swap->[0]->[0] =~ /^(.*?)\s+\d+\s+\d+$/) {
      # If there's many files, first of them would be ok.
      $swap = $1;
      my (undef, undef, undef, undef, undef, undef, undef, undef, $atime,
          undef, undef, undef, undef) = stat($swap);
      $swap = time - $atime;
    } else {
      $swap = 0;
    }
  }

  # How many "49 day" intervals passed since pagefile creation?
  #
  # Also, pagefile is created AFTER GetTickCount's zero, so it will be
  # 0.9something if uptime is less than 49 days. 

  my $q = int 1000 * $swap / $INT_VALUE; 

  my $ticks = $GetTickCount->Call();

  # Adjust to stave off 49 day reset
  $ticks += $q * $INT_VALUE if $q;

  # "if $q" is here because benchmarking says it's 3 times faster with "if"
  # when $q = 0, and only 20% slower when $q > 0. Perl seems to multiply it
  # anyway without optimization.

  return $ticks;
}

1;