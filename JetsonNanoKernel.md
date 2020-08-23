# 1. Download compilers for arm
```
wget http://releases.linaro.org/components/toolchain/binaries/7.3-2018.05/aarch64-linux-gnu/gcc-linaro-7.3.1-2018.05-x86_64_aarch64-linux-gnu.tar.xz

mkdir $HOME/src/jetsonnano/l4t-gcc
pushd $HOME/src/jetsonnano/l4t-gcc
tar xf ../gcc-linaro-7.3.1-2018.05-x86_64_aarch64-linux-gnu.tar.xz
popd
```

# 2. Download kernel source
```
wget https://developer.nvidia.com/embedded/dlc/r32-3-1_Release_v1.0/Sources/T210/public_sources.tbz2

tar -xvf public_sources.tbz2
pushd Linux_for_Tegra/source/public
JETSON_NANO_KERNEL_SOURCE=$(pwd)
tar -xf kernel_src.tbz2
popd
```

# 3. Change code if you want to add more modules

``
wget -O tc358743_nano.zip https://gist.github.com/nyacg/becd94a029355825a05f633f38a25b46/archive/74d4bebf7ab3fa7b98fb1007cf8d2936e45db553.zip

unzip tc358743_nano.zip
mv becd94a029355825a05f633f38a25b46-74d4bebf7ab3fa7b98fb1007cf8d2936e45db553 src_tc358743
```
Follow the guide to change some file.

# 4. Compile kernel & dtb

```
cd $JETSON_NANO_KERNEL_SOURCE
TOOLCHAIN_PREFIX=$HOME/src/jetsonnano/l4t-gcc/gcc-linaro-7.3.1-2018.05-x86_64_aarch64-linux-gnu/bin/aarch64-linux-gnu-
TEGRA_KERNEL_OUT=$JETSON_NANO_KERNEL_SOURCE/build
KERNEL_MODULES_OUT=$JETSON_NANO_KERNEL_SOURCE/modules
make -C kernel/kernel-4.9/ ARCH=arm64 O=$TEGRA_KERNEL_OUT LOCALVERSION=-tegra CROSS_COMPILE=${TOOLCHAIN_PREFIX} tegra_defconfig
make -C kernel/kernel-4.9/ ARCH=arm64 O=$TEGRA_KERNEL_OUT LOCALVERSION=-tegra CROSS_COMPILE=${TOOLCHAIN_PREFIX} --output-sync=target zImage
make -C kernel/kernel-4.9/ ARCH=arm64 O=$TEGRA_KERNEL_OUT LOCALVERSION=-tegra CROSS_COMPILE=${TOOLCHAIN_PREFIX} --output-sync=target modules
make -C kernel/kernel-4.9/ ARCH=arm64 O=$TEGRA_KERNEL_OUT LOCALVERSION=-tegra CROSS_COMPILE=${TOOLCHAIN_PREFIX} --output-sync=target dtbs
make -C kernel/kernel-4.9/ ARCH=arm64 O=$TEGRA_KERNEL_OUT LOCALVERSION=-tegra INSTALL_MOD_PATH=$KERNEL_MODULES_OUT modules_install
```

# 5. copy your kernel image & dtb to jetson
Edit /boot/extlinux/extlinux.conf file to change your boot options

# Reference
https://developer.ridgerun.com/wiki/index.php?title=Jetson_Nano/Development/Building_the_Kernel_from_Source

https://gist.github.com/nyacg/becd94a029355825a05f633f38a25b46