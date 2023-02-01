#!/bin/bash

echo "`/bin/date +%d.%m.%Y-%H:%M:%S` starting cdr-custom, cel-custom rotate"  >> /var/log/cdr-custom.log

hname=`hostname`
#d=`date +%m-%d-%Y`
curtime=`date +%Y-%m-%d-%H-%M`
#echo "\n\n"
#echo $hname

cfname=$hname-$curtime-extended
echo $cfname

cp /var/log/asterisk/cdr-custom/Master.csv /var/log/asterisk/cdr-custom/Master_1.csv
cp /var/log/asterisk/cdr-custom/Master.csv /var/cdr-backup/$cfname.csv
echo -n > /var/log/asterisk/cdr-custom/Master.csv

cd /var/cdr-backup/
/bin/tar -czf $cfname.csv.tar.gz  $cfname.csv
rm /var/cdr-backup/$cfname.csv

cp /var/log/asterisk/cel-custom/Master.csv /var/log/asterisk/cel-custom/Master_1.csv
cp /var/log/asterisk/cel-custom/Master.csv /var/cel-backup/$cfname.csv
echo -n > /var/log/asterisk/cel-custom/Master.csv

cd /var/cel-backup/
/bin/tar -czf $cfname.csv.tar.gz  $cfname.csv
rm /var/cel-backup/$cfname.csv

echo "`/bin/date +%d.%m.%Y-%H:%M:%S` ending cdr-cel-custom rotate"  >> /var/log/cdr-custom.log