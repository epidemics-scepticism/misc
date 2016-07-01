#!/usr/bin/env python2
# this code is strings in 139bytes (one tweet), excluding comment lines
# CODE STARTS
import sys,string as s
p=s.printable[:-4]
f=open(sys.argv[1]).read()
b=''
for a in f:
 if a in p:b+=a;continue
 if len(b)>3:print(b)
 b=''
# CODE ENDS
