# WARN -> be careful if your cpu don't support following architecture you're bound to doom
# to check use -> /lib/ld-linux-x86-64.so.2 --help | grep supported
# I know that my cpu which ryzen 7 PRO 6850U supports x86-64-v3 so i have config in place

# adding keyring first
sudo pacman-key --recv-keys F3B607488DB35A47 --keyserver keyserver.ubuntu.com
sudo pacman-key --lsign-key F3B607488DB35A47

# adding the repos
sudo pacman -U 'https://mirror.cachyos.org/repo/x86_64/cachyos/cachyos-keyring-20240331-1-any.pkg.tar.zst' \
          'https://mirror.cachyos.org/repo/x86_64/cachyos/cachyos-mirrorlist-18-1-any.pkg.tar.zst'    \
          'https://mirror.cachyos.org/repo/x86_64/cachyos/cachyos-v3-mirrorlist-18-1-any.pkg.tar.zst' \
          'https://mirror.cachyos.org/repo/x86_64/cachyos/cachyos-v4-mirrorlist-6-1-any.pkg.tar.zst'  \
          'https://mirror.cachyos.org/repo/x86_64/cachyos/pacman-7.0.0.r3.gf3211df-3.1-x86_64.pkg.tar.zst' --noconfirm

