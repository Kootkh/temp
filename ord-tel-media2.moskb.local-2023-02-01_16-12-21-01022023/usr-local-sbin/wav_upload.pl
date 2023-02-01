#!/usr/bin/perl

use strict;
use warnings;
#use Data::Dumper;

my ($f) = @ARGV;
#my $dstdir = "/var/spool/asterisk/monitortest/";
my $dstdir = "/var/spool/asterisk/monitor_outgoing/";
#my $mtime = (stat($f))[9];           # время последней модификации файла
my $size = (stat($f))[7];             # размер файла
my $s = "$f";
$s =~ s/.+\///;
#$s =~ s/\.wav$//;
#print "$s\n";
my ($dt, $extern, $dir, $intern, $ext, $bind, $uniq) = split(/-/, $s);
my $dur = int( $size / 33400 );       #16700 mono; 33400 stereo
my $newname = '';
if ($dir eq 'out') {
    $newname = "$dt-$dur-$intern$ext-$extern-$uniq";
} else {
    $newname = "$dt-$dur-$extern-$intern$ext-$uniq";
}

#print "$f \n";
#print "$dstdir$newname\n";
system "cp $f $dstdir$newname";
