# OLD
https://gitee.com/plink718/plink-jetpack/tree/master/flashPatch/36.4/Orin-Nano/Y-C7
mkdir workspace
cd workspace
wget https://developer.nvidia.com/downloads/embedded/l4t/r36_release_v4.0/release/Jetson_Linux_R36.4.0_aarch64.tbz2
wget https://developer.nvidia.com/downloads/embedded/l4t/r36_release_v4.0/release/Tegra_Linux_Sample-Root-Filesystem_R36.4.0_aarch64.tbz2
tar -xf Jetson_Linux_R36.4.0_aarch64.tbz2
tar -xf plink-ai_Y-C7_orin-Nano_R36.4_patch.tbz2
sudo tar -xpf ../../Tegra_Linux_Sample-Root-Filesystem_R36.4.0_aarch64.tbz2 -C Linux_for_Tegra/rootfs/
cd ..
sudo ./tools/l4t_flash_prerequisites.sh
sudo ./apply_binaries.sh
cd workspace/Linux_for_Tegra/
sudo ./flash_y-c7_orin-nano_364.sh


# NEW
Connect flash port (USB-C port on bottom) to host computer, direct connection only.
Shunt RESET port (middle button)
Power on board

wget https://developer.nvidia.com/downloads/embedded/l4t/r36_release_v5.0/release/Jetson_Linux_r36.5.0_aarch64.tbz2
wget https://developer.nvidia.com/downloads/embedded/l4t/r36_release_v5.0/release/Tegra_Linux_Sample-Root-Filesystem_r36.5.0_aarch64.tbz2
wget https://gitee.com/link?target=https%3A%2F%2Fdeveloper.nvidia.com%2Fdownloads%2Fembedded%2Fl4t%2Fr35_release_v5.0%2Fsources%2Fpublic_sources.tbz2

tar xf Jetson_Linux_R36.5.0_aarch64.tbz2
sudo tar xpf Tegra_Linux_Sample-Root-Filesystem_R36.5.0_aarch64.tbz2 -C Linux_for_Tegra/rootfs/
cd Linux_for_Tegra/
sudo ./apply_binaries.sh
sudo ./tools/l4t_flash_prerequisites.sh
cd ..
tar xsf public_sources.tbz2
cd Linux_for_Tegra
sudo ./tools/l4t_create_default_user.sh -u localadmin -p Katipo01! --accept-license
sudo ./tools/kernel_flash/l4t_initrd_flash.sh --external-device nvme0n1p1 -c tools/kernel_flash/flash_l4t_t234_nvme.xml -p "-c bootloader/generic/cfg/flash_t234_qspi.xml" --showlogs --network usb0 jetson-orin-nano-devkit internal




