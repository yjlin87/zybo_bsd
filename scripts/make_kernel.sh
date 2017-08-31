#!/bin/bash -e
###############################################################################
# Copyright (C) 2017 by Yujiang Lin <linyujiang@hotmail.com>
#
# This program is free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# 参考资料：
# https://kernelnewbies.org/KernelBuild
# http://www.wiki.xilinx.com/Build+Kernel
# http://www.wiki.xilinx.com/Build+Kernel#Zynq
# http://processors.wiki.ti.com/index.php/Linux_Kernel_Users_Guide
###############################################################################
# => Filename of the running script.
script_name="$(basename ${BASH_SOURCE})"
# => Directory containing the running script.
script_dir="$(cd $(dirname ${BASH_SOURCE}) && pwd)"

# => Help information
usage() {
  echo "Purpose: 编译、安装Linux内核、设备树、内核模块"
  echo "Usage: $script_name [option]"
  echo "options:"
  echo "--help: Display this help message"
  exit 0;
}
expr "$*" : ".*--help" > /dev/null && usage

# => Local functions
print_warning() {
  local msg="$1"
  printf "\033[33m[WARNING] \033[0m";
  printf "$msg\n";
}

print_info() {
  local msg="$1"
  printf "\033[32m[INFO] \033[0m";
  printf "$msg\n";
}

error_exit() {
  local msg="$1"
  printf "\033[31m[ERROR] \033[0m";
  printf "$msg\n";
  exit 1;
}

error_info() {
  local msg="$1"
  printf "\033[31m[ERROR] \033[0m";
  printf "$msg\n";
}

# => 初始化环境变量
if [ ! "${CROSS_COMPILE}" ]; then
  if [ -f "$(dirname ${script_dir})/setup_env.sh" ]; then
    source $(dirname ${script_dir})/setup_env.sh
  else
    error_exit "无法找到setup_env.sh脚本."
  fi
fi

# => Root user detection
if [ $(echo "$UID") = "0" ]; then
  sudo_cmd=''
else
  sudo_cmd='sudo'
fi

# => Redirect output to log from inside script
if [ "${ZN_LOGFILE_DIR}" != "" ]; then
  log_file=${ZN_LOGFILE_DIR}/${script_name%.*}.log
  exec &> >(tee "$log_file")
fi

###############################################################################
print_info "$(date "+%Y.%m.%d-%H.%M.%S") : Starting $script_name"

# => 检查kernel源码是否存在
if [ "`ls -A ${ZN_KERNEL_DIR}`" = "" ]; then
  error_exit "未找到kernel源码！！！"
else
  cd ${ZN_KERNEL_DIR}
fi

# => 检查ramdisk.image.gz文件是否存在
if [ ! -f "${ZN_TARGET_DIR}/ramdisk.image.gz" ]; then
  if [ ! -f "${ZN_DOWNLOAD_DIR}/ramdisk.image.gz" ]; then
    error_exit "找不到ramdisk.image.gz"
  else
    cp ${ZN_DOWNLOAD_DIR}/ramdisk.image.gz ${ZN_TARGET_DIR}
  fi
fi

# Compiling the Kernel
print_info "Building the kernel image on the ${ZN_KERNEL_DIR}."
make ${MAKE_JOBS} ARCH=arm CROSS_COMPILE=${ZN_TOOLCHAIN_PREFIX}- UIMAGE_LOADADDR=0x8000 uImage
if [ $? -eq 0 ]; then
  print_info "Installing the Kernel Image..."
  cp -a ${ZN_KERNEL_DIR}/arch/arm/boot/zImage ${ZN_TARGET_DIR}
  cp -a ${ZN_KERNEL_DIR}/arch/arm/boot/uImage ${ZN_TARGET_DIR}
  cp -a ${ZN_KERNEL_DIR}/arch/arm/boot/uImage ${ZN_TARGET_DIR}/uImage.bin
else
  error_exit "Kernel Image - Build Failed!!!"
fi

# Compiling the Device Tree Binaries
# 方法一：若设备树放在Kernel目录下，可以使用方法
# print_info "Building the Device Tree Binaries on the ${ZN_KERNEL_DIR}."
# make ARCH=arm CROSS_COMPILE=${ZN_TOOLCHAIN_PREFIX}- dtbs
# if [ $? -eq 0 ]; then
#   print_info "Installing the Device Tree Binaries..."
#   cp -a ${ZN_KERNEL_DIR}/arch/arm/boot/dts/${ZN_DTB_NAME} ${ZN_TARGET_DIR}/devicetree.dtb
# else
#   error_exit "Device Tree Binaries - Build Failed!!!"
# fi
# 方法二：比较通用的方法
print_info "Building the Device Tree Binaries on the ${ZN_DTS_DIR}."
${ZN_DTC_DIR}/dtc -I dts -O dtb -o ${ZN_DTB_DIR}/${ZN_DTB_NAME} \
  ${ZN_DTS_DIR}/${ZN_DTS_NAME}
if [ $? -eq 0 ]; then
    print_info "The Device Tree - Build OK!!!"
else
    error_exit "The Device Tree - Build Failed!!!"
fi


# Compiling the Kernel Modules
print_info "Building the Kernel Modules on the ${ZN_KERNEL_DIR}"
make ${MAKE_JOBS} ARCH=arm CROSS_COMPILE=${ZN_TOOLCHAIN_PREFIX}- modules
if [ $? -eq 0 ]; then
  print_info "Installing the Kernel Modules..."
  # 预处理。。。
  gunzip ${ZN_TARGET_DIR}/ramdisk.image.gz
  chmod u+rwx ${ZN_TARGET_DIR}/ramdisk.image
  ${sudo_cmd} mount -o loop ${ZN_TARGET_DIR}/ramdisk.image ${ZN_ROOTFS_MOUNT_POINT}
  ${sudo_cmd} rm -rf ${ZN_ROOTFS_MOUNT_POINT}/lib/modules/

  # 安装中。。。
  ${sudo_cmd} make ${MAKE_JOBS} ARCH=arm INSTALL_MOD_PATH=${ZN_ROOTFS_MOUNT_POINT} modules_install
  if [ $? -eq 0 ]; then
    print_info "The Kernel Modules - Install OK!!!"
  else
    error_exit "The Kernel Modules - Install Failed!!!"
  fi

  # 后处理。。。
  ${sudo_cmd} umount ${ZN_ROOTFS_MOUNT_POINT}
  gzip ${ZN_TARGET_DIR}/ramdisk.image

  # --- mkimage ---
  if [ ! $( which mkimage ) ]; then
    error_exit "Missing mkimage command."
  else
    mkimage -A arm -T ramdisk -C gzip -d ${ZN_TARGET_DIR}/ramdisk.image.gz \
      ${ZN_TARGET_DIR}/uramdisk.image.gz
  fi

else
  error_exit "Kernel - Build Failed!!!"
fi

###############################################################################
# => Install your custom kernel
# The kernel image and the device tree binary are installed in the boot
# partition whereas the kernel modules, the device firmware and the C header
# files are copied to the root file system. If you are running different Linux
# installations on different partitions of your eMMC or SD storage device with
# the same kernel image you need to install the kernel modules (e.g. by sudo
# make modules_install INSTALL_MOD_PATH=...), the device firmware (sudo make
# firmware_install INSTALL_FW_PATH=...) and the C header files on each of this
# partitions. You can get a list of all make targets and parameters by typing
# make help.
###############################################################################
# sudo cp ./arch/arm/boot/*(u)*(z)Image ./arch/arm/boot/dts/*.dtb <boot-partition>
# sudo make headers_install INSTALL_HDR_PATH=...
# sudo make modules_install INSTALL_MOD_PATH=...
# sudo make firmware_install INSTALL_FW_PATH=...

print_info "$(date "+%Y.%m.%d-%H.%M.%S") : Finished $script_name"
###############################################################################
# vim: set ts=2 sw=2 tw=0 et :
