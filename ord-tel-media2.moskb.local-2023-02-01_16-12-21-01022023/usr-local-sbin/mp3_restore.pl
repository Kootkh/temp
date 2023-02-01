#!/usr/bin/perl

use strict;
use warnings;
#use Data::Dumper;
use DBI;
use File::Find;

my $dsn = "DBI:Pg:dbname = record;host = 10.181.169.54;port = 5432";
my $dbh = DBI->connect($dsn, "postgres", "", { RaiseError => 1 })
      or die $DBI::errstr;

my $i = 0;

sub wanted {

    ! /\.mp3$/ && return;

    my $src = $File::Find::name;
    $src =~ s/\.mp3$//;
    my $s = $_;
    print "$src\n";
    my ($dt, $extern, $dir, $intern, $ext, $bind, $uniq) = split(/-/, $s);

    my $year = substr("$dt",0,4);
    my $mon = substr("$dt",4,2);
    my $day = substr("$dt",6,2);
    my $dstdir = "/var/spool/asterisk/monitor_tel_rec/$bind/$year/$mon/$day/";

#    if (-e "$dstdir$s") {
#        system "rm $src*";
#        print "file $src removed";
#        return;
#    }

    my $size = (stat("$src.mp3"))[7];             # размер файла
    if ( !$size || $size < 1000 ) {
        print "file too small $size\n";
        system "rm $src*";
        return;
    }

    $uniq =~ s/\.mp3$//;

    if (! -d "$dstdir"){
        print "create $dstdir\n";
        system "mkdir -p $dstdir";
    }

#    print "file $s is not exists!";

    my $stmt = qq(  BEGIN TRANSACTION;
                    INSERT INTO tree (bind) values ('$bind') ON CONFLICT DO NOTHING;
                    INSERT INTO record values ( '$dt', '$bind', '$uniq', '$extern', '$intern', '$ext', '$dir' ) ON CONFLICT DO NOTHING;
            );

    my $sth = $dbh->prepare( $stmt );
    my $rv = eval{$sth->execute()};
    if($rv < 0 or $@) {
        print STDERR $DBI::errstr, "\n";
        $sth = $dbh->prepare( "ROLLBACK" );
        $sth->execute();
        return 1;
    }

    print "$dstdir$s\n\n";
    if (system "cp $src.mp3 $dstdir$s") {
        $sth = $dbh->prepare( "ROLLBACK" );
    } else {
        $sth = $dbh->prepare( "COMMIT TRANSACTION" );
        system "rm $src*";
    }
    $sth->execute();
    $i++;
    return;

}

find ( \&wanted, '/var/spool/asterisk/monitor' );
if ($i > 0 ) {
    print STDERR scalar(localtime)." WARNING! $i monitor files restored.\n";
}

exit;
