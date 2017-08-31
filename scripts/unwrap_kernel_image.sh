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

if [ -f "${ZN_TARGET_DIR}/uramdisk.image.gz" ]; then
  # => Check File Type
  print_info "Check File Type ..."
  file ${ZN_TARGET_DIR}/uramdisk.image.gz
  # uramdisk.image.gz: u-boot legacy uImage, , Linux/ARM, RAMDisk Image (gzip),
  # 4815459 bytes, Fri May 30 01:52:10 2014, Load Address: 0x00000000, Entry
  # Point: 0x00000000, Header CRC: 0x265787C1, Data CRC: 0x2CA30F4B

  # => Unwrap the image with the u-boot header
  print_info "Unwrap the image with the u-boot header..."
  dd if=${ZN_TARGET_DIR}/uramdisk.image.gz of=${ZN_TARGET_DIR}/ramdisk.image.gz bs=64 skip=1

  # => Check File Type
  print_info "Check File Type ..."
  file ${ZN_TARGET_DIR}/ramdisk.image.gz
  # ramdisk.image.gz: gzip compressed data, was "rootfs.cpio", from Unix, last
  # modified: Fri May 30 01:52:08 2014

else
  error_exit "未找到uramdisk.image.gz文件"
fi

print_info "$(date "+%Y.%m.%d-%H.%M.%S") : Finished $script_name"
###############################################################################
# vim: set ts=2 sw=2 tw=0 et :
