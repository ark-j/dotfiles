#!/usr/bin/bash

echo "removing uncessary apps"
sudo pacman -R gnome-contacts yelp gnome-user-docs gnome-maps gnome-music totem --noconfirm

echo "installing cachy os repos" 
./cachyos-repo.sh

echo "configuring pacman"
sudo rm -rf /etc/pacman.conf
sudo cp ./pacman.conf /etc/

echo "updating the package index and system"
sudo pacman -Syyu --noconfirm

echo "installing necessary things"
sudo pacman -S mpv vlc pnpm npm go rust python-pip luarocks zig paru tmux fzf ripgrep fd stow lazygit lsd rsync wl-clipboard tree-sitter htop p7zip unzip unrar neovim zsh starship brave-bin zen-browser-avx2-bin warp kitty alacritty bluez-cups bluez-mesh nautilus-image-converter nautilus-share seahorse-nautilus seahorse flameshot obs-studio drawio-desktop extension-manager fprintd qbittorrent docker sbctl qt5-wayland qt6-wayland kvantum kvantum-theme-libadwaita-git otf-geist-mono-nerd otf-hasklig-nerd ttf-agave-nerd ttf-bitstream-vera-mono-nerd ttf-fantasque-nerd ttf-iosevkaterm-nerd ttf-jetbrains-mono-nerd ttf-nerd-fonts-symbols ttf-nerd-fonts-symbols-common ttf-nerd-fonts-symbols-mono noto-color-emoji-fontconfig noto-fonts noto-fonts-emoji noto-fonts-extra inter-font papirus-icon-theme capitaine-cursors alacritty kitty gnome-photos gnome-terminal linux-firmware-qlogic adw-gtk-theme --noconfirm

echo "installing extra packages"
paru -Sa planify gnome-shell-extension-pop-shell-git nautilus-bluetooth spotify-adblock ast-firmware upd72020x-fw wd719x-firmware wd719x-firmware aic94xx-firmware --skipreview --removemake --cleanafter --nokeepsrc --noconfirm

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
cd ~/dotfiles && stow .

echo "installing auto p state for amd"
curl -sSL https://github.com/ark-j/auto-pstate/releases/download/0.0.2/install | bash

echo "configuring folder theme"
git clone https://github.com/EliverLara/Nordic.git /tmp/nordic
sudo mv /tmp/nordic/kde/folders/Nordic-* /usr/share/icons

echo "setting up themes, icon, cursor, fonts"
gsettings set org.gnome.desktop.interface cursor-theme 'capitaine-cursors-light'
gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark'
gsettings set org.gnome.desktop.interface icon-theme 'Nordic-bluish'
gsettings set org.gnome.desktop.interface font-name 'Inter 12'
gsettings set org.gnome.desktop.interface monospace-font-name 'Berkeley Mono Bold 14'
gsettings set org.gnome.desktop.interface document-font-name 'Inter 11'
