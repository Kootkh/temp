#!/usr/bin/perl
#print "START  monitor_files_check.pl \n";
#Скрипт сравнивает директории записей текущего дня на tel-rec и локальную, фильтрует mp3. Если на локальном диске есть mp3 , то копирует на tel-rec
#проверяет записалось ли , если да , удаляет локальный файл .

use strict;
use warnings;
use Data::Dumper;
use Array::Utils qw(:all);
use Time::Piece;
use DateTime;

my $today = DateTime->now;
my $substring = ".mp3";
my $currentdate = $today->ymd('/');

my $d = "/var/spool/asterisk/monitor/ord/$currentdate"."/";
my $destd = "/var/spool/asterisk/monitor_tel_rec/ord/$currentdate"."/";

#print "data time + dir\n";
#print "$currentdate\n $d \n $destd\n";

opendir(D, "$d") || die "Can't open directory $d: $!\n";
my @localf = readdir(D);
closedir(D);

opendir(DF, "$destd") || die "Can't open directory $d: $!\n";
my @netf = readdir(DF);
closedir(DF);



my @minus = array_minus( @localf, @netf );

foreach my $lf (@minus) {
         if($lf =~/$substring/){                                 #check mp3
#            print "$lf\n";
#            print "cp -f $d$lf $destd$lf\n";
            system "cp -f $d$lf $destd$lf";
                if (-e "$destd$lf"){                      #check success copy
#                    print "$destd$lf exsist\n";
                    system "rm $d$lf";
                    }

        }
    }
