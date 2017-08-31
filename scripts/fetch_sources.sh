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
#
# Note:
# PetaLinux 2015.4 contains the following build collateral:
# * Linux Kernel Version 4.0 (Git tag: xilinx-v2015.4)
# * U-Boot Version 2015.07 (Git tag: xilinx-v2015.4)
#
###############################################################################
# => Filename of the running script.
script_name="$(basename ${BASH_SOURCE})"
# => Directory containing the running script.
script_dir="$(cd $(dirname ${BASH_SOURCE}) && pwd)"

# => Help information
usage() {
  echo "Purpose: 下载原始的源码"
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

# => 检查下载工具是否可用
if [ $(command -v curl) ]; then
  dl_cmd="curl"
else
  error_exit "未找到curl工具!!!"
fi

# => Getting the U-Boot Source Code
print_info "Getting the U-Boot Source Code..."

# 设置资源属性
ZN_UBOOT_TAG=digilent-v2016.07
ZN_UBOOT_TAR=${ZN_DOWNLOAD_DIR}/u-boot-digilent-${ZN_UBOOT_TAG}.tar.gz
ZN_UBOOT_URL=https://github.com/Digilent/u-boot-digilent/archive/${ZN_UBOOT_TAG}.tar.gz

# 开始下载bootloader源码包
if [ ! -f "${ZN_UBOOT_TAR}" ]; then
  ${dl_cmd} -L ${ZN_UBOOT_URL} -o ${ZN_UBOOT_TAR}
fi

# 如果下载完U-Boot源码，则解压U-Boot
if [ "`ls -A ${ZN_UBOOT_DIR}`" = "" ]; then
  if [ -f "${ZN_UBOOT_TAR}" ]; then
    tar zxf ${ZN_UBOOT_TAR} --strip-components=1 -C ${ZN_UBOOT_DIR}
  else
    error_exit "未找到U-Boot源码包！！！"
  fi
fi

# => The Linux kernel with Xilinx patches and drivers
print_info "Getting the Kernel Source Code..."

# 设置资源属性
ZN_KERNEL_TAG=digilent-v4.4
ZN_KERNEL_TAR=${ZN_DOWNLOAD_DIR}/linux-digilent-${ZN_KERNEL_TAG}.tar.gz
ZN_KERNEL_URL=https://github.com/Digilent/linux-digilent/archive/${ZN_KERNEL_TAG}.tar.gz

# Download Linux Kernel
if [ ! -f "${ZN_KERNEL_TAR}" ]; then
  ${dl_cmd} -L ${ZN_KERNEL_URL} -o ${ZN_KERNEL_TAR}
fi

# Extract Linux Kernel
if [ "`ls -A ${ZN_KERNEL_DIR}`" = "" ]; then
  if [ -f "${ZN_KERNEL_TAR}" ]; then
    tar zxf ${ZN_KERNEL_TAR} --strip-components=1 -C ${ZN_KERNEL_DIR}
  else
    error_exit "未找到kernel源码包！！！"
  fi
fi

# => Device Tree Compiler (required to build U-Boot)
if [ "`ls -A ${ZN_DTC_DIR}`" = "" ]; then
  print_info "Getting the Device Tree Compiler Source Code..."
  git clone https://git.kernel.org/pub/scm/utils/dtc/dtc.git ${ZN_DTC_DIR}
fi

# => Device Tree Generator plugin for xsdk
print_info "Getting the Device Tree Generator Source Code..."

# 设置资源属性
ZN_DTG_TAG=xilinx-v2016.4
ZN_DTG_TAR=${ZN_DOWNLOAD_DIR}/device-tree-xlnx-${ZN_DTG_TAG}.tar.gz
ZN_DTG_URL=https://github.com/Xilinx/device-tree-xlnx/archive/${ZN_DTG_TAG}.tar.gz

# 开始下载device tree源码包
if [ ! -f "${ZN_DTG_TAR}" ]; then
  ${dl_cmd} -L ${ZN_DTG_URL} -o ${ZN_DTG_TAR}
fi

# 如果下载完Device Tree generator源码，则解压Device Tree generator
if [ "`ls -A ${ZN_DTG_DIR}`" = "" ]; then
  if [ -f "${ZN_DTG_TAR}" ]; then
    tar zxf ${ZN_DTG_TAR} --strip-components=1 -C ${ZN_DTG_DIR}
  else
    error_exit "未找到Device Tree Generator源码包！！！"
  fi
fi

# 5. The Linux File System
# 5.1. Using a BusyBox Ramdisk
#
# The BusyBox ramdisk is a very small file system that includes basic
# functionality and runs through RAM.  BusyBox is non-persistent, which means
# it will not save any changes you make during your operating session after you
# power down the ZedBoard.

# 5.1.1. Build Linux for Zynq-7000 AP SoC using Buildroot
#
# http://www.wiki.xilinx.com/Build+Linux+for+Zynq-7000+AP+SoC+using+Buildroot

print_info "Getting the Buildroot Source Code..."

# 设置资源属性
ZN_BUILDROOT_TAG=2017.02.4
ZN_BUILDROOT_TAR=${ZN_DOWNLOAD_DIR}/buildroot-${ZN_BUILDROOT_TAG}.tar.gz

ZN_BUILDROOT_URL=https://buildroot.org/downloads/buildroot-${ZN_BUILDROOT_TAG}.tar.gz
#
# 开始下载BUILDROOT包
if [ ! -f "${ZN_BUILDROOT_TAR}" ]; then
  ${dl_cmd} -L ${ZN_BUILDROOT_URL} -o ${ZN_BUILDROOT_TAR}
fi

# Extract Buildroot
if [ ! -f "${ZN_BUILDROOT_DIR}/Makefile" ]; then
  if [ -f "${ZN_BUILDROOT_TAR}" ]; then
    tar zxf ${ZN_BUILDROOT_TAR} --strip-components=1 -C ${ZN_BUILDROOT_DIR}
  else
    error_exit "未找到BUILDROOT源码包！！！"
  fi
fi

# 5.1.2. Xilinx Prebuilt RootFS
#
# This prebuilt ramdisk uses source code that Xilinx provides online.
# See the Xilinx materials at: http://wiki.xilinx.com/zynq-rootfs for a
# detailed description of the ramdisk and how to create a custom system.

print_info "Getting the Xilinx Prebuilt RootFS..."

# 设置资源属性
ZN_RAMDISK_TAR=${ZN_DOWNLOAD_DIR}/ramdisk.image.gz
ZN_RAMDISK_URL=http://www.wiki.xilinx.com/file/view/arm_ramdisk.image.gz/419243558/arm_ramdisk.image.gz

# 开始下载RAMDISK包
if [ ! -f "${ZN_RAMDISK_TAR}" ]; then
  ${dl_cmd} -L ${ZN_RAMDISK_URL} -o ${ZN_RAMDISK_TAR}
fi

# 5.2. Using a Linaro File System
#
# The Linaro file system is a complete Linux distribution based on Ubuntu.
# Linaro executes from a separate partition on the SD card, and all changes
# made are written to memory. The utility of Linaro is that it will save files
# even after you power down and reboot the ZedBoard.
#
# http://www.wiki.xilinx.com/Ubuntu+on+Zynq


print_info "$(date "+%Y.%m.%d-%H.%M.%S") : Finished $script_name"
###############################################################################
# vim: set ts=2 sw=2 tw=0 et :
