#!/usr/bin/env bash

InstallApt="sudo apt install -y"
RemoveApt="sudo apt remove -y"
AutoRemoveApt="sudo apt autoremove -y"
InstallPkg="sudo dpkg -i"
UpdateApt="sudo apt update"
DownloadStdOut="wget -O -"
AddRepo="sudo add-apt-repository -y"
FullUpgrade="sudo apt full-upgrade -y"
RemoveFiles="sudo rm -rf"
CopyFiles="sudo cp"
SysCtlUser="systemctl --user"
SysCtl="sudo systemctl"
Flatpak="flatpak install -y --noninteractive"
DocsDir="$HOME/Documents"
ScriptsDir="$DocsDir/Scripts"
LoginStartupDir="/etc/profile.d"

set -e

UbuntuCodename=$(lsb_release -cs)
echo "Ubuntu Codename: $UbuntuCodename"

IsUbuntuJammy=false && [[ "$UbuntuCodename" == jammy ]] && IsUbuntuJammy=true
echo "IsUbuntuJammy: $IsUbuntuJammy"

DebianVer=$(cat /etc/debian_version)
DebianVer=${DebianVer%/*}
echo "DebianVer $DebianVer"


#Enable 32bit architecture for Wine & Steam
sudo dpkg --add-architecture i386
$UpdateApt

#Install wine
sudo mkdir -pm755 /etc/apt/keyrings
sudo wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key

sudo wget -NP /etc/apt/sources.list.d/ "https://dl.winehq.org/wine-builds/ubuntu/dists/$UbuntuCodename/winehq-$UbuntuCodename.sources"
$UpdateApt
sudo apt install --install-recommends wine-stable

#winetricks
$InstallApt cabextract p7zip unrar unzip wget zenity
Filepath="$ScriptsDir/winetricks"
$RemoveFiles $Filepath

wget -O $Filepath https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks
chmod +x $Filepath
sh $Filepath corefonts vcrun6

#Playonlinux
$InstallApt playonlinux

#PortProton
$InstallApt curl file libc6 libnss3 policykit-1 xz-utils bubblewrap curl icoutils tar libvulkan1 libvulkan1:i386  zstd cabextract xdg-utils openssl libgl libgl1:i386

#Steam
$InstallApt steam
steam
