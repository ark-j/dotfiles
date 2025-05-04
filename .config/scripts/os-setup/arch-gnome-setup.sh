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
    containerd buildkit cni-plugins nerdctl pigz fprintd pahole neovim \
    paru tmux fzf ripgrep fd stow lsd rsync wl-clipboard reflector \
    htop p7zip unzip unrar starship wireless-regdb \
    otf-geist-mono-nerd otf-hasklig-nerd ttf-agave-nerd \
    ttf-bitstream-vera-mono-nerd ttf-fantasque-nerd \
    ttf-iosevkaterm-nerd ttf-jetbrains-mono-nerd \
	virt-manager qemu-base iptables-nft nftables dnsmasq linux-lts-headers \
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
paru -Sa planify gnome-shell-extension-pop-shell-git nautilus-bluetooth \
	spotify ast-firmware upd72020x-fw wd719x-firmware wd719x-firmware \
	aic94xx-firmware --skipreview --removemake --cleanafter --nokeepsrc --noconfirm

echo "copying reflector config"
sudo rm -rf /etc/xdg/reflector/reflector.conf
sudo cp ./reflector.conf /etc/xdg/reflector/

echo "installing auto p state for amd"
curl -sSL https://github.com/ark-j/auto-pstate/releases/download/0.0.2/install | bash

echo "setting up nerdctl"
mkdir -p $HOME/.bin
chmod 700 $HOME/.bin
cp /usr/bin/nerdctl $HOME/.bin
sudo chown root $HOME/.bin/nerdctl
sudo chmod +s $HOME/.bin/nerdctl

echo "setting up libvirt"
sudo usermod -aG libvirt $USER
sudo gpasswd -a $USER kvm

echo "enabling services"
sudo systemctl enable --now \
	containerd.service \
	buildkit.service \
	bluetooth.service \
	bluetooth-mesh.service \
	cups.service \
	reflector.service \
	sshd.service \
	libvirtd.service

echo "setting up dotfiles"
cd ~/dotfiles && stow .

echo "installing tmux package manager"
git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm

echo "setting up zsh as default"
chsh -s $(which zsh)
sudo chsh -s $(which zsh)

echo "installing kind"
$(uname -m) = x86_64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.26.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

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

echo "setting up themes, icon, cursor, fonts"
gsettings set org.gnome.desktop.interface cursor-theme 'capitaine-cursors-light'
gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark'
gsettings set org.gnome.desktop.interface icon-theme 'Nordic-bluish'
gsettings set org.gnome.desktop.interface font-name 'Inter 11'
gsettings set org.gnome.desktop.interface monospace-font-name 'JetBrainsMono Nerd Font 13' 
gsettings set org.gnome.desktop.interface document-font-name 'Inter 11'
