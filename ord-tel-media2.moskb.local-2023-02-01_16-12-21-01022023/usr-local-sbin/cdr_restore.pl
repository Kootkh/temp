#!/usr/bin/perl

use strict;
use warnings;
use Text::CSV;
#use Data::Dumper;
use DBI;
use Time::Local;
use Config::Tiny;

my $CONFIG_FILE = '/etc/odbc.ini';
die("Configuration file ".$CONFIG_FILE." not found!") unless -e $CONFIG_FILE;
my $config = Config::Tiny->read( $CONFIG_FILE, 'utf8' );

my $dsn = "DBI:Pg:dbname = $config->{cdr}{Database};host = $config->{cdr}{Servername};port = $config->{cdr}{Port}";
my $dbh = DBI->connect($dsn, $config->{cdr}{UserName}, $config->{cdr}{Password}, { RaiseError => 1 })
   or die $DBI::errstr;
#   print "sucsessful connect to $dsn\n";

   my $csv = Text::CSV->new({ sep_char => ',' });
   my $i = 0;
   my %lid;

   my $file = '/var/log/asterisk/cel-custom/Master_1.csv';
   &loadcdr($file);
   $file = '/var/log/asterisk/cel-custom/Master.csv';
   &loadcdr($file);

sub loadcdr {
    my $file = shift;
    open(my $data, '<', $file) or return;
    while (my $line = <$data>) {
        chomp $line;
        if ($csv->parse($line)) {
            my @fields = $csv->fields();
            my $values = join(",", map{"'$_'"} @fields);
            #print Dumper(@fields);
            my $stmt = qq(INSERT INTO cel (eventtype, eventtime, userdeftype, cid_name, cid_num, cid_ani, cid_rdnis, cid_dnid, exten, context, channame, appname, appdata, amaflags, accountcode, peeraccount, uniqueid, linkedid, userfield, peer, pbxserver)
                VALUES ( $values ) ON CONFLICT DO NOTHING;);
            my $sth = $dbh->prepare( $stmt );
            my $rv = eval{$sth->execute()};
#            print "result = $rv \n";
            if($rv < 0 or $@) {
                print STDERR $DBI::errstr, "\n";
                next;
            }
            if ($rv == 1) {
                $lid{$fields[17]} = 1;
                $i++;
            } else {
                #print "Line could not be parsed: $line\n";
            }
        }
    }
}

my $k;
foreach $k (keys %lid) {
    my $stmt = "SELECT ncdr_restore('" . $k . "');";
    my $sth = $dbh->prepare( $stmt );
    my $rv = eval{$sth->execute()};
}


if ($i > 0 ) {
        print STDERR scalar(localtime)." WARNING! $i lines of cel restored. \n";
}
