#!/usr/bin/env bash

sudo apt-get remove timidity
sudo apt-get remove --purge pulseaudio
sudo apt-get install pulseaudio
sudo rm -rf ~/.config/pulse/*
sudo apt --reinstall install pipewire-media-session
sudo touch /usr/share/pipewire/media-session.d/with-pulseaudio
systemctl --user restart pipewire-session-manager
sudo alsa force-reload
