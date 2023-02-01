#!/usr/bin/perl

use strict;
use warnings;
use Text::CSV;
#use Data::Dumper;
use DBI;
use Time::Local;

my $CONFIG_FILE = '/usr/local/sbin/cel-restore.conf';

my %CONFIG = (
    pg_host => undef,
    pg_user => undef,
    pg_password  => undef,
    pg_db  => undef,
    cdr_csv_file => undef,
);

die("Configuration file ".$CONFIG_FILE." not found!") unless -e $CONFIG_FILE;

open FH_CONFIG, '<', $CONFIG_FILE;
while(<FH_CONFIG>) {
    chomp;
    next if /^#/;
    next unless /^([^=]+)=([^#]+)$/;
    my ($param, $value) = (lc $1, $2);
    $param =~ s/(?:(?:^["'\s]+)|(?:['"\s]+)$)//g;
    $value =~ s/(?:(?:^["'\s]+)|(?:['"\s]+)$)//g;
    $CONFIG{$param} = $value;
}
close FH_CONFIG;

my $dsn = "DBI:Pg:dbname = $CONFIG{pg_db};host = $CONFIG{pg_host};port = 5432";
my $dbh = DBI->connect($dsn, $CONFIG{pg_user}, $CONFIG{pg_password}, { RaiseError => 1 })
   or die $DBI::errstr;
#print "sucsessful connect to database $CONFIG{pg_db}\n\n";

my $csv = Text::CSV->new({ sep_char => ',' });
my $i = 0;

my $file = $CONFIG{prev_cel_csv_file};
&loadcdr($file);
$file = $CONFIG{cel_csv_file};
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
		 $i++;
	    } else {
    		#print "Line could not be parsed: $line\n";
	    }
	}
    }
}

if ($i > 0 ) {
	print STDERR scalar(localtime)." WARNING! $i lines of cel restored. \n";
}
