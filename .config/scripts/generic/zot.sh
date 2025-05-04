#!/usr/bin/bash

set -eo pipefail

remove=$1

if [ -n "$remove" ] && [ "$remove" = "true" ]; then
	echo "removing zot registry"
	sudo systemctl disable --now zot.service
	sudo rm -rf /var/lib/zot /var/log/zot /etc/zot /usr/bin/zot /etc/systemd/system/zot.service
	exit 0
fi

echo "downloading zot"
curl -L -o zot https://github.com/project-zot/zot/releases/download/v2.1.2/zot-linux-amd64
sudo mv zot /usr/bin
sudo chmod +x /usr/bin/zot
sudo mkdir /etc/zot
sudo mkdir -p /var/lib/zot
sudo mkdir -p /var/log/zot

sudo chown root:root /usr/bin/zot
sudo chown root:root /etc/zot

sudo htpasswd -bnB jayesh hyperbeast | sudo tee /etc/zot/htpasswd > /dev/null
sudo tee /etc/zot/config.json > /dev/null << EOF
{
	"distSpecVersion": "1.1.0",
	"scheduler": {
		"numWorkers": 3
	},
	"storage": {
		"dedupe": true,
		"remoteCache": false,
		"rootDirectory": "/var/lib/zot",
		"gc": true
	},
	"http": {
		"address": "0.0.0.0",
		"port": "5000",
		"compat": [
			"docker2s2"
		],
		"realm": "zot",
		"auth": {
			"htpasswd": {
				"path": "/etc/zot/htpasswd"
			},
			"failDelay": 5
		}
	},
	"log": {
		"level": "info",
		"output": "/var/log/zot/zot.log",
		"audit": "/var/log/zot/zot-audit.log"
	},
	"extensions": {
		"search": {
			"enable": true,
			"cve": {
				"updateInterval": "6h"
			}
		},
		"ui": {
			"enable": true
		}
	}
}
EOF

# PUT this in exentions section if mirroring is desirable
# "sync": {
# 			"enable": true,
# 			"registries": [
# 				{
# 					"urls": [
# 						"https://docker.io/library"
# 					],
# 					"content": [
# 						{
# 							"prefix": "**",
# 							"destination": "/library"
# 						}
# 					],
# 					"onDemand": true,
# 					"tlsVerify": true
# 				}
# 			]
# 		}

sudo tee /etc/systemd/system/zot.service > /dev/null << EOF
[Unit]
Description=OCI Distribution Registry
Documentation=https://zotregistry.dev/
After=network.target auditd.service local-fs.target

[Service]
Type=simple
ExecStart=/usr/bin/zot serve /etc/zot/config.json
Restart=on-failure
User=root
Group=root
LimitNOFILE=500000
MemoryHigh=12G
MemoryMax=16G

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl start zot.service

sleep 10
sudo chmod 644 -R /var/log/zot/*
sudo chmod 644 -R /var/lib/zot/*
