sudo apt update
sudo apt install -y network-manager unzip util-linux-extra

# Install docker
sudo dpkg -i FENRIR_1.0.0/install/additional/*.deb
sudo usermod -aG docker $USER

# Configure Raspberry Pi as an access point
echo -e "network:\n  version: 2\n  renderer: NetworkManager" | sudo tee /etc/netplan/01-network-manager-all.yaml > /dev/null
sudo rm -f /etc/netplan/50-cloud-init.yaml
sudo netplan apply

# Stop systemd-networkd so it doesn't hold the interfaces away from NetworkManager
sudo systemctl stop systemd-networkd
sudo systemctl disable systemd-networkd

# Restart NetworkManager and explicitly mark wlan0 as managed
sudo systemctl restart NetworkManager
sleep 5
sudo rfkill unblock wifi || true
sudo nmcli device set wlan0 managed yes

# Wait for wlan0 to be managed and ready
for i in $(seq 1 30); do
	WLAN_STATE=$(nmcli -t -f DEVICE,STATE device 2>/dev/null | awk -F: '$1=="wlan0"{print $2}')
	if [ "$WLAN_STATE" = "disconnected" ] || [ "$WLAN_STATE" = "connected" ]; then
		break
	fi
	sleep 2
done

# Bring up the hotspot with retries
HOTSPOT_READY=0
for i in $(seq 1 3); do
	if sudo nmcli device wifi hotspot ssid Fenrir password Fenrir01!; then
		HOTSPOT_READY=1
		break
	fi
	sudo nmcli radio wifi on
	sleep 3
done

# Fallback: if hotspot profile exists, try bringing it up directly
if [ "$HOTSPOT_READY" -ne 1 ] && sudo nmcli -t -f NAME connection show | grep -qx "Hotspot"; then
	sudo nmcli connection up Hotspot && HOTSPOT_READY=1
fi

if [ "$HOTSPOT_READY" -ne 1 ]; then
	echo "ERROR: Failed to create WiFi hotspot on wlan0" >&2
	nmcli device status >&2 || true
	exit 1
fi

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