#!/bin/bash

#    Copyright (C) 2016 cacahuatl < cacahuatl at autistici dot org >
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.

# NOTES/README
# Installs Riot.im into ~/Persistent/Riot under Tails
# Manually verifies the Releases file and uses that as a base of trust
# for all subsequent files as a best effort at installing without root
# N.B. all files are contained within ~/Persistent/Riot along with the
# keys and other data under ~/Persistent/Riot/.config/Riot which
# constitute your long term identity

LIBCBIT=`getconf LONG_BIT`
if [[ ${LIBCBIT} -eq 32 ]];then
	ARCH="i386"
elif [[ ${LIBCBIT} -eq 64 ]];then
	ARCH="amd64"
else
	echo "Arch is: $LIBCBIT -- WTF?"
	exit 1
fi
CODENAME=`lsb_release -c|awk '{print $2}'`
echo "[*] We are running ${CODENAME} on ${ARCH}"
TEMPDIR=`mktemp -d`
cd ${TEMPDIR}
echo -en "[ ] Fetching Release file and signature...\r"
wget https://riot.im/packages/debian/dists/${CODENAME}/Release{,.gpg} &> install.log
if [[ $? -ne 0 ]]; then
    echo "[-] Fetching Release file and signature...Failed"
    exit 2
else
    echo "[+] Fetching Release file and signature...Done"
fi
echo -en "[ ] Fetching signing key...\r"
gpg --recv-key 0xE019645248E8F4A1 &>> install.log
if [[ $? -ne 0 ]]; then
    echo "[-] Fetching signing key...Failed"
    exit 3
else
    echo "[+] Fetching signing key...Done"
fi
echo -en "[ ] Verifying Release signature...\r"
gpg --verify Release.gpg Release &>> install.log
if [[ $? -ne 0 ]]; then
	echo "[-] Verifying Release signature...Failed"
	exit 4
else
	echo "[+] Verifying Release signature...Done"
fi
echo -en "[ ] Fetching Packages file...\r"
wget https://riot.im/packages/debian/dists/${CODENAME}/main/binary-${ARCH}/Packages &>> install.log
if [[ $? -ne 0 ]]; then
	echo "[-] Fetching Packages file...Failed"
	exit 5
else
	echo "[+] Fetching Packages file...Done"
fi
echo -en "[ ] Verifying Packages file...\r"
grep "^ `sha256sum Packages | awk '{print $1}'` `wc -c Packages | awk '{print $1}'` main/binary-${ARCH}/Packages$" Release &>> install.log
if [[ $? -ne 0 ]]; then
	echo "[-] Verifying Packages file...Failed"
	exit 6
else
	echo "[+] Verifying Packages file...Done"
fi
DEBFILE=`grep -m1 "^Filename:" Packages | sed 's/^Filename:\s*//'`
FILENAME=`basename ${DEBFILE}`
echo -en "[ ] Fetching ${FILENAME} file...\r"
wget https://riot.im/packages/debian/${DEBFILE} &>> install.log
if [[ $? -ne 0 ]]; then
	echo "[-] Fetching ${FILENAME}...Failed"
	exit 7
else
	echo "[+] Fetching ${FILENAME}...Done"
fi
echo -en "[ ] Verifying ${FILENAME}...\r"
grep "^SHA256: `sha256sum ${FILENAME} | awk '{print $1}'`$" Packages &>> install.log
if [[ $? -ne 0 ]]; then
	echo "[-] Verifying ${FILENAME}...Failed"
	exit 8
else
	echo "[+] Verifying ${FILENAME}...Done"
fi
echo -en "[ ] Extracting Riot...\r"
7z x $FILENAME &>> install.log
if [[ $? -ne 0 ]]; then
	echo "[-] Extracting Riot...Failed"
	exit 9
fi
tar xf data.tar &>> install.log
if [[ $? -ne 0 ]]; then
        echo "[-] Extracting Riot...Failed"
	exit 10
fi
DEST="/home/amnesia/Persistent"
cp -r opt/Riot ${DEST} &>> install.log
if [[ $? -ne 0 ]]; then
        echo "[-] Extracting Riot...Failed"
	exit 10
fi
cp usr/share/icons/hicolor/48x48/apps/riot-web.png ${DEST}/Riot/ &>> install.log
if [[ $? -ne 0 ]]; then
        echo "[-] Extracting Riot...Failed"
	exit 10
fi
cat << EOF > ${DEST}/Riot/riot-web.desktop
[Desktop Entry]
Name=Start a Riot
Comment=A feature-rich client for Matrix.org
Exec=env HOME=${DEST}/Riot ${DEST}/Riot/riot-web --proxy-server="socks5://127.0.0.1:9050" --host-resolver-rules="MAP * 0.0.0.0 , EXCLUDE myproxy"
Terminal=false
Type=Application
Icon=${DEST}/Riot/riot-web.png
StartupWMClass=riot-web
EOF
chmod +x ${DEST}/Riot/riot-web.desktop
cp install.log ${DEST}/Riot/
rm -rf ${TEMPDIR}
echo "[+] Extracting Riot...Done"
echo "[+] Browse to \"${DEST}/Riot\" in File Manager and double click \"Start a Riot\" to run"
