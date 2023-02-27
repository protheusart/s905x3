#!/bin/bash

# Instalar las herramientas de compilación necesarias
sudo apt update
sudo apt install -y build-essential git bc libssl-dev device-tree-compiler zip

# Descargar el código fuente de u-boot
git clone https://github.com/hardkernel/u-boot.git -b odroidn2-v2015.01

# Descargar el código fuente del kernel de Linux
git clone https://github.com/hardkernel/linux.git -b odroid-v5.12.y

# Configurar y compilar u-boot
cd u-boot/
make odroid_n2_defconfig
make -j$(nproc)

# Configurar y compilar el kernel de Linux
cd ../linux/
make ARCH=arm64 odroidc4_defconfig
make ARCH=arm64 menuconfig
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- -j$(nproc)
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- modules -j$(nproc)
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- INSTALL_MOD_PATH=./rootfs/ modules_install
mkbootimg --kernel arch/arm64/boot/Image --ramdisk uInitrd --output boot.img

# Copiar los archivos necesarios para la imagen de arranque
mkdir boot
cp arch/arm64/boot/Image boot/
cp arch/arm64/boot/dts/amlogic/*.dtb boot/
cp boot.ini boot/
cp boot.img boot/
cp ../u-boot/u-boot.bin boot/

# Empaquetar la imagen de arranque
sudo apt-get install android-tools-fastboot
cd boot/
zip -r odroid_s905x3_boot.zip *

echo "Proceso de compilación completado."
