set -e
#sudo ppa-purge ppa:pipewire-debian/pipewire-upstream
sudo apt remove pipewire-audio-client-libraries libspa-0.2-bluetooth libspa-0.2-jack
sudo apt install pipewire-media-session wireplumber-
echo "1"
sudo rm -f ~/.config/systemd/user/pipewire-session-manager.service
systemctl --user --now enable pipewire-media-session
systemctl --global --now enable pipewire-media-session
systemctl --user unmask pulseaudio
systemctl --global unmask pulseaudio
echo "2"
systemctl --user --now disable pipewire-pulse.service pipewire-pulse.socket
systemctl --global --now disable pipewire-pulse.service pipewire-pulse.socket
echo "3"
systemctl --user --now enable pulseaudio.service pulseaudio.socket
systemctl --global --now enable pulseaudio.service pulseaudio.socket
echo "end"
