# Install docker
sudo dpkg -i FENRIR_1.0.0/install/additional/*.deb
sudo usermod -aG docker $USER

# Install ssh-server (CURRENTRLY ONLY ELEMENT REQUIRING INTERNET ACCESS)
sudo apt update
sudo apt install -y openssh-server
sudo systemctl start ssh
sudo systemctl enable ssh

# Configure Raspberry Pi as an access point
sudo nmcli device wifi hotspot ssid Fenrir password Fenrir01!
sudo nmcli connection modify Hotspot connection.autoconnect yes connection.autoconnect-priority 100

# Install ORBWEAVER
cp FENRIR_1.0.0/config/system_config.json orbweaver/cfg/system_config.json
tar -xsvf FENRIR_1.0.0/orbweaver/orbweaver-arm64.tar.gz orbweaver/
docker load -i orbweaver/image/orbweaver.tar
docker compose -f orbweaver/compose.yml -f orbweaver/compose.hardware.yml up -d 
# compose may require updated path, modem was not detected on first few restarts container being restarted fixed it so might not be detecting hardware file

# Disable ModemManager
sudo systemctl stop ModemManager
sudo systemctl disable ModemManager