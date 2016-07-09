#!/usr/bin/env python2
# this code is `strings` in 135bytes (<1 tweet), excluding comments
import sys,string as s
p=s.printable[:-4]
b=''
for a in open(sys.argv[1]).read():
 if a in p:b+=a;continue;
 if len(b)>3:print(b);b=''
