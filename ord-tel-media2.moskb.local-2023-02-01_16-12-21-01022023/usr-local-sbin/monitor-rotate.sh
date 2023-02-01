#!/bin/sh
find /var/spool/asterisk/monitor -type f -mtime +3 -delete
#find /var/spool/asterisk/monitor -type f -mtime +3