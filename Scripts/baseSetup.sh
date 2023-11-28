InstallApt="sudo apt install -y"
RemoveApt="sudo apt remove -y"
AutoRemoveApt="sudo apt autoremove -y"
InstallPkg="sudo dpkg -i"
UpdateApt="sudo apt update"
DownloadStdOut="wget -O -"
AddRepo="sudo add-apt-repository -y"
RemoveFiles="sudo rm -rf"
CopyFiles="sudo cp"
SysCtlUser="systemctl --user"
SysCtl="sudo systemctl"
Flatpak="flatpak install -y --noninteractive"
DocsDir="$HOME/Documents"
LoginStartupDir="/etc/profile.d"

IsFirstRun=false

#Never do full-upgrade, some packages break for example Wine dependencies

# DE:
# Change fonts to JB Mono NL Light 16pt.
# Antialising: slight. Subpixel: RGB. Force DPI: 192

# Openbox:
# Change fonts to JB Mono NL Light 16pt.
# Mouse: Check "Focus Windows". Check both "Move focus"

# System:
# Updates check every 2 weeks. Only notify.
# Locale switch: Right Alt only

# Firefox:
# JB Mono NL Light fonts 16pt for everything. Min size: 16pt. Scale text only 150%. Don't allow pages to choose fonts.

# Kate:
# JB Mono NL Light font 16pt

# Intelleji:
# UI Font: JB Mono NL Light 20pt. Editor font: JB Mono 26pt.


# exit when any command fails
set -e

#Relative paths
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
ExtDriveDir="$( echo $SCRIPT_DIR | cut -f 1,2,3,4 -d "/" )"
echo "Script directory: $SCRIPT_DIR"
echo "External drive directory: $ExtDriveDir"


CurDesktop=$(env | grep XDG_CURRENT_DESKTOP)
echo $CurDesktop

IsGnome=false && [[ "$CurDesktop" == *GNOME ]] && IsGnome=true
IsKDE=false && [[ "$CurDesktop" == *KDE ]] && IsKDE=true
IsLXQt=false && [[ "$CurDesktop" == *LXQt ]] && IsLXQt=true

echo "Gnome: $IsGnome"
echo "KDE: $IsKDE"
echo "LXQt: $IsLXQt"


$AutoRemoveApt

#build
$InstallApt git curl build-essential libssl-dev unzip

#kernel build
$InstallApt libncurses-dev gawk flex bison openssl libssl-dev dkms libelf-dev libudev-dev libpci-dev libiberty-dev autoconf

#multimedia
$InstallApt ubuntu-restricted-extras

#base
$InstallApt ppa-purge

#Restore NTFS mounting
$InstallApt fuse3 ntfs-3g

#AppImage
$InstallApt libfuse2

#mainline kernel downloader
$AddRepo ppa:cappelikan/ppa
$InstallApt mainline

#controller
$InstallApt clang libsdl2-dev libdrm-dev libhidapi-dev libusb-1.0-0 libusb-1.0-0-dev libevdev-dev

#Dim screen
$InstallApt x11-xserver-utils brightnessctl

ScriptName="dim_screen.sh"
ScriptDestPath="$LoginStartupDir/$ScriptName"
$CopyFiles $SCRIPT_DIR/$ScriptName $ScriptDestPath
sudo chmod +x $ScriptDestPath
# sudo chmod 744 $ScriptDestPath

#Touchpad
$RemoveApt xserver-xorg-input-synaptics
$InstallApt xserver-xorg-input-libinput

ScriptName="fix_touchpad.sh"
ScriptDestPath="$LoginStartupDir/$ScriptName"
$CopyFiles $SCRIPT_DIR/$ScriptName $ScriptDestPath
sudo chmod +x $ScriptDestPath

#Samsung sound
#Set right speaker +50% louder than left.
$InstallApt alsa-tools firmware-sof-signed

ScriptName="necessary-verbs.sh"
ScriptDestPath="$DocsDir/$ScriptName"
$CopyFiles $SCRIPT_DIR/$ScriptName $ScriptDestPath
sudo chmod +x $ScriptDestPath

ScriptName="fix_samsung_audio.sh"
ScriptDestPath="$LoginStartupDir/$ScriptName"
$CopyFiles $SCRIPT_DIR/$ScriptName $ScriptDestPath
sudo chmod +x $ScriptDestPath

#Intel GPU
# $InstallApt xserver-xorg-video-intel
# echo 'Section "Device"
#     Identifier    "Intel Graphics"
#     Driver        "intel"
#     Option      "AccelMethod"  "uxa"
#     Option      "DRI"  "iris"
#     Option      "TearFree"        "true"
#     Option      "TripleBuffer"    "true"
#     Option      "SwapbuffersWait" "true"
# EndSection' | sudo tee /etc/X11/xorg.conf.d/20-intel.conf

$RemoveApt xserver-xorg-video-intel
$RemoveFiles /etc/X11/xorg.conf.d/20-intel.conf

inxi -G

#Fonts
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/JetBrains/JetBrainsMono/master/install_manual.sh)"

#Git
git config --global user.email "PositiveWay05@gmail.com"
git config --global user.name "Andrew"

#liquorix
$AddRepo ppa:damentz/liquorix
$InstallApt linux-image-liquorix-amd64 linux-headers-liquorix-amd64

# Firefox
# Manual: layers.acceleration.force-enabled to true in about:config

# disable exitting on error temporarily
set +e
sudo snap remove firefox
# bring it back
set -e

$AddRepo ppa:mozillateam/ppa
echo '
Package: *
Pin: release o=LP-PPA-mozillateam
Pin-Priority: 1001
' | sudo tee /etc/apt/preferences.d/mozilla-firefox
echo 'Unattended-Upgrade::Allowed-Origins:: "LP-PPA-mozillateam:${distro_codename}";' | sudo tee /etc/apt/apt.conf.d/51unattended-upgrades-firefox
$InstallApt firefox

#Apps
$InstallApt gparted kate

#Cpupower
$InstallApt libicu-dev libxcb-cursor-dev cpupower-gui

#Telegram
if [  ! -d "$DocsDir/Telegram" ]; then
echo "Telegram is not installed. Installing..."

Filepath="$DocsDir/tg.tar.xz"
wget -O $Filepath https://telegram.org/dl/desktop/linux
tar -xf $Filepath -C $DocsDir
$RemoveFiles $Filepath
fi

if $IsFirstRun
then
echo "First run:"

#rust
$DownloadStdOut https://sh.rustup.rs | sh -s -- -y
source "$HOME/.cargo/env"
rustup default stable

#calibre
sudo -v && wget --no-check-certificate -nv -O- https://download.calibre-ebook.com/linux-installer.sh | sudo sh /dev/stdin

#bdprochot
prochotRepo="turnoff-BD-PROCHOT"
Filepath="$DocsDir/$prochotRepo"
$RemoveFiles $Filepath
git clone https://github.com/yyearth/$prochotRepo.git $Filepath

#mouse
Filepath="$DocsDir/mousewheel.sh"
$RemoveFiles $Filepath

$InstallApt imwheel zenity

wget -O $Filepath https://gist.githubusercontent.com/AshishKapoor/6f054e43578659b4525c47bf279099ba/raw/0b2ad8b67f02ebb01d99294b0ecb6feacc078f67/mousewheel.sh
chmod +x $Filepath
# $Filepath

#Copy pass
cp $ExtDriveDir/Dropbox/Settings/Pass.txt $DocsDir
fi

#Flatpak
$InstallApt flatpak plasma-discover-backend-flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

#ProtopUpQt
$Flatpak flathub net.davidotek.pupgui2

if $IsKDE
then
echo "KDE specific:"

#Disable baloo indexer
sudo balooctl config set contentIndexing no
sudo balooctl disable
sudo balooctl purge
sudo rm -rf .local/share/baloo/

#Wayland
$InstallApt plasma-workspace-wayland
fi

if $IsLXQt
then
echo "LXQt specific:"

#Lubuntu LXQt backports
# $AddRepo ppa:lubuntu-dev/backports
# sudo apt full-upgrade

#Touchpad
# echo 'Section "InputClass"
#         Identifier "touchpad"
#         MatchIsTouchpad "on"
#         Driver "libinput"
#         Option "Tapping" "on"
#         Option "NaturalScrolling" "off"
# EndSection' | sudo tee /etc/X11/xorg.conf.d/40-libinput.conf
#reboot

#        MatchDevicePath "/dev/input/event*"
#        Option "InvY" "on"
#        Option "ButtonMapping" "3 2 1"
#        Option "TapButton1" "1"
#        Option "TapButton2" "3"
#        Option "TapButton3" "2"
fi

if $IsGnome
then
echo "GNOME specific:"

$InstallApt gedit gnome-shell-extensions chrome-gnome-shell gnome-tweaks

#controller gnome
$InstallApt libgtk-3-dev libgtkmm-3.0-dev libappindicator3-dev gir1.2-appindicator3-0.1
fi

#python
pythonVer="11"

pythonPackage="python3.$pythonVer"
$AddRepo ppa:deadsnakes/ppa
$InstallApt $pythonPackage $pythonPackage-dev $pythonPackage-gdbm $pythonPackage-venv


#Reinstall grub
# sudo grub-install /dev/nvme0n1
# sudo cat /boot/efi/EFI/ubuntu/grub.cfg

exit
exit

#Wine & Steam
sudo dpkg --add-architecture i386
$UpdateApt
$InstallApt wine64 wine32 libasound2-plugins:i386 libsdl2-2.0-0:i386 libdbus-1-3:i386 libsqlite3-0:i386
$InstallApt steam

#Mesa drivers
$AddRepo ppa:kisak/kisak-mesa
sudo apt upgrade

#go
goVersion="19.4"

goPackage="go1.$goVersion.linux-amd64.tar.gz"
wget https://go.dev/dl/$goPackage
$RemoveFiles /usr/local/go && sudo tar -C /usr/local -xzf $goPackage
$RemoveFiles ./$goPackage

#Disable snap
$SysCtl disable snapd.service
$SysCtl disable snapd.socket
$SysCtl disable snapd.seeded.service
$SysCtl mask snapd.service

#time dualboot
timedatectl set-local-rtc 1

#custom kernels 
#xanmod
echo 'deb http://deb.xanmod.org releases main' | sudo tee /etc/apt/sources.list.d/xanmod-kernel.list
$DownloadStdOut https://dl.xanmod.org/gpg.key | sudo apt-key --keyring /etc/apt/trusted.gpg.d/xanmod-kernel.gpg add -
$UpdateApt
$InstallApt linux-xanmod linux-xanmod-edge

