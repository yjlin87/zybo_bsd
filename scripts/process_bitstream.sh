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

# => Setting Zynq-7000 Development Environment Variables
if [ -f "${script_dir}/export_xilinx_env.sh" ]; then
  source ${script_dir}/export_xilinx_env.sh
else
  error_exit "无法找到export_xilinx_env.sh脚本."
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
# Description
#
# This example design shows how to program the PL using the following Linux
# instructions and a raw binary bitstream.
#
# Once Linux is booted, mount the SD card and then create a device node for
# the Zynq devcfg block:
#
#     mknod /dev/xdevcfg c 259 0 > /dev/null
#
# Next, use the Linux "cat" command to stream the PL bitstream in the Zynq PL:
#
#     cat <path_to_storage_media>/<pl_bitstream_name>.bit.bin > /dev/xdevcfg
#
# The PL is now programmed.
#
# NOTE:
# In a later version of Linux Kernel the /dev/xdevcfg might be auto generated.
#
# When you encounter "mknod: /dev/xdevcfg: File exists" warning message after
# running the "mknod /dev/xdevcfg c 259 0 > /dev/null" command you can just run
# the next command.

#
# https://www.xilinx.com/support/answers/46913.html
#
# In order to use the Linux driver for devcfg to program the PL, the bitstream
# needs to be converted to a binary.
#
BIF_DIR=${ZN_TARGET_DIR}/all.bif

echo "all:"		                      > ${BIF_DIR}
echo ""			                        >>${BIF_DIR}
echo "{"		                        >>${BIF_DIR}
echo ""			                        >>${BIF_DIR}
echo "${ZN_TARGET_DIR}/system.bit"	>>${BIF_DIR}
echo ""			                        >>${BIF_DIR}
echo "}"		                        >>${BIF_DIR}

#
# Starting from 2014.1 Bootgen has an option called "process_bitstream" and it
# will generate the BIN file which can be used for PL to configure from PS via
# Devcfg.
#
bootgen -image ${ZN_TARGET_DIR}/all.bif -w -process_bitstream bin

# Output:
#
# The file system.bit.bin is generated in the current working directory.


print_info "$(date "+%Y.%m.%d-%H.%M.%S") : Finished $script_name"
###############################################################################
# vim: set ts=2 sw=2 tw=0 et :
