#!/usr/bin/perl

use strict;
use warnings;
#use Data::Dumper;
use DBI;

my $NFSDir ="/var/spool/asterisk/monitor_tel_rec";
my $dsn = "DBI:Pg:dbname = record;host = 10.181.169.54;port = 5432";
my $dbh = DBI->connect($dsn, "postgres", "", { RaiseError => 1 })
      or die $DBI::errstr;

my ($f) = $ARGV[0];

# 20210927_114742-89112634548-out-8123313568-254-78123313568-CELL_INTEGRA_MEDIA_03_1632732462.366.wav

#my $mtime = (stat($f))[9];           # время последней модификации файла
my $size = (stat("$f.mp3"))[7];             # размер файла
if ( !$size || $size < 1000 ) {
#    print "file too small $size\n";
    system "rm $f* ";
    exit;
}

#print "size = $size\n";

my $s = "$f";
$s =~ s/.+\///;
#print "$s\n";
my ($dt, $extern, $dir, $intern, $ext, $bind, $uniq) = split(/-/, $s);
#$uniq =~ s/\.wav$//;
#$uniq =~ s/\.mp3$//;

my $stmt = qq(  BEGIN TRANSACTION;
                INSERT INTO tree (bind) values ('$bind') ON CONFLICT DO NOTHING;
                INSERT INTO record values ( '$dt', '$bind', '$uniq', '$extern', '$intern', '$ext', '$dir' ) ON CONFLICT DO NOTHING;
            );

my $sth = eval{$dbh->prepare( $stmt )};
my $rv = eval{$sth->execute()};
if($rv < 0 or $@) {
        print $DBI::errstr, "\n";
        $sth = $dbh->prepare( "ROLLBACK" );
        $sth->execute();
        return 1;
}

my $year = substr("$dt",0,4);
my $mon = substr("$dt",4,2);
my $day = substr("$dt",6,2);

my $dstdir = "/var/spool/asterisk/monitor_tel_rec/$bind/$year/$mon/$day/";


#this block checks the  NFS mount
my @output = `findmnt -T $NFSDir`;
my $result = $output[1];
my $position = index($result," ");
my $MountDir = substr($result,0,$position);
print "MountDir - $MountDir NFSDir -  $NFSDir \n";

if ($MountDir eq $NFSDir) {
        if (! -d "$dstdir"){
            #print "create $dstdir";
            system "mkdir -p $dstdir";
        }

        if (system "cp $f.mp3 $dstdir$s.mp3") {
            $sth = $dbh->prepare( "ROLLBACK" );
        } else {
            $sth = $dbh->prepare( "COMMIT TRANSACTION" );
            system "rm $f* ";
        }
        $sth->execute();
} else {

        $sth = $dbh->prepare( "ROLLBACK" );
        $sth->execute();
}

#eof
