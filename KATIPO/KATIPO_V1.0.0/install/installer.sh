sudo apt update
sudo apt upgrade -y
sudo apt install -y nvidia-jetpack
sudo apt install -y curl ca-certificates ufw

sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
sudo usermod -aG docker ${USER}

sudo ufw allow ssh
sudo ufw allow 8002

sudo systemctl set-default multi-user.target 

sudo systemctl restart docker
sudo nvidia-ctk runtime configure --runtime=docker 
sudo systemctl restart docker

git clone https://github.com/myriadrf/LimeSuiteNG
cd LimeSuiteNG
sudo ./install_dependencies.sh
cmake -B build && cd build
make
sudo make install
sudo ldconfig

sudo mv /etc/nvpmodel.conf /etc/nvpmodel_old.conf
sudo cp /etc/nvpmodel/nvpmodel_p3767_0000_super.conf /etc/nvpmodel.conf
sudo /usr/sbin/nvpmodel -m 0 --force