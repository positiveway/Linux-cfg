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
SysCtlUser="systemctl --user"
SysCtl="sudo systemctl"
DocsDir="$HOME/Documents"

# exit when any command fails
set -e

#Pipewire
$InstallApt pipewire pipewire-audio-client-libraries libspa-0.2-bluetooth libspa-0.2-jack

$CopyFiles /usr/share/doc/pipewire/examples/alsa.conf.d/99-pipewire-default.conf /etc/alsa/conf.d/
$CopyFiles /usr/share/doc/pipewire/examples/ld.so.conf.d/pipewire-jack-*.conf /etc/ld.so.conf.d/
sudo ldconfig

$SysCtlUser daemon-reload
$SysCtlUser --now disable pulseaudio.service pulseaudio.socket
$SysCtlUser mask pulseaudio
$SysCtlUser --now enable pipewire-media-session.service
$SysCtlUser restart pipewire

$RemoveApt pulseaudio-module-bluetooth ofono
