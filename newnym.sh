#!/usr/bin/env bash
#NEWNYM script for use with Tails in pure bash
exec 3<>/dev/tcp/127.0.0.1/9052;
if [[ $? -eq 0 ]]; then
	printf "AUTHENTICATE\r\nSIGNAL NEWNYM\r\nQUIT\r\n" >&3
fi
