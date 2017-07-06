#!/usr/bin/env bash
echo -en "[*] Setting password...\n"
passwd
if [[ $? -ne 0 ]]; then
	echo -en "[-] Failed.\n"
	exit 1
fi
echo -en "[+] Password set.\n"
echo -en "[*] Enabling screenlock...\n"
dconf write /org/gnome/desktop/screensaver/lock-enabled true
if [[ $? -ne 0 ]]; then
	echo -en "[-] Failed.\n"
	exit 1
fi
echo -en "[+] Screenlock enabled:\n\t- Automatically on screen blank (5 min inactivity).\n\t- Manually by pressing the Meta+L key combination.\n"
