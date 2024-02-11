#!/usr/bin/env bash

InstallApt="sudo apt install -y"
RemoveApt="sudo apt remove -y"
AutoRemoveApt="sudo apt autoremove -y"
InstallPkg="sudo dpkg -i"
UpdateApt="sudo apt update"
DownloadStdOut="wget -O -"
AddRepo="sudo add-apt-repository -y"
RemoveFiles="sudo rm -rf"
CopyFiles="sudo cp"
SystemCtl="systemctl --user"

# exit when any command fails
set -e

CurDesktop=$(env | grep XDG_CURRENT_DESKTOP)
echo $CurDesktop

IsGnome=false && [[ "$CurDesktop" == *GNOME ]] && IsGnome=true
IsKde=false && [[ "$CurDesktop" == *KDE ]] && IsKde=true

echo $IsGnome $IsKde

$AutoRemoveApt

#build
$InstallApt git curl build-essential libssl-dev unzip

#kernel build
$InstallApt libncurses-dev gawk flex bison openssl libssl-dev dkms libelf-dev libudev-dev libpci-dev libiberty-dev autoconf

#multimedia
$InstallApt ubuntu-restricted-extras

#Chrome
$InstallPkg ../Apps/google-chrome-stable_current_amd64.deb

#Telegram
tlgArchive="tsetup.*.tar.xz"
$RemoveFiles $HOME/Downloads/Telegram
tar -C $HOME/Downloads -xf ../Apps/$tlgArchive

#VPN
$InstallApt openresolv wireguard
$CopyFiles -R ../../../VPN/keychains/* /etc/wireguard
sudo chown root:root -R /etc/wireguard && sudo chmod 600 -R /etc/wireguard

#rust
$DownloadStdOut https://sh.rustup.rs | sh -s -- -y
source "$HOME/.cargo/env"
rustup default stable

#go
goVersion="19.4"

goPackage="go1.$goVersion.linux-amd64.tar.gz"
wget https://go.dev/dl/$goPackage
$RemoveFiles /usr/local/go && sudo tar -C /usr/local -xzf $goPackage
$RemoveFiles ./$goPackage

#python
pythonVer="9"

pythonPackage="python3.$pythonVer"
$AddRepo ppa:deadsnakes/ppa
$InstallApt $pythonPackage $pythonPackage-dev $pythonPackage-gdbm $pythonPackage-venv

#mainline kernel downloader
$AddRepo ppa:cappelikan/ppa
$InstallApt mainline

#controller
$InstallApt clang libsdl2-dev libdrm-dev libhidapi-dev libusb-1.0-0 libusb-1.0-0-dev libevdev-dev


exit
#controller gnome
$InstallApt libgtk-3-dev libgtkmm-3.0-dev libappindicator3-dev gir1.2-appindicator3-0.1

#gnome
$InstallApt gedit gnome-shell-extensions chrome-gnome-shell gnome-tweaks

#time dualboot
timedatectl set-local-rtc 1

#bdprochot
prochotRepo="turnoff-BD-PROCHOT"
cd $HOME/Documents
$RemoveFiles ./$prochotRepo
git clone https://github.com/yyearth/$prochotRepo.git


#mouse
$InstallApt imwheel
bash <($DownloadStdOut http://www.nicknorton.net/mousewheel.sh)
chmod +x mousewheel.sh
./mousewheel.sh

#custom kernels 
#xanmod
echo 'deb http://deb.xanmod.org releases main' | sudo tee /etc/apt/sources.list.d/xanmod-kernel.list
$DownloadStdOut https://dl.xanmod.org/gpg.key | sudo apt-key --keyring /etc/apt/trusted.gpg.d/xanmod-kernel.gpg add -
$UpdateApt
$InstallApt linux-xanmod linux-xanmod-edge

#liquorix
$AddRepo ppa:damentz/liquorix
$InstallApt linux-image-liquorix-amd64 linux-headers-liquorix-amd64

#Pipewire
$AddRepo ppa:pipewire-debian/pipewire-upstream
$InstallApt pipewire pipewire-audio-client-libraries libspa-0.2-bluetooth libspa-0.2-jack

$CopyFiles /usr/share/doc/pipewire/examples/alsa.conf.d/99-pipewire-default.conf /etc/alsa/conf.d/
$CopyFiles /usr/share/doc/pipewire/examples/ld.so.conf.d/pipewire-jack-*.conf /etc/ld.so.conf.d/
sudo ldconfig

$SystemCtl daemon-reload
$SystemCtl --now disable pulseaudio.service pulseaudio.socket
$SystemCtl mask pulseaudio
$SystemCtl --now enable pipewire-media-session.service
$SystemCtl restart pipewire

$RemoveApt pulseaudio-module-bluetooth ofono

