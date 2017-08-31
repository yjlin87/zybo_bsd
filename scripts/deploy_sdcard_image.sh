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
# http://www.wiki.xilinx.com/Build+Kernel#Zynq
###############################################################################
# => Filename of the running script.
script_name="$(basename ${BASH_SOURCE})"
# => Directory containing the running script.
script_dir="$(cd $(dirname ${BASH_SOURCE}) && pwd)"

# => Help information
usage() {
  echo "Purpose: 部署SD卡镜像"
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

# 0. Plug in your SD Card to your Linux machine.

# 1、显示SD卡分区信息
print_info "硬盘分区信息："
lsblk --nodeps
echo ""

# 2、确定SD卡
read -p "请选择磁盘 [hdX|sdX|mmcblkX] 或者输入q退出: " DISK
# 若用户输入的是大写字母，在这里直接转换为小写字母
DISK=`echo ${DISK} | tr '[:upper:]' '[:lower:]'`
# 2.1、用户选择退出程序
if [ ${DISK} = "q" ];then
  exit 0
fi
# 2.2、用户选择的磁盘是系统所在磁盘
if [ ${DISK} = "hda" ] || [ ${DISK} = "sda" ];then
  error_exit "您输入的是系统存放的硬盘，脚本退出!!!"
fi
# 2.3、
if [ ! -b /dev/${DISK} ]; then
  error_exit "输入有误!!!"
fi
# 2.4 The partition name prefix depends on the device name:
# - /dev/sde -> /dev/sde1
# - /dev/mmcblk0 -> /dev/mmcblk0p1
if echo ${DISK} | grep -q mmcblk ; then
  PART="p"
else
  PART=""
fi

# 2.5 启动分区
BOOT_PART=/dev/${DISK}${PART}1

# 2.6 确认是否有启动分区
if [ ! -b ${BOOT_PART} ]; then
  error_exit "请确认是否已经正确分区!!!"
fi

# 2.7 确认启动分区文件系统
if [ "$(df ${BOOT_PART} -T | awk '{print $2}')" == "vfat" ]; then
  error_exit "启动分区未格式化为FAT32!!!"
fi

# 3、卸载启动分区
if [ -n "`df -h | grep ${BOOT_PART}`" ]; then
  ${sudo_cmd} umount ${BOOT_PART}
fi

# 4. 创建一个临时目录并重新挂载启动分区
sdcard=`mktemp -d ${ZN_TEMP_DIR}/sdcard.XXXXXX`
${sudo_cmd} mount -t vfat ${BOOT_PART} ${sdcard}

# 5、清除旧镜像
# 5.1. Generate the boot image BOOT.BIN
${sudo_cmd} rm -rf ${sdcard}/BOOT.bin
# 5.2. uImage: Linux kernel with modified header for U-Boot
${sudo_cmd} rm -rf ${sdcard}/uImage
# 5.3. Device tree blob
${sudo_cmd} rm -rf ${sdcard}/devicetree.dtb
# 5.4. Root filesystem
${sudo_cmd} rm -rf ${sdcard}/uramdisk.image.gz
# 5.5. uEnv.txt: Plain text file to set U-Boot environmental variables to boot from the SD card
${sudo_cmd} rm -rf ${sdcard}/uEnv.txt
# 5.6 fit.itb
${sudo_cmd} rm -rf ${sdcard}/fit.itb

# 6、安装新镜像
${sudo_cmd} cp -r ${ZN_SIMG_DIR}/* ${sdcard}

# 7、Remove microSD/SD card
${sudo_cmd} sync && ${sudo_cmd} umount ${sdcard} &&  rm -rf ${sdcard}

print_info "$(date "+%Y.%m.%d-%H.%M.%S") : Finished $script_name"
###############################################################################
# vim: set ts=2 sw=2 tw=0 et :
