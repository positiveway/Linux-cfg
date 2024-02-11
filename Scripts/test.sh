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
SimpleCopy="cp -r"
SudoCopy="sudo $SimpleCopy"
SysCtlUser="systemctl --user"
SysCtl="sudo systemctl"
Flatpak="flatpak install -y --noninteractive"
DocsDir="$HOME/Documents"
ScriptsDir="$DocsDir/Scripts"
ResourcesDir="$DocsDir/Resources"
LoginStartupDir="/etc/profile.d"

set -e

UbuntuCodename=$(lsb_release -cs)
echo "Ubuntu Codename: $UbuntuCodename"

IsUbuntuJammy=false && [[ "$UbuntuCodename" == jammy ]] && IsUbuntuJammy=true
echo "IsUbuntuJammy: $IsUbuntuJammy"

if $IsUbuntuJammy
then
WarpDistroVer="$UbuntuCodename"
else
WarpDistroVer="bookworm"
fi
echo "$WarpDistroVer"


DebianVer=$(cat /etc/debian_version)
DebianVer=${DebianVer%/*}
echo "$DebianVer"

echo "deb [signed-by=/etc/apt/keyrings/lutris.gpg] https://download.opensuse.org/repositories/home:/strycore/Debian_12/ ./" | sudo tee /etc/apt/sources.list.d/lutris.list > /dev/null
wget -q -O- https://download.opensuse.org/repositories/home:/strycore/Debian_12/Release.key | gpg --dearmor | sudo tee /etc/apt/keyrings/lutris.gpg > /dev/null
sudo apt update
sudo apt install lutris

exit

#scrcpy
sudo apt install ffmpeg libsdl2-2.0-0 adb wget \
                 gcc git pkg-config meson ninja-build libsdl2-dev \
                 libavcodec-dev libavdevice-dev libavformat-dev libavutil-dev \
                 libswresample-dev libusb-1.0-0 libusb-1.0-0-dev

Repo="scrcpy"
Filepath="$DocsDir/$Repo"
if [  ! -d "$Filepath" ]; then
echo "Installing $Repo"
git clone https://github.com/Genymobile/$Repo.git $Filepath
fi
cd $Filepath
git pull
./install_release.sh
scrcpy -d


goVersion="21.5"

goPackage="go1.$goVersion.linux-amd64.tar.gz"
wget https://go.dev/dl/$goPackage
$RemoveFiles /usr/local/go && sudo tar -C /usr/local -xzf $goPackage
$RemoveFiles ./$goPackage


#Torrent clients
$RemoveApt transmission-common transmission-qt

$AddRepo ppa:qbittorrent-team/qbittorrent-stable
$InstallApt qbittorrent



#Grub
StrContent='GRUB_DEFAULT=saved
GRUB_SAVEDEFAULT=true
GRUB_TIMEOUT_STYLE=menu
GRUB_TIMEOUT=20'
FileToAdd="/etc/default/grub"

grep -qxF "$StrContent" $FileToAdd || echo "$StrContent" | sudo tee -a $FileToAdd


#Set environment variables
EnvVariables=(
    '#Fix locale
export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8'

    '#Set formats
export LC_COLLATE=en_DE.UTF-8
export LC_MEASUREMENT=en_DE.UTF-8
export LC_MONETARY=en_DE.UTF-8
export LC_NUMERIC=en_DE.UTF-8
export LC_TIME=en_DE.UTF-8'

    '#Set scaling
export GDK_DPI_SCALE=1
export GDK_SCALE=2
export QT_SCALE_FACTOR=2
export XCURSOR_SIZE=64'

    '#Configure GTK
export GTK_CSD=0'
)

FileToAdd="$HOME/.profile"

for StrContent in "${EnvVariables[@]}"; do
    grep -qxF "$StrContent" $FileToAdd || echo "$StrContent" | sudo tee -a $FileToAdd
done

#Set scaling
StrContent='export GDK_DPI_SCALE=1
export GDK_SCALE=2
export QT_SCALE_FACTOR=2
export XCURSOR_SIZE=64'
FileToAdd="$HOME/.profile"

grep -qxF "$StrContent" $FileToAdd || echo "$StrContent" | sudo tee -a $FileToAdd

StrContent='export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8'
FileToAdd="$HOME/.profile"

grep -qxF "$StrContent" $FileToAdd || echo "$StrContent" | sudo tee -a $FileToAdd

StrContent="MOZ_USE_XINPUT2 DEFAULT=1"
FileToAdd="/etc/security/pam_env.conf"

grep -qxF "$StrContent" $FileToAdd || echo "$StrContent" | sudo tee -a $FileToAdd



WineRepoPath='https://dl.winehq.org/wine-builds/ubuntu/dists/'"$UbuntuCodename"'/winehq-'"$UbuntuCodename"'.sources'
echo "WineRepoPath: $WineRepoPath"

echo "https://dl.winehq.org/wine-builds/ubuntu/dists/$UbuntuCodename/winehq-$UbuntuCodename.sources"


#Enable 32bit architecture for Wine & Steam
sudo dpkg --add-architecture i386
$UpdateApt
# $InstallApt libasound2-plugins:i386 libsdl2-2.0-0:i386 libdbus-1-3:i386 libsqlite3-0:i386
echo "1"

#Install wine
# $InstallApt wine64 wine32
sudo mkdir -pm755 /etc/apt/keyrings
sudo wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key
sudo wget -NP /etc/apt/sources.list.d/ "https://dl.winehq.org/wine-builds/ubuntu/dists/$UbuntuCodename/winehq-$UbuntuCodename.sources"
$UpdateApt
sudo apt install --install-recommends winehq-stable
echo "2"

#winetricks
$InstallApt cabextract p7zip unrar unzip wget zenity
echo "3"

Filepath="$DocsDir/winetricks"
$RemoveFiles $Filepath

wget -O $Filepath https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks
chmod +x $Filepath
sh $Filepath corefonts vcrun6
echo "4"

#Steam
$InstallApt steam
echo "5"

#Playonlinux
$InstallApt playonlinux
echo "6"

