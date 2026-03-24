sudo apt update
sudo apt install -y network-manager unzip util-linux-extra rfkill

# Install docker
sudo dpkg -i FENRIR_1.0.0/install/additional/*.deb
sudo usermod -aG docker $USER

# Configure Raspberry Pi as an access point
echo -e "network:\n  version: 2\n  renderer: NetworkManager" | sudo tee /etc/netplan/01-network-manager-all.yaml > /dev/null
sudo rm -f /etc/netplan/50-cloud-init.yaml
sudo netplan apply

# # Stop systemd-networkd so it doesn't hold the interfaces away from NetworkManager
# sudo systemctl stop systemd-networkd || true
# sudo systemctl disable systemd-networkd || true

# # Restart NetworkManager after renderer change
# sudo systemctl restart NetworkManager
# sleep 5
# Bring up the hotspot.
# If this fails the first time after changing netplan renderer, reboot once and rerun this script.
sudo nmcli device wifi hotspot ssid Fenrir password Fenrir01!
sudo nmcli connection modify Hotspot connection.autoconnect yes connection.autoconnect-priority 100

unzip FENRIR_1.0.0/install/fenrir/fenrir-aarch64.zip
docker load -i fenrir/image/fenrir-aarch64.tar

# Disable ModemManager
sudo systemctl stop ModemManager
sudo systemctl disable ModemManager

sudo ufw allow 8000

echo 'dtparam=rtc=bbat_vchg=3000000' | sudo tee -a /boot/firmware/config.txt

rm -rf FENRIR_1.0.0
rm FENRIR_1.0.0.tar

docker compose --profile production-aarch64 -f fenrir/compose.yml up -d