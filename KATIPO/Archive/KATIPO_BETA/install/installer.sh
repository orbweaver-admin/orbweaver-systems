sudo apt-get update
sudo apt-get install nvidia-jetpack

sudo nvpmodel -m 0

# DEV
sudo apt install firefox -y
sudo apt install htop -y
sudo apt install git -y
git clone https://github.com/JetsonHacksNano/installVSCode.git
cd installVSCode
sudo ./installVSCode.sh

git clone https://github.com/myriadrf/LimeSuiteNG
cd LimeSuiteNG
# sudo dpkg --configure -a
sudo ./install_dependencies.sh
cmake -B build && cd build
make
sudo make install
sudo ldconfig

sudo apt install pip
sudo pip install cupy

# sudo apt install -y libsoapysdr-dev soapysdr-module-all soapysdr-tools
# sudo apt install python3-soapysdr
