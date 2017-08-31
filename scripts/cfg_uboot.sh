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
# http://www.wiki.xilinx.com/U-boot
# http://www.wiki.xilinx.com/U-Boot+Secondary+Program+Loader
# http://www.wiki.xilinx.com/Debug+U-boot
# http://www.wiki.xilinx.com/Build+U-Boot
# http://www.wiki.xilinx.com/Build+U-Boot#Zynq
# https://www.xilinx.com/video/hardware/debugging-u-boot-with-sdk.html
# https://github.com/Xilinx/u-boot-xlnx
###############################################################################
# => Filename of the running script.
script_name="$(basename ${BASH_SOURCE})"
# => Directory containing the running script.
script_dir="$(cd $(dirname ${BASH_SOURCE}) && pwd)"

# => Help information
usage() {
  echo "Purpose: 配置U-Boot"
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

# => 检查U-Boot源码是否存在
if [ "`ls -A ${ZN_UBOOT_DIR}`" = "" ]; then
  error_exit "未找到U-Boot源码！！！"
else
  cd ${ZN_UBOOT_DIR}
fi

# => Cleaning the U-Boot Sources
print_info "To delete all build products as well as the configuration."
make distclean
if [ $? -ne 0 ]; then
  error_exit "Failed to make distclean."
fi

# => To configure the sources for the intended target.
print_info "Configure U-Boot on the ${ZN_UBOOT_DIR}."
make zynq_zybo_defconfig
if [ $? -ne 0 ]; then
  error_exit "Failed to make zynq_zybo_defconfig."
fi

# => Prepare for compiling the source code
print_info "Prepare for compiling the source code."
make tools
if [ $? -ne 0 ]; then
  error_exit "Failed to make tools."
fi

print_info "$(date "+%Y.%m.%d-%H.%M.%S") : Finished $script_name"
###############################################################################
# vim: set ts=2 sw=2 tw=0 et :
