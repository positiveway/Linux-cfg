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

IsFirstRun=true

#Never do full-upgrade, some packages break for example Wine dependencies

# DE:
# Change fonts to JB Mono NL Normal 16pt.
# Fonts DPI: 192

# Config 1:
#     Don't touch defaults

# Config 2:
#     Use antialised fonts: Unchecked
#     Subpixel antialising: VRGB
#     Font hinting: Checked
#     Hinting style: Full

# LXQt Theme: Lubuntu Arc. Icons: Papirus Dark. Pallete: silver-dark. GTK Theme: Arc-Darcker. Cursor: Breeze
# Power Management: Disable Idleness watcher. Lid behaviour: Suspend

# Open LXQt Configuration Center -> Session Settings or run lxqt-config-session
# Set Global Screen scaling to 2.0

# Environment Variables (Advanced):
# Add QT_SCALE_FACTOR with value 2
# Add GDK_DPI_SCALE with value 1
# Add XCURSOR_SIZE with value 64
# Set GDK_SCALE to 2

# Shortcut keys: Remove Ctrl+Alt+ shortcuts

# Openbox:
# Theme: Lubuntu Breeze
# Change fonts to JB Mono NL Regular 16pt.
# Mouse: Check "Focus Windows". Check both "Move focus"

# System:
# Updates check every 2 weeks. Only notify.
# Locale switch: Right Ctrl only

# Firefox:
# JB Mono NL fonts 16pt for everything. Min size: 16pt. Scaling: 133%. Zoom text only: Unchecked. Allow pages to choose fonts: Unchecked.
# Website appearance: Dark

# layers.acceleration.force-enabled to true in about:config

# To control Firefox UI scaling:
# Set layout.css.devPixelsPerPx to 2.0 or different value (default is -1) on the about:config page

# Kate & Terminal:
# JB Mono NL Regular font 16pt

# Telegram:
# Settings -> Advanced -> Experimental -> Show panel by click

# Intelleji:
# UI Font: JB Mono NL Medium 22pt. Editor font: JB Mono 26pt.


# exit when any command fails
set -e

#Relative paths
THIS_SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
echo "Script directory: $THIS_SCRIPT_DIR"

RESOURCES_DIR="$THIS_SCRIPT_DIR/../Resources"
echo "Resources directory: $RESOURCES_DIR"

#Make folders
DirsToMake=(
    "$ScriptsDir"
    "$HOME/Downloads/Dev"
    "$ResourcesDir"
)
for DirToMake in "${DirsToMake[@]}"; do
    mkdir -p $DirToMake
done

#Version and DE
UbuntuCodename=$(lsb_release -cs)
echo "Ubuntu Codename: $UbuntuCodename"

IsUbuntuJammy=false && [[ "$UbuntuCodename" == jammy ]] && IsUbuntuJammy=true
echo "IsUbuntuJammy: $IsUbuntuJammy"

DebianVer=$(cat /etc/debian_version)
DebianVer=${DebianVer%/*}
echo "DebianVer $DebianVer"


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
$InstallApt ppa-purge apt-show-versions

#Restore NTFS mounting
$InstallApt fuse3 ntfs-3g

#AppImage
$InstallApt libfuse2

#Git
git config --global user.email "PositiveWay05@gmail.com"
git config --global user.name "Andrew"

#Run python configuration script
sudo python3 baseSetup.py

#controller
$InstallApt clang libsdl2-dev libdrm-dev libhidapi-dev libusb-1.0-0 libusb-1.0-0-dev libudev-dev libevdev-dev
sudo usermod -a -G input user

#Dim screen
$InstallApt x11-xserver-utils brightnessctl

#Touchpad
$RemoveApt xserver-xorg-input-synaptics
$InstallApt xserver-xorg-input-libinput

#Samsung sound
#Set right speaker +40% louder than left.
$InstallApt alsa-tools firmware-sof-signed

#Copy scripts to startup
for ScriptName in "dim_screen.sh" "fix_touchpad.sh" "fix_samsung_audio.sh"
do
ScriptDestPath="$LoginStartupDir/$ScriptName"
$SudoCopy $THIS_SCRIPT_DIR/$ScriptName $ScriptDestPath
sudo chmod +x $ScriptDestPath
done

#Copy to Documents/Scripts
for ScriptName in "necessary-verbs.sh" "run_steam.sh"
do
ScriptDestPath="$ScriptsDir/$ScriptName"
$SimpleCopy $RESOURCES_DIR/$ScriptName $ScriptDestPath
sudo chmod +x $ScriptDestPath
done

#Intel GPU
$InstallApt intel-gpu-tools

$RemoveApt xserver-xorg-video-intel
$RemoveFiles /etc/X11/xorg.conf.d/20-intel.conf

# echo 'Section "Device"
#   Identifier "Intel Graphics"
#   Driver "modesetting"
#   Option "TearFree" "true"
# EndSection' | sudo tee /etc/X11/xorg.conf.d/20-intel.conf

$InstallApt inxi hwinfo vainfo mesa-utils
hwinfo --display
glxinfo |grep OpenGL
vainfo
inxi -G

# Wifi
# sudo nano /etc/NetworkManager/conf.d/default-wifi-powersave-on.conf
#
# By default there is:
#
# [connection]
# wifi.powersave = 3
#
# Change the value to 2
#
# To take effect, just run:
# sudo systemctl restart NetworkManager

#Apps
$InstallApt gparted kate htop
sudo snap install mpv

#Gaming
$InstallApt mangohud

#Cpupower-gui
$InstallApt libicu-dev libxcb-cursor-dev cpupower-gui

#Android
$InstallApt android-tools-adb

# appimaged
# Remove pre-existing similar tools
set +e
systemctl --user stop appimaged.service || true
sudo apt-get -y remove appimagelauncher || true

# Clear cache
rm "$HOME"/.local/share/applications/appimage*
[ -f ~/.config/systemd/user/default.target.wants/appimagelauncherd.service ] && rm ~/.config/systemd/user/default.target.wants/appimagelauncherd.service

# Optionally, install Firejail (if you want sandboxing functionality)

# Download
mkdir -p ~/Applications
wget -c https://github.com/$(wget -q https://github.com/probonopd/go-appimage/releases/expanded_assets/continuous -O - | grep "appimaged-.*-x86_64.AppImage" | head -n 1 | cut -d '"' -f 2) -P ~/Applications/
chmod +x ~/Applications/appimaged-*.AppImage

# Launch
~/Applications/appimaged-*.AppImage
set -e

#scrcpy
$InstallApt ffmpeg libsdl2-2.0-0 adb wget \
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
#./install_release.sh
#scrcpy -d


#WITHOUT ACTIVATING WARP ADDING REPO CAN CAUSE CONNECTION TIMEOUT
#Warp
# Add cloudflare gpg key
curl -fsSL https://pkg.cloudflareclient.com/pubkey.gpg | sudo gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg

# Add this repo to your apt repositories
if $IsUbuntuJammy
then
WarpDistroVer="$UbuntuCodename"
else
WarpDistroVer="bookworm"
fi
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ $WarpDistroVer main" | sudo tee /etc/apt/sources.list.d/cloudflare-client.list

# Install
$UpdateApt && $InstallApt cloudflare-warp
warp-cli register
warp-cli set-mode warp+doh
warp-cli set-families-mode off
warp-cli enable-wifi
warp-cli connect

#Proprietary packages & Steam
$AddRepo multiverse

# Firefox
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

#Enable touchscreen support
StrContent="MOZ_USE_XINPUT2 DEFAULT=1"
FileToAdd="/etc/security/pam_env.conf"

grep -qxF "$StrContent" $FileToAdd || echo "$StrContent" | sudo tee -a $FileToAdd

#mainline kernel downloader
$AddRepo ppa:cappelikan/ppa
$InstallApt mainline

#MESA drivers
$AddRepo ppa:oibaf/graphics-drivers
$UpdateApt
$FullUpgrade
$InstallApt mesa-vdpau-drivers

#Torrent clients
$RemoveApt transmission-common transmission-qt

$AddRepo ppa:qbittorrent-team/qbittorrent-stable
$InstallApt qbittorrent

$SimpleCopy $RESOURCES_DIR/qBittorrentDarktheme-Rev12 $ResourcesDir/

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

#Fonts
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/JetBrains/JetBrainsMono/master/install_manual.sh)"

#rust
$DownloadStdOut https://sh.rustup.rs | sh -s -- -y
source "$HOME/.cargo/env"
rustup install nightly

# Android
rustup target add aarch64-linux-android
$InstallApt openjdk-17-jdk
sudo update-alternatives --config java
# Choose Java 17

#python
if $IsUbuntuJammy
then
pythonVer="11"

pythonPackage="python3.$pythonVer"
$AddRepo ppa:deadsnakes/ppa
$InstallApt $pythonPackage $pythonPackage-dev $pythonPackage-gdbm $pythonPackage-venv
fi

#calibre
sudo -v && wget --no-check-certificate -nv -O- https://download.calibre-ebook.com/linux-installer.sh | sudo sh /dev/stdin

#liquorix
# $AddRepo ppa:damentz/liquorix
# $InstallApt linux-image-liquorix-amd64 linux-headers-liquorix-amd64

#bdprochot
Repo="turnoff-BD-PROCHOT"
Filepath="$ScriptsDir/$Repo"
$RemoveFiles $Filepath
git clone https://github.com/yyearth/$Repo.git $Filepath

#mouse
Filepath="$ScriptsDir/mousewheel.sh"
$RemoveFiles $Filepath

$InstallApt imwheel zenity

wget -O $Filepath https://gist.githubusercontent.com/AshishKapoor/6f054e43578659b4525c47bf279099ba/raw/0b2ad8b67f02ebb01d99294b0ecb6feacc078f67/mousewheel.sh
chmod +x $Filepath
# $Filepath
fi

#qt5ct:
# Style: Breeze. Theme: Darker. Icon Theme: Papirus dark

# Set in Lubuntu Session variables:
# QT_PLATFORM_PLUGIN to qt5ct
# QT_QPA_PLATFORMTHEME to qt5ct

# $InstallApt qt5ct qt5-style-plugins

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

#GTK Themes
$InstallApt kde-config-gtk-style
# $InstallApt gnome-settings-daemon gsettings-desktop-schemas gsettings-qt

if $IsUbuntuJammy
then
echo "Ubuntu Jammy specific:"

#KDE backports
$AddRepo ppa:kubuntu-ppa/backports
$AddRepo ppa:kubuntu-ppa/backports-extra
$FullUpgrade
fi
fi

if $IsLXQt
then
echo "LXQt specific:"

if $IsUbuntuJammy
then
echo "Ubuntu Jammy specific:"

#LXQt backports
# $AddRepo ppa:lubuntu-dev/backports
# $FullUpgrade
fi
fi

if $IsGnome
then
echo "GNOME specific:"

$InstallApt gedit gnome-shell-extensions chrome-gnome-shell gnome-tweaks

#controller gnome
$InstallApt libgtk-3-dev libgtkmm-3.0-dev libappindicator3-dev gir1.2-appindicator3-0.1
fi

#Flatpak
$InstallApt flatpak plasma-discover-backend-flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

#Games
#ProtopUpQt
$Flatpak flathub net.davidotek.pupgui2

#Lutris
echo "deb [signed-by=/etc/apt/keyrings/lutris.gpg] https://download.opensuse.org/repositories/home:/strycore/Debian_12/ ./" | sudo tee /etc/apt/sources.list.d/lutris.list > /dev/null
wget -q -O- https://download.opensuse.org/repositories/home:/strycore/Debian_12/Release.key | gpg --dearmor | sudo tee /etc/apt/keyrings/lutris.gpg > /dev/null
$UpdateApt
$InstallApt lutris

#Heroic Games Launcher
# https://github.com/Heroic-Games-Launcher/HeroicGamesLauncher/releases/

#mangohud
$InstallApt mangohud goverlay

#grub
sudo update-grub

#Reinstall grub
# sudo grub-install /dev/nvme0n1
# sudo cat /boot/efi/EFI/ubuntu/grub.cfg

#show current boot parameters
cat /proc/cmdline

#Cpupower: show current CPU parameters
$InstallApt linux-tools-common
set +e
$InstallApt linux-tools-`uname -r`
cpupower frequency-info
set -e

#Disconnect Warp
warp-cli disconnect

#Surfshark
curl -f https://downloads.surfshark.com/linux/debian-install.sh --output surfshark-install.sh #gets the installation script
sh surfshark-install.sh #installs surfshark
# sudo apt-get remove -y surfshark surfshark-release

exit
exit


ExtDriveDir="$( echo $THIS_SCRIPT_DIR | cut -f 1,2,3,4 -d "/" )"
echo "External drive directory: $ExtDriveDir"

#go
goVersion="21.5"

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

# Panel Self Refresh (PSR), a power saving feature used by Intel iGPUs is known to cause flickering in some instances. A temporary solution is to disable this feature using the kernel parameter i915.enable_psr=0
#
# Low-powered Intel processors and/or laptop processors have a tendency to randomly hang or crash due to the problems with the power management features found in low-power Intel chips. If such a crash happens, you will not see any logs reporting this problem. Adding the following Kernel parameters may help to resolve the problem.
# Note: It is not advised to use all three of the below kernel parameters together.
#
# intel_idle.max_cstate=1 i915.enable_dc=0 ahci.mobile_lpm_policy=1
#
# ahci.mobile_lpm_policy=1 fixes a hang on several Lenovo laptops and some Acer notebooks due to problematic SATA controller power management. That workaround is strictly not related to Intel graphics but it does solve related issues. Adding this kernel parameter sets the link power management from firmware default to maximum performance and will also solve hangs when you change display brightness on certain Lenovo machines but increases idle power consumption by 1-1.5 W on modern ultrabooks. For further information, especially about the other states, see the Linux kernel mailing list and Red Hat documentation.
#
# i915.enable_dc=0 disables GPU power management. This does solve random hangs on certain Intel systems, notably Goldmount and Kaby Lake Refresh chips. Using this parameter does result in higher power use and shorter battery life on laptops/notebooks.
#
# intel_idle.max_cstate=1 limits the processors sleep states, it prevents the processor from going into deep sleep states. That is absolutely not ideal and does result in higher power use and lower battery life. However, it does solve random hangs on many Intel systems. Use this if you have a Intel Baytrail or a Kaby Lake Refresh chip. Intel "Baytrail" chips were known to randomly hang without this kernel parameter due to a hardware flaw, theoretically fixed 2019-04-26. More information about the max_cstate parameter can be found in the kernel documentation and about the cstates in general on a writeup on GitHub.
#
# If you try adding intel_idle.max_cstate=1 i915.enable_dc=0 ahci.mobile_lpm_policy=1 in the hope of fixing frequent hangs and that solves the issue you should later remove one by one to see which of them actually helped you solve the issue. Running with cstates and display power management disabled is not advisable if the actual problem is related to SATA power management and ahci.mobile_lpm_policy=1 is the one that actually solves it.
#
# Some NVMe devices may exhibit issues related to power saving (APST). This is a known issue for Kingston A2000 [8] as of firmware S5Z42105 and has previously been reported on Samsung NVMe drives (Linux v4.10) [9][10]
#
# A failure renders the device unusable until system reset, with kernel logs similar to:
#
#  nvme nvme0: I/O 566 QID 7 timeout, aborting
#  nvme nvme0: I/O 989 QID 1 timeout, aborting
#  nvme nvme0: I/O 990 QID 1 timeout, aborting
#  nvme nvme0: I/O 840 QID 6 timeout, reset controller
#  nvme nvme0: I/O 24 QID 0 timeout, reset controller
#  nvme nvme0: Device not ready; aborting reset, CSTS=0x1
#  ...
#  nvme nvme0: Device not ready; aborting reset, CSTS=0x1
#  nvme nvme0: Device not ready; aborting reset, CSTS=0x1
#  nvme nvme0: failed to set APST feature (-19)
#
# As a workaround, add the kernel parameter nvme_core.default_ps_max_latency_us=0 to completely disable APST, or set a custom threshold to disable specific states.

# The NMI watchdog is a debugging feature to catch hardware hangs that cause a kernel panic. On some systems it can generate a lot of interrupts, causing a noticeable increase in power usage:
#
# /etc/sysctl.d/disable_watchdog.conf
#
# kernel.nmi_watchdog = 0
#
# or add nmi_watchdog=0 to the kernel line to disable it completely from early boot.

# Since Linux 5.9, it is possible to set the cpufreq.default_governor kernel option.[6] To set the desired scaling parameters at boot, configure the cpupower utility and enable its systemd service. Alternatively, systemd-tmpfiles or udev rules can be used.

# You can also run the cat /proc/cmdline command to check the boot parameters. If you find iommu=on in the output, it confirms that IOMMU is enabled.

# By default, PulseAudio suspends any audio sources that have become idle for too long. When using an external USB microphone, recordings may start with a pop sound. As a workaround, comment out the following line in /etc/pulse/default.pa:
#
# load-module module-suspend-on-idle
#
# Afterwards, restart PulseAudio with systemctl restart --user pulseaudio
