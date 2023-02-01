#!/usr/bin/perl
#print "START  mp3_upload \n";

use strict;
use warnings;
#use Data::Dumper;
#Set variable to default
my ($mfile) = $ARGV[0];
my $BIND = $ARGV[1];
my $RDNIS = $ARGV[2];
my $DID = $ARGV[3];
my $CID = $ARGV[4];
my $year = $ARGV[5];
my $month = $ARGV[6];
my $day = $ARGV[7];
my $targretfile = '';


my $f = $mfile.".mp3";

print "$f \n";

system "rm $mfile*.wav ";


#print "file - $f BIND - $BIND RDNIS - $RDNIS DID - $DID CID - $CID\n";


#print "BIND = $BIND\n";
#my $dstdir = "/var/spool/asterisk/monitortest/";
my $dstdir = "/var/spool/asterisk/monitor_tel_rec/$BIND/$year/$month/$day/";

if (! -d "$dstdir"){
#print "create $dstdir";
system "mkdir -p $dstdir";
}


#my $mtime = (stat($f))[9];           # время последней модификации файла
my $size = (stat($f))[7];             # размер файла
my $s = "$f";
$s =~ s/.+\///;
#$s =~ s/\.wav$//;
#print "$s\n";
my ($dt, $extern, $dir, $intern, $ext, $bind, $uniq) = split(/-/, $s);
#my $dur = int( $size / 33400 );       #16700 mono; 33400 stereo

#my $newname = '';
my $newname = "$dt-$extern-$dir-$intern-$ext-$bind-$uniq";

#print "$f \n";
#print "copy to $dstdir$newname\n";
system "cp $f $dstdir$newname";
#my $targetfile = "$dstdir$newname";
#print "$targetfile";

if (-e "$dstdir$newname"){
#print "$dstdir$newname exsist\n";
system "rm $mfile* ";


}