# Configure generic system
sudo apt update
sudo apt upgrade -y

# Install docker
sudo apt install apt-transport-https ca-certificates curl software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

sudo usermod -aG docker $USER
newgrp docker

# Configure Raspberry Pi as an access point
sudo nmcli device wifi hotspot ssid Fenrir password Fenrir01!
sudo nmcli connection modify Hotspot connection.autoconnect yes connection.autoconnect-priority 100

# Install ORBWEAVER
# get the files git or usb, probably usb copy
# docker load -i images/orbweaver_image.tar


# Configure ORBWEAVER
# copy system_config.json into orbweaver/cfg/