sudo pacman -R --noconfirm docker docker-buildx containerd docker-compose 
sudo pacman -S --noconfirm containerd buildkit cni-plugins nerdctl

echo "setting up nerdctl"
sudo mkdir -p /etc/containerd /etc/buildkit /etc/nerdctl
sudo tee /etc/containerd/config.toml > /dev/null <<EOF
version = 3
[plugins.'io.containerd.cri.v1.runtime'.containerd.runtimes.runc.options]
	SystemdCgroup = true
	snapshotter = "overlayfs"
[plugins.'io.containerd.cri.v1.images']
	snapshotter = "overlayfs"
	use_local_image_pull = true
	max_concurrent_downloads = 5
EOF

sudo tee /etc/buildkit/buildkitd.toml > /dev/null <<EOF
debug = false
[log]
	format = "json"
[worker.oci]
	enabled = false
	max-parallelism = 4
	rootless = false
[worker.containerd]
	address = "/run/containerd/containerd.sock"
	enabled = true
	namespace = "k8s.io"
	gc = true
	[worker.containerd.runtime]
		name = "io.containerd.runc.v2"
		path = "/usr/bin/containerd-shim-runc-v2"
		options = { BinaryName = "runc" }
EOF

sudo tee /etc/nerdctl/nerdctl.toml > /dev/null <<EOF
debug				= false
debug_full			= false
experimental		= true
namespace			= "k8s.io"
cgroup_manager		= "systemd"
snapshotter			= "overlayfs"
insecure_registry	= true
EOF

install -dm700 $HOME/.bin
sudo install -o root -m 4755 "/usr/bin/nerdctl" "$HOME/.bin/"

# enable the required services
sudo systemctl enable --now containerd.service buildkit.service
