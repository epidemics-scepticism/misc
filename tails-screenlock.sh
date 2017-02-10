#!/usr/bin/env bash
echo "###"
echo "Step 1. Set a password for the amnesia user"
echo "###"
ret=1
while [[ $ret -ne 0 ]]; do
	passwd
	ret=$?
done
dconf write "/org/gnome/desktop/lockdown/disable-lock-screen" "false"
echo "###"
echo "Step 2. Lock screen with Meta + L, from the power menu or enable autolock from"
echo "the Privacy menu under Settings."
echo "###"
