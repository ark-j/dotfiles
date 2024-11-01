#!/usr/bin/bash

echo "installing cachy os repos" 
curl https://mirror.cachyos.org/cachyos-repo.tar.xz -o cachyos-repo.tar.xz
tar xvf cachyos-repo.tar.xz && cd cachyos-repo
sudo ./cachyos-repo.sh
cd ..
rm -rf cachyos-repo

echo "installing necessary things"
sudo pacman -S mpv vlc \ 
	pnpm npm go rust python-pip luarocks \
	tmux fzf ripgrep fd stow lazygit lsd \
	wl-clipboard tree-sitter htop p7zip unzip unrar neovim zsh starship \
	brave-bin zen-browser-avx2-bin warp \
	bluez-cups bluez-mesh nautilus-image-converter nautilus-share seahorse-nautilus seahorse \
	flameshot obs-studio drawio-desktop extension-manager fprintd qbittorrent docker sbctl \
	qt5-wayland qt6-wayland kvantum kvantum-theme-libadwaita-git \
	papirus capitaine-cursors --noconform

echo "installing extra packages"
paru -Sa planify gnome-shell-extension-pop-shell-git nautilus-bluetooth spotify-adblock --skipreview --removemake --cleanafter --nokeepsrc --noconform

echo "installing tmux package manager"
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

echo "setting up docker"
sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker

echo "enabling services"
sudo systemctl enable docker.service containerd.service bluetooth.service bluetooth-mesh.service
