#!/bin/bash

## you can run this and install go as needed
echo "getting go version"
version=$(curl -s https://go.dev/dl/ | grep -E -o "go[0-9]+\.[0-9]+\.[0-9]+\.linux-amd64\.tar\.gz" | head -n 1)
echo "installing version ${version}"
curl -L "https://go.dev/dl/${version}" | tar -C /tmp -xz
sudo mv /tmp/go /usr/local/
echo 'export PATH=$PATH:/usr/local/go/bin' | sudo tee -a /etc/profile
