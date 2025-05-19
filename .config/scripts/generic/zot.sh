#!/usr/bin/bash

set -eo pipefail

while getopts "hru:p:" flag; do
	case $flag in
		h)
			echo "-r uninstall the zot cleaningup everything"
			echo "-u username for htpasswd"
			echo "-p password for htpasswd"
			exit 0
		;;
		r) 
			sudo systemctl disable --now zot.service
			sudo rm -rf /var/lib/zot /var/log/zot /etc/zot /usr/bin/zot /usr/lib/systemd/system/zot.service
			echo "zot registry removed"
			exit 0
		;;
		u) 
			USER=$OPTARG
		;;
		p) 
			PASSWD=$OPTARG
		;;
	esac
done


# check if username and password provided for registry
if [ -z "$USER" ] || [ -z "$PASSWD" ]; then
	echo "user and password required"
	exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${0}")" && pwd)"
OS=$(uname | awk '{print tolower($0)}')
ARCH=$(uname -m)
if [ "$ARCH" == "x86_64" ]; then
    ARCH="amd64"
fi

echo "downloading zot"
ZOT_VERSION=$(curl -sS https://api.github.com/repos/project-zot/zot/releases/latest | grep '"tag_name":' | awk '{gsub(/[",]/, "", $2); print $2}')
ZOT_URL="https://github.com/project-zot/zot/releases/download/${ZOT_VERSION}/zot-${OS}-${ARCH}"
curl -L -o /tmp/zot "$ZOT_URL"
sudo install -vDm755 /tmp/zot /usr/bin/zot
sudo install -vdm755 /var/lib/zot /var/log/zot
htpasswd -bnB "$USER" "$PASSWD" > /tmp/htpasswd
sudo install -vDm644 /tmp/htpasswd /etc/zot/htpasswd
sudo install -vDm644 "$SCRIPT_DIR"/config/zot/config.json /etc/zot/config.json
sudo install -vDm644 "$SCRIPT_DIR"/config/zot/zot.service /usr/lib/systemd/system/zot.service
sudo systemctl enable --now zot.service
rm -rf /tmp/htpasswd

echo "zot version ${ZOT_VERSION} is running on port 5235"
