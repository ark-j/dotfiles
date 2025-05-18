#!/bin/bash

set -o pipefail

echo "cleaning up leftover installs"
sudo systemctl disable --now containerd.service buildkit.service
sudo rm -rf \
  /var/lib/systemd/system/containerd.service \
  /var/lib/systemd/system/buildkit.service \
  /var/lib/systemd/system/buildkit.socket \
  /usr/lib/systemd/system/containerd.service \
  /usr/bin/crun \
  /usr/bin/runc \
  /usr/bin/containerd* \
  /usr/bin/ctr \
  /usr/bin/buildkit* \
  /usr/bin/nerdctl \
  /usr/bin/containerd-rootless-setuptool.sh \
  /usr/bin/install-buildkit-containerd \
  /etc/containerd \
  /etc/cni \
  /opt/cni \
  /var/lib/containerd \
  /var/lib/cni \
  /var/lib/nerdctl \
  /var/lib/buildkit
sudo ip link delete nerdctl0
rm -rf /tmp/cni-bin /tmp/nerdctl-bin

OS=$(uname | awk '{print tolower($0)}')
ARCH=$(uname -m)
runtime=${1:-"runc"}

if [ "$ARCH" == "x86_64" ]; then
    ARCH="amd64"
fi

if [ "$runtime" = "crun" ]; then
	# install crun
	echo "downloading crun"
	CRUN_VERSION=$(curl -sS https://api.github.com/repos/containers/crun/releases/latest | grep '"tag_name":' | awk '{gsub(/[",]/, "", $2); print $2}')
	CRUN_URL="https://github.com/containers/crun/releases/download/${CRUN_VERSION}/crun-${CRUN_VERSION}-${OS}-${ARCH}"
	curl -Lo /tmp/crun "$CRUN_URL"
	echo "------------------"
	sudo install -Dm755 /tmp/crun /usr/bin
	sudo install -Dm755 /tmp/crun /usr/bin/runc
	echo "installed crun version ${CRUN_VERSION}"
else
	# install runc
	echo "downloading runc"
	RUNC_VERSION=$(curl -sS https://api.github.com/repos/opencontainers/runc/releases/latest | grep '"tag_name":' | awk '{gsub(/[",]/, "", $2); print $2}')
	RUNC_URL="https://github.com/opencontainers/runc/releases/download/${RUNC_VERSION}/runc.${ARCH}"
	echo "------------------"
	curl -Lo /tmp/runc "$RUNC_URL"
	sudo install -Dm755 /tmp/runc /usr/bin
	echo "installed runc version ${RUNC_VERSION}"
fi

# install cni plugin
echo "downloading cni plugins"
CNI_VERSION=$(curl -sS https://api.github.com/repos/containernetworking/plugins/releases/latest | grep '"tag_name":' | awk '{gsub(/[",]/, "", $2); print $2}')
CNI_URL="https://github.com/containernetworking/plugins/releases/download/${CNI_VERSION}/cni-plugins-${OS}-${ARCH}-${CNI_VERSION}.tgz"
curl -Lo /tmp/cni.tgz "$CNI_URL"
echo "------------------"
mkdir /tmp/cni-bin
tar -xf /tmp/cni.tgz -C /tmp/cni-bin
sudo install -vDm755 /tmp/cni-bin/* -t /opt/cni/bin/
sudo install -vdm755 /etc/cni/net.d/
echo "installed cni-plugins version ${CNI_VERSION}"

# install containerd
echo "downloading containerd"
CONTAINERD_VERSION=$(curl -sS https://api.github.com/repos/containerd/containerd/releases/latest | grep '"tag_name":' | awk '{gsub(/[",]/, "", $2); print $2}')
CONTAINERD_URL="https://github.com/containerd/containerd/releases/download/${CONTAINERD_VERSION}/containerd-${CONTAINERD_VERSION#v}-${OS}-${ARCH}.tar.gz"
curl -Lo /tmp/containerd.tar.gz "$CONTAINERD_URL"
echo "------------------"
tar -xf /tmp/containerd.tar.gz -C /tmp
sudo install -Dm755 /tmp/bin/* /usr/bin
sudo install -Dm644 ./containers_configs/containerd.service /usr/lib/systemd/system/containerd.service
if [ "$runtime" == "crun" ]; then
	sudo install -Dm644 ./containers_configs/config_crun.toml /etc/containerd/config.toml
else 
	sudo install -Dm644 ./containers_configs/config_runc.toml /etc/containerd/config.toml
fi
echo "installed containerd version ${CONTAINERD_VERSION}"
sudo systemctl daemon-reload
sudo systemctl enable --now containerd.service

# install buildkit
echo "downloading buildkitd"
BUILDKIT_VERSION=$(curl -sS https://api.github.com/repos/moby/buildkit/releases/latest | grep '"tag_name":' | awk '{gsub(/[",]/, "", $2); print $2}')
BUILDKIT_URL="https://github.com/moby/buildkit/releases/download/${BUILDKIT_VERSION}/buildkit-${BUILDKIT_VERSION}.${OS}-${ARCH}.tar.gz"
curl -Lo /tmp/buildkit.tar.gz "$BUILDKIT_URL"
echo "------------------"
mkdir /tmp/buildkit-bin/
tar -xf /tmp/buildkit.tar.gz /tmp/buildkit-bin/
sudo install -Dm755 /tmp/buildkit-bin/bin/* /usr/bin/
sudo install -Dm644 ./containers_configs/buildkit.service /usr/lib/systemd/system/buildkit.service
sudo install -Dm644 ./containers_configs/buildkit.socket /usr/lib/systemd/system/buildkit.socket
if [ "$runtime" = "crun" ]; then
	sudo install -Dm644 ./containers_configs/buildkitd_crun.toml /etc/buildkit/buildkitd.toml
else 
	sudo install -Dm644 ./containers_configs/buildkitd_runc.toml /etc/buildkit/buildkitd.toml
echo "installed buildkitd version ${BUILDKIT_VERSION}"
sudo systemctl daemon-reload
sudo systemctl enable --now buildkit.service

# install nerdctl
echo "downloading nerdctl"
NERDCTL_VERSION=$(curl -sS https://api.github.com/repos/containerd/nerdctl/releases/latest | grep '"tag_name":' | awk '{gsub(/[",]/, "", $2); print $2}')
NERDCTL_URL="https://github.com/containerd/nerdctl/releases/download/${NERDCTL_VERSION}/nerdctl-${NERDCTL_VERSION#v}-${OS}-${ARCH}.tar.gz"
curl -Lo /tmp/nerdctl.tar.gz "$NERDCTL_URL"
echo "------------------"
mkdir /tmp/nerdctl-bin
tar -xf /tmp/nerdctl.tar.gz -C /tmp/nerdctl-bin
sudo install -Dm644 ./containers_configs/nerdctl.toml /etc/nerdctl/nerdctl.toml
sudo install -Dm755 /tmp/nerdctl-bin/* /usr/bin
echo "installed nerdctl version ${NERDCTL_VERSION}"

sudo rm -rf /tmp/cni.tgz /tmp/containerd.tar.gz /tmp/crun /tmp/nerdctl.tar.gz /tmp/bin /tmp/cni-bin /tmp/nerdctl-bin /tmp/buildkit-bin/ /tmp/buildkit.tar.gz
