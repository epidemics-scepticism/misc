#!/usr/bin/env python2
# this code is `strings` in 130bytes (<1 tweet), excluding comments
import sys,string
b=''
for a in open(sys.argv[1]).read():
 if a in string.printable[:-4]:b+=a
 else:
  if len(b)>3:print b
  b=''
