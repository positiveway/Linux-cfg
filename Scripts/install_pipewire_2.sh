sudo apt install pipewire-media-session- wireplumber
systemctl --user --now enable wireplumber.service
sudo apt install pipewire-audio-client-libraries
sudo cp /usr/share/doc/pipewire/examples/alsa.conf.d/99-pipewire-default.conf /etc/alsa/conf.d/
sudo apt install libldacbt-{abr,enc}2 libspa-0.2-bluetooth pulseaudio-module-bluetooth-
