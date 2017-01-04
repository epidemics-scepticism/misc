#!/usr/bin/env python3
from hashlib import md5
import hmac
from os import fdopen
from sys import stdin,stdout
import binascii
class md5lol():
	def __init__(self, p = None, i = stdin, o = stdout):
		self.i = fdopen(i.fileno(), "rb")
		self.o = fdopen(o.fileno(), "wb")
		self.p = p
		self.ctr = 0
		self.km = b''
		if p == None:
			raise Exception('No password')
		k = self.hkdf(32, p.encode('utf-8'))
		self.ek = k[0:16]
		self.ak = k[16:32]

	def key_stream(self, size = 0):
		while size > len(self.km):
			self.km += self.key_stream_next()
		ret = self.km[:size]
		self.km = self.km[size:]
		return ret

	def key_stream_next(self):
		bctr = binascii.a2b_hex("%016x" % self.ctr)
		if self.ctr == 0xffffffffffffffff:
			raise Exception('I dont gracefully handle ctr wraparound')
		self.ctr += 1
		return self.hmac(self.ek, bctr)

	def hkdf(self, l = 32, ik = b''):
		dk = self.hmac(b'', ik)
		carry = b''
		out = b''
		x = 0
		while len(out) < l:
			carry = self.hmac(dk, carry + bytes([x+1]))
			x += 1
			out += carry
		return out[:l]

	def hmac(self, k = b'', p = b''):
		return hmac.new(key = k, msg = p, digestmod = md5).digest()

	def hmac_verify(self, m = b'', p = b'', k = b''):
		return hmac.compare_digest(m, hmac.new(key = k, msg = p, digestmod = md5).digest())

	def encrypt(self):
		p = self.i.read()
		k = self.key_stream(len(p))
		c = b''
		for a,b in zip(p,k):
			c += bytes([a ^ b])
		c = self.hmac(self.ak, c) + c
		self.o.write(c)

	def decrypt(self):
		c = self.i.read()
		if self.hmac_verify(m = c[:16], p = c[16:], k = self.ak) != True:
			raise Exception('Invalid message')
		c = c[16:]
		k = self.key_stream(len(c))
		p = b''
		for a,b in zip(c,k):
			p += bytes([a ^ b])
		self.o.write(p)

if __name__ == '__main__':
	import argparse
	parser = argparse.ArgumentParser()
	parser.add_argument("-m", "--mode", help="encrypt or decrypt", choices=['encrypt','decrypt'])
	parser.add_argument("-p", "--password", help="password", default="yolo")
	args = parser.parse_args()
	ml=md5lol(p = args.password)
	if args.mode == "encrypt":
		ml.encrypt()
	elif args.mode == "decrypt":
		ml.decrypt()
