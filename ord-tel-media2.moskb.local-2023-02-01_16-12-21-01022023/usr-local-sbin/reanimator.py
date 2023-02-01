#!/usr/bin/python -u
# -*- coding: utf-8 -*-
import cgi
#from BaseHTTPServer import BaseHTTPRequestHandler, HTTPServer
import subprocess
import sys
import os
import re
import syslog
from socket import *

#LISTEN_PORT = 8088
HOST = '127.0.0.1'
PORT = 5038
USER = 'reanimatolog'
PASS = 'fcnthbcr'
#surgery = os.system("/usr/sbin/asterisk -rx 'core show calls'")

def Care():
    try:
	# Login to AMI
	ast = socket(AF_INET, SOCK_STREAM)
	#  ast.settimeout(1)
	ast.connect((HOST, PORT))
    except error, E:
	#surgery = os.popen("/usr/sbin/asterisk -rx 'core show calls'")
	#surgery = os.system("/etc/int.d/asterisk restart")
	diagnosis = surgery.read()
        retstr = "ERROR AMI: %s, RESTARTING ASTERISK" % (str(E))
        print retstr
        return retstr
        sys.exit(0)

    data = ""
    while "\r\n" not in data:
        data += ast.recv(1024)

    params = ["Action: login",
          "Events: off",
          "Username: %s" % USER,
          "Secret: %s" % PASS]

    ast.send("\r\n".join(params) + "\r\n\r\n")
    # receive login response
    data = ""
    i = 0
    while "\r\n\r\n" not in data:
	data += ast.recv(1024)

    #теперь выполняем репорт
    data = ""
    cmd = 'sip show peers'
    brk = 'sip peers [Monitored:'
    params = ["Action: Command",
          "ActionID: 001",
          "Command: %s" % cmd]


    ast.send("\r\n".join(params) + "\r\n\r\n")
# receive answer
    i = 0
    while brk not in data:
	data += ast.recv(1024)
	i += 1
	if i > 999:
    	    break
    siprep = []
    siprep = data.split("\n")
    #print siprep
    reportmatch = [st for st in siprep if "sip peers" in st]
    #reportmatch = [st for st in siprep if "[Monitored: " in st]
    #peerstat = ((reportmatch[0]).split("[")[1]).split(",")[0]
    #print reportmatch
    #print "\n\n\n"
    #peerstat = int(re.findall('\d+', ((reportmatch[0]).split("[")[1]).split(",")[0])[0])
    peerstat = int(re.findall('\d+', reportmatch[0])[1])
    #print peerstat
    ast.send("Action: Logoff\r\n\r\n")
    ast.close()
    if peerstat < 10:
	#surgery = os.system("/usr/sbin/asterisk -rx 'core show calls'")
	#surgery = os.system("/etc/int.d/asterisk restart")
	retstr = "ERROR ASTERISK SIP LOW ONLINE: RESTARTING ASTERISK"
    else:
        retstr = peerstat
    print retstr
    return retstr
    sys.exit(0)
    
Care()


