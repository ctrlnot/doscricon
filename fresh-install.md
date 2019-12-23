# Setup after fresh install (arch based)

### update packages
sudo pacman-mirrors -g && sudo pacman -Syyu
sudo pacman-db-upgrade && sync

### start firewall
sudo systemctl enable ufw && sudo systemctl start ufw

### aur yay
sudo pacman -S git && git clone [yay](https://aur.archlinux.org/yay.git)
cd yay && makepkg -si

### fix timezone
sudo timedatectl set-local-rtc 0
sudo systemctl enable --now systemd-timesyncd
sudo ln -sf /usr/share/zoneinfo/Asia/Manila /etc/localtime

### programs
sudo pacman -S nvidia
               jq
yay -S ttf-ms-fonts
       qbittorrent
       vivaldi
       brave-bin
       gallery-dl
       sayonara-player
       youtube-dl-git
       deezloader-remix-git

### other setups
- install mozilla, vivaldi and brave settings
- github ssh key
- [nvm](https://github.com/nvm-sh/nvm)
- [doscricon](https://github.com/ctrlnot/doscricon)
