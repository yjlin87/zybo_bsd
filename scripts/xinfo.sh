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
# To get critical install and system information for a given Vivado install
# https://china.xilinx.com/support/answers/55414.html
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

# => This will ensure that the .jou and .log files are placed in the project
# directory.
cd ${ZN_TARGET_DIR}

# => Create a new tcl files.
TCL_FILE="${ZN_TARGET_DIR}/xinfo.tcl"
echo "report_environment -file ${ZN_TARGET_DIR}/xinfo.txt" > ${TCL_FILE}
echo "return 0"                                            >>${TCL_FILE}

# =>
vivado -mode batch -source ${ZN_TARGET_DIR}/xinfo.tcl

print_info "$(date "+%Y.%m.%d-%H.%M.%S") : Finished $(basename ${BASH_SOURCE})"
###############################################################################
# vim: set ts=2 sw=2 tw=0 et :
