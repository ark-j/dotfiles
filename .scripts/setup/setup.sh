#!/usr/bin/bash

echo "installing cachy os repos" 
./cachyos-repo.sh

echo "configuring pacman"
sudo rm -rf /etc/pacman.conf
sudo cp ./pacman.conf /etc/

echo "updating the package index and system"
sudo pacman -Syyu

echo "installing necessary things"
sudo pacman -S mpv vlc \ 
	pnpm npm go rust python-pip luarocks zig \
	tmux fzf ripgrep fd stow lazygit lsd \
	wl-clipboard tree-sitter htop p7zip unzip unrar neovim zsh starship \
	brave-bin zen-browser-avx2-bin warp\
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

echo "setting up zsh as default"
chsh -s $(which zsh)
sudo chsh -s $(which zsh)

echo "setting up dotfiles"
git clone https://github.com/ark-j/dotfiles.git
cd dotfiles && stow .
