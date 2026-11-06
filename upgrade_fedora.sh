version=45
sudo dnf upgrade --refresh
sudo dnf system-upgrade download --releasever=$version
sudo dnf system-upgrade reboot
