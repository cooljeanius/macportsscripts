#!/usr/bin/env perl
# taken from https://trac.macports.org/ticket/34482

use strict;
use warnings;

sub regfiles {

    my ($top,$regfile) = @_;

    my $fast = 1;

    my @regs;

    if ($fast) {
       push(@regs,"$top/local/var/macports/registry/$regfile");
    }

    # in case this bug ever comes up again and $regfile moves
    else {
       @regs = `find /opt -name '$regfile'`;
       return undef unless @regs;
       chomp @regs;
    }


    return \@regs;

}

my $sqlite3 = '/opt/local/bin/sqlite3';
die "Please do a 'port install sqlite3' and try again\n" if (! -x $sqlite3);

my $top     = '/opt';
my $regfile = 'registry.db';
my $regs    = regfiles($top,$regfile);
die "Unable to locate  $regfile in $top\n" if (! $regs);

my $cmd;

foreach my $dbfile (@$regs) {

    $cmd = "$sqlite3 $dbfile 'SELECT * FROM dependencies WHERE id NOT IN (SELECT DISTINCT id FROM ports);'";
    print $cmd, "\n";
    my @tofix = `$cmd`;

    if (! @tofix) {
       warn "Registry file $regfile format is correct...\n";
    }
    else {

       chomp @tofix;

       my $ids = {};
       foreach my $entry (@tofix) {
          my @parts = split /\|/, $entry;
          my $id    = shift @parts;
          $ids->{$id} = 1;
       }

       foreach my $id (sort keys %$ids) {

          $cmd = "$sqlite3 $dbfile 'DELETE FROM files WHERE id = $id'";
          print $cmd, "\n";
          system($cmd);

          $cmd = "$sqlite3 $dbfile 'DELETE FROM dependencies WHERE id = $id'";
          print $cmd, "\n";
          system($cmd);

       }

    }

}

my @inactive = `port list inactive`;
if (@inactive) {
   $cmd = 'port uninstall inactive';
   print $cmd, "\n";
   system($cmd);
}
