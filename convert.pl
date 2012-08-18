#!/usr/bin/perl -w

use Data::Dumper;
use HTML::Entities;
use DateTime;
use strict;

my $infile = shift(@ARGV);
my ($year, $month, $day) = $infile =~ m/(\d\d\d\d).(\d\d).(\d\d)/;
open (INFILE,$infile) || die($!);

LINE: while (my $in = <INFILE>) {

  my $line = HTML::Entities::decode($in);

  my ($hour, $minute, $class, $nick, $message) = $line =~
    m/<.*=\"irc-date\">\[(\d+):(\d+)\]<\/.*>\s*<.*=\"(.*)\">(\S*)\s+(.*)<\/.*>.*/;

  my $dt = DateTime->new(
    year => $year,
    month => $month,
    day => $day,
    hour => $hour,
    minute => $minute,
    time_zone => 'CET'
  );

  $dt->set_time_zone("America/Los_Angeles");

  if ($class eq 'irc-black') {
    print "$dt  $nick $message\n";
  }
  elsif ($class eq 'irc-green') {
    $message =~ s/\(.*\)\s+//;
    print "$dt  *** $message\n";
  }
  elsif ($class eq 'irc-navy') {
    if ($message =~ m/(\w+) \(\S+\) Quit.*/) {
      print "$dt  *** $1 has quit IRC\n";
    }
  }
  else {
    next LINE;
  }
}

