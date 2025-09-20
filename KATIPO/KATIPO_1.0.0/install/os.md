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