#!/usr/bin/bash

set -euo pipefail

token=${1:-""}

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
sudo pacman -S \
    mpv vlc flameshot obs-studio drawio-desktop \
    gnome-photos nautilus-image-converter nautilus-share \
    pnpm npm go rust python-pip luarocks zig tree-sitter \
	docker docker-buildx containerd docker-compose pigz fprintd pahole neovim \
    paru tmux fzf ripgrep fd stow lsd rsync wl-clipboard reflector \
    btop p7zip unzip unrar starship wireless-regdb rofi dmenu \
    otf-geist-mono-nerd otf-hasklig-nerd ttf-agave-nerd \
    ttf-bitstream-vera-mono-nerd ttf-fantasque-nerd \
    ttf-iosevkaterm-nerd ttf-jetbrains-mono-nerd \
	qemu-base virt-install libvirt dnsmasq iptables-nft nftables linux-lts-headers \
    ttf-nerd-fonts-symbols ttf-nerd-fonts-symbols-common \
    ttf-nerd-fonts-symbols-mono noto-color-emoji-fontconfig \
    noto-fonts noto-fonts-emoji noto-fonts-extra inter-font \
    adw-gtk-theme kvantum kvantum-theme-libadwaita-git \
    papirus-icon-theme capitaine-cursors figlet \
    kitty alacritty gnome-terminal zsh bluez-mesh \
    seahorse seahorse-nautilus brave-bin zen-browser-avx2-bin \
    localsend extension-manager cups logrotate ipp-usb \
    qt5-wayland qt6-wayland linux-firmware-qlogic realtime-privileges \
    lazygit silicon bat qbittorrent sbctl sshpass tldr git-delta \
	--noconfirm

echo "improving audio by adding realtime privileges user"
sudo gpasswd -a $USER realtime

echo "installing extra packages"
paru -Sa gnome-shell-extension-pop-shell-git nautilus-bluetooth \
	spotify ast-firmware upd72020x-fw wd719x-firmware wd719x-firmware \
	aic94xx-firmware --skipreview --removemake --cleanafter --nokeepsrc --noconfirm

echo "copying reflector config"
sudo rm -rf /etc/xdg/reflector/reflector.conf
sudo cp ./reflector.conf /etc/xdg/reflector/

echo "installing auto p state for amd"
curl -sSL https://github.com/ark-j/auto-pstate/releases/download/0.0.3/install | sudo bash

echo "setting up libvirt"
sudo virsh net-start default
sudo virsh net-autostart default

echo "setting up docker"
sudo tee /etc/modprobe.d/overlay.conf > /dev/null <<EOF
# Used by docker to avoid issue:
# Not using native diff for overlay2, this may cause degraded performance for building images:
# kernel has CONFIG_OVERLAY_FS_REDIRECT_DIR enabled
options overlay metacopy=off
options overlay redirect_dir=off
EOF
sudo groupadd docker
sudo usermod -aG docker $USER

echo "enabling services"
sudo systemctl enable --now \
	docker.service \
	docker.socket \
	bluetooth.service \
	bluetooth-mesh.service \
	cups.service \
	reflector.service \
	sshd.service \
	libvirtd.service

echo "setting up dotfiles"
cd ~/dotfiles && stow .

echo "installing tmux package manager and plugins"
git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
~/.config/tmux/plugins/tpm/bin/install_plugins

echo "setting up zsh as default"
chsh -s $(which zsh)
sudo chsh -s $(which zsh)

echo "installing kind"
../generic/kind.sh

echo "configuring folder theme"
git clone https://github.com/EliverLara/Nordic.git /tmp/nordic
sudo mv /tmp/nordic/kde/folders/Nordic-* /usr/share/icons

if [ -n "$token" ]; then
	echo "storing git secrets in gnome-keyring"
	echo -e "protocol=https\nhost=github.com\nusername=ark-j\npassword=$token" | /usr/lib/git-core/git-credential-libsecret store
fi

echo "refreshing font cache"
sudo fc-cache -fv
fc-cache -fv

echo "copying wallpapers"
cp -r ./wallpapers/* ~/.local/share/backgrounds/

echo "setting up themes, icon, cursor, fonts"
gsettings set org.gnome.desktop.interface cursor-theme 'capitaine-cursors-light'
gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark'
gsettings set org.gnome.desktop.interface icon-theme 'Nordic-bluish'
gsettings set org.gnome.desktop.interface monospace-font-name 'JetBrainsMono Nerd Font 13' 

read -p "Do you want performance for ext4? (y/n): " choice
case "$choice" in
  y|Y|yes|YES )
	echo "increasing performance of ext4 system if detected"
	sudo ./ext4-perf.sh
	break
    ;;
  n|N|no|NO )
    echo "Exiting..."
    exit 0
    ;;
  * )
    echo "Invalid input. Please enter y or n."
    ;;
esac
