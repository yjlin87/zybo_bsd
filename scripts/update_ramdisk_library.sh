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
# http://xilinx.wikidot.com/zynq-rootfs
# http://www.wiki.xilinx.com/Build+and+Modify+a+Rootfs
###############################################################################
# => Filename of the running script.
script_name="$(basename ${BASH_SOURCE})"
# => Directory containing the running script.
script_dir="$(cd $(dirname ${BASH_SOURCE}) && pwd)"

# => Help information
usage() {
  echo "Purpose: "
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

# => 检查ramdisk.image.gz文件是否存在
if [ ! -f "${ZN_TARGET_DIR}/ramdisk.image.gz" ]; then
  if [ ! -f "${ZN_DOWNLOAD_DIR}/ramdisk.image.gz" ]; then
    error "找不到ramdisk.image.gz"
  else
    cp ${ZN_DOWNLOAD_DIR}/ramdisk.image.gz ${ZN_TARGET_DIR}
  fi
fi

# Extract the initrd image from the gzip archive.
gunzip ${ZN_TARGET_DIR}/ramdisk.image.gz
# Mount the initrd image.
chmod u+rwx ${ZN_TARGET_DIR}/ramdisk.image
mount -o loop ${ZN_TARGET_DIR}/ramdisk.image ${ZN_ROOTFS_MOUNT_POINT}

###
# Make changes in the mounted filesystem.
###
# => Remover Old Toolchain Library
rm -r ${ZN_ROOTFS_MOUNT_POINT}/lib/*

# => Install New Toolchain Library
# 1. Copy in the supplied libraries:
cp -r ${ZN_TOOLCHAIN_PATH}/arm-xilinx-linux-gnueabi/libc/lib/* ${ZN_ROOTFS_MOUNT_POINT}/lib
# 2. Strip the libraries of debug symbols:
${CROSS_COMPILE}strip ${ZN_ROOTFS_MOUNT_POINT}/lib/*
# 3. Copy in the supplied tools in libc/sbin and libc/usr/bin
# cp -r ${ZN_TOOLCHAIN_PATH}/arm-xilinx-linux-gnueabi/libc/sbin/*    ${ZN_ROOTFS_MOUNT_POINT}/sbin/
# cp -r ${ZN_TOOLCHAIN_PATH}/arm-xilinx-linux-gnueabi/libc/usr/bin/* ${ZN_ROOTFS_MOUNT_POINT}/usr/bin/

# Unmount the initrd image and compress the image.
umount ${ZN_ROOTFS_MOUNT_POINT}
gzip ${ZN_TARGET_DIR}/ramdisk.image
# Wrapping the image with a U-Boot header
mkimage -A arm -T ramdisk -C gzip -d ${ZN_TARGET_DIR}/ramdisk.image.gz \
  ${ZN_TARGET_DIR}/uramdisk.image.gz

print_info "$(date "+%Y.%m.%d-%H.%M.%S") : Finished $script_name"
###############################################################################
# vim: set ts=2 sw=2 tw=0 et :
