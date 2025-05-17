#!/bin/bash

set -xo pipefail

sudo systemctl disable --now containerd.service buildkit.service
sudo rm -rf /var/lib/systemd/system/containerd.service /var/lib/systemd/system/buildkit.service /var/lib/systemd/system/buildkit.socket
sudo rm -rf /usr/bin/crun /usr/bin/runc
sudo rm -rf /usr/bin/containerd* /usr/bin/ctr /usr/lib/systemd/system/containerd.service /etc/containerd
sudo rm -rf /etc/cni /opt/cni
sudo rm -rf /usr/bin/buildkit*
sudo rm -rf /usr/bin/nerdctl /usr/bin/containerd-rootless-setuptool.sh /usr/bin/install-buildkit-containerd
sudo ip link delete nerdctl0
rm -rf /tmp/cni-bin /tmp/nerdctl-bin

OS=$(uname | awk '{print tolower($0)}')
ARCH=$(uname -m)

if [ "$ARCH" == "x86_64" ]; then
    ARCH="amd64"
fi

# install crun
CRUN_VERSION=$(curl -sS https://api.github.com/repos/containers/crun/releases/latest | grep '"tag_name":' | awk '{gsub(/[",]/, "", $2); print $2}')
CRUN_URL="https://github.com/containers/crun/releases/download/${CRUN_VERSION}/crun-${CRUN_VERSION}-${OS}-${ARCH}"
curl -Lo /tmp/crun "$CRUN_URL"
sudo install -Dm755 /tmp/crun /usr/bin
sudo install -Dm755 /tmp/crun /usr/bin/runc

# install cni plugin
CNI_VERSION=$(curl -sS https://api.github.com/repos/containernetworking/plugins/releases/latest | grep '"tag_name":' | awk '{gsub(/[",]/, "", $2); print $2}')
CNI_URL="https://github.com/containernetworking/plugins/releases/download/${CNI_VERSION}/cni-plugins-${OS}-${ARCH}-${CNI_VERSION}.tgz"
curl -Lo /tmp/cni.tgz "$CNI_URL"
mkdir /tmp/cni-bin
tar -xf /tmp/cni.tgz -C /tmp/cni-bin
sudo install -vDm755 /tmp/cni-bin/* -t /opt/cni/bin/
sudo install -vdm755 /etc/cni/net.d/

# install containerd
CONTAINERD_VERSION=$(curl -sS https://api.github.com/repos/containerd/containerd/releases/latest | grep '"tag_name":' | awk '{gsub(/[",]/, "", $2); print $2}')
CONTAINERD_URL="https://github.com/containerd/containerd/releases/download/${CONTAINERD_VERSION}/containerd-${CONTAINERD_VERSION#v}-${OS}-${ARCH}.tar.gz"
curl -Lo /tmp/containerd.tar.gz "$CONTAINERD_URL"
tar -xf /tmp/containerd.tar.gz -C /tmp
sudo install -Dm755 /tmp/bin/* /usr/bin
sudo mkdir /etc/containerd 
sudo tee /usr/lib/systemd/system/containerd.service > /dev/null <<EOF
[Unit]
Description=containerd container runtime
Documentation=https://containerd.io
After=network.target dbus.service

[Service]
ExecStartPre=-/sbin/modprobe overlay
ExecStart=/usr/bin/containerd

Type=notify
Delegate=yes
KillMode=process
Restart=always
RestartSec=5

# Having non-zero Limit*s causes performance problems due to accounting overhead
# in the kernel. We recommend using cgroups to do container-local accounting.
LimitNPROC=infinity
LimitCORE=infinity

# Comment TasksMax if your systemd version does not supports it.
# Only systemd 226 and above support this version.
TasksMax=infinity
OOMScoreAdjust=-999

[Install]
WantedBy=multi-user.target
EOF

sudo tee /etc/containerd/config.toml > /dev/null <<EOF
version = 3
[plugins."io.containerd.cri.v1.runtime".containerd]
	default_runtime_name = "crun"
	[plugins."io.containerd.cri.v1.runtime".containerd.runtimes]
		[plugins."io.containerd.cri.v1.runtime".containerd.runtimes.crun]
			runtime_type = "io.containerd.runc.v2"
			[plugins."io.containerd.cri.v1.runtime".containerd.runtimes.crun.options]
				BinaryName = "/usr/bin/crun"
				SystemdCgroup = true
EOF
sudo systemctl daemon-reload
sudo systemctl enable --now containerd.service

# install buildkit
BUILDKIT_VERSION=$(curl -sS https://api.github.com/repos/moby/buildkit/releases/latest | grep '"tag_name":' | awk '{gsub(/[",]/, "", $2); print $2}')
BUILDKIT_URL="https://github.com/moby/buildkit/releases/download/${BUILDKIT_VERSION}/buildkit-${BUILDKIT_VERSION}.${OS}-${ARCH}.tar.gz"
curl -Lo /tmp/buildkit.tar.gz "$BUILDKIT_URL"
mkdir /tmp/buildkit-bin/
tar -xf /tmp/buildkit.tar.gz /tmp/buildkit-bin/
sudo install -Dm755 /tmp/buildkit-bin/bin/* /usr/bin/
sudo tee /usr/lib/systemd/system/buildkit.service <<EOF
[Unit]
Description=BuildKit
Requires=buildkit.socket
After=buildkit.socket
Documentation=https://github.com/moby/buildkit

[Service]
Type=notify
ExecStart=/usr/bin/buildkitd --addr fd://

[Install]
WantedBy=multi-user.target
EOF
sudo tee /usr/lib/systemd/system/buildkit.socket <<EOF
[Unit]
Description=BuildKit
Documentation=https://github.com/moby/buildkit

[Socket]
ListenStream=%t/buildkit/buildkitd.sock
SocketMode=0660

[Install]
WantedBy=sockets.target
EOF
sudo mkdir /etc/buildkit
sudo tee /etc/buildkit/buildkitd.toml <<EOF
[worker.oci]
	binary = "crun"
[worker.containerd]
	[worker.containerd.runtime]
		name = "io.containerd.runc.v2"
		path = "/usr/bin/containerd-shim-runc-v2"
		options = { BinaryName = "crun" }
EOF
sudo systemctl daemon-reload
sudo systemctl enable --now buildkit.service

# install nerdctl
NERDCTL_VERSION=$(curl -sS https://api.github.com/repos/containerd/nerdctl/releases/latest | grep '"tag_name":' | awk '{gsub(/[",]/, "", $2); print $2}')
NERDCTL_URL="https://github.com/containerd/nerdctl/releases/download/${NERDCTL_VERSION}/nerdctl-${NERDCTL_VERSION#v}-${OS}-${ARCH}.tar.gz"
curl -Lo /tmp/nerdctl.tar.gz "$NERDCTL_URL"
mkdir /tmp/nerdctl-bin
tar -xf /tmp/nerdctl.tar.gz -C /tmp/nerdctl-bin
sudo install -Dm755 /tmp/nerdctl-bin/* /usr/bin

sudo rm -rf /tmp/cni.tgz /tmp/containerd.tar.gz /tmp/crun /tmp/nerdctl.tar.gz /tmp/bin /tmp/cni-bin /tmp/nerdctl-bin /tmp/buildkit-bin/ /tmp/buildkit.tar.gz
