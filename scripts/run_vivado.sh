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

if [ -d "${ZN_VIVADO_PROJECT_DIR}" ]; then
  # => This will ensure that the .jou and .log files are placed in the project
  # directory.
  cd ${ZN_VIVADO_PROJECT_DIR}
  # => open the Vivado IDE
  if [ -f "${ZN_VIVADO_PROJECT_DIR}/${ZN_VIVADO_PROJECT_NAME}.xpr" ]; then
    vivado ${ZN_VIVADO_PROJECT_DIR}/${ZN_VIVADO_PROJECT_NAME}.xpr > /dev/null 2>&1 &
  elif [ -f "${ZN_VIVADO_PROJECT_DIR}/create_project.tcl" ]; then
    vivado -source ${ZN_VIVADO_PROJECT_DIR}/create_project.tcl > /dev/null 2>&1 &
  else
    vivado > /dev/null 2>&1 &
  fi
else
  error_exit "未找到Vivado工程目录"
fi

print_info "$(date "+%Y.%m.%d-%H.%M.%S") : Finished $(basename ${BASH_SOURCE})"
###############################################################################
# vim: set ts=2 sw=2 tw=0 et :
