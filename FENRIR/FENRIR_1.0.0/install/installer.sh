#!/usr/bin/env bash

# Log all installer output to both terminal and file.
LOG_DIR="$HOME/fenrir_install_logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/install_$(date +%Y%m%d-%H%M%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1
echo "Starting FENRIR install. Log: $LOG_FILE"

sudo apt update
sudo apt install -y network-manager unzip util-linux-extra rfkill

# Install docker
sudo dpkg -i FENRIR_1.0.0/install/additional/*.deb
sudo usermod -aG docker $USER

# Configure Raspberry Pi as an access point
echo -e "network:\n  version: 2\n  renderer: NetworkManager" | sudo tee /etc/netplan/01-network-manager-all.yaml > /dev/null
sudo rm -f /etc/netplan/50-cloud-init.yaml
sudo netplan apply

# Deterministic handoff to NetworkManager after renderer change
sudo systemctl stop systemd-networkd || true
sudo systemctl disable systemd-networkd || true
sudo systemctl restart NetworkManager
sleep 3

if command -v rfkill >/dev/null 2>&1; then
	sudo rfkill unblock wifi || true
fi

sudo nmcli radio wifi on
sudo nmcli device set wlan0 managed yes

# Wait up to 60s for wlan0 to become ready for AP mode
READY=0
for i in $(seq 1 30); do
	WLAN_STATE=$(nmcli -t -f DEVICE,STATE device 2>/dev/null | awk -F: '$1=="wlan0"{print $2}')
	if [ "$WLAN_STATE" = "disconnected" ] || [ "$WLAN_STATE" = "connected" ]; then
		READY=1
		break
	fi
	sleep 2
done

if [ "$READY" -ne 1 ]; then
	echo "ERROR: wlan0 did not become ready for hotspot setup" >&2
	nmcli device status >&2 || true
	exit 1
fi

# Bring up the hotspot.
sudo nmcli device wifi hotspot ssid Fenrir password Fenrir01!
sudo nmcli connection modify Hotspot connection.autoconnect yes connection.autoconnect-priority 100

unzip FENRIR_1.0.0/install/fenrir/fenrir-aarch64.zip
sudo docker load -i fenrir/image/fenrir-aarch64.tar

# Disable ModemManager
sudo systemctl stop ModemManager
sudo systemctl disable ModemManager

sudo ufw allow 8000

echo 'dtparam=rtc=bbat_vchg=3000000' | sudo tee -a /boot/firmware/config.txt

rm -rf FENRIR_1.0.0
rm FENRIR_1.0.0.tar

sudo docker compose --profile release-aarch64 -f fenrir/compose.yml up -d