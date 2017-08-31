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
# How do I find out which libraries are required to run Vivado tools in Linux?
# https://www.xilinx.com/support/answers/66184.html
#
# To check which required library or libraries are missing on a Linux system,
# you can use the ldd command recursively.  A Perl script that handles the
# recursive ldd search, named ldd-recursive.pl is available at:
# http://sourceforge.net/projects/recursive-ldd/
#
# To use the script:
# 1) Perl must be installed on your system.
#
# 2) For valid switches and syntax:
#    perl ldd-recursive.pl
#
# 3) The Vivado Environment needs to be setup beforehand (settings64.sh needs
# to be sourced).
#
# 4) Execute the script as follows to get a unique list (no duplicates) of the
# required libraries needed:
#
# perl ldd-recursive.pl /<vivado_install_location>/<vivado_version>/bin/unwrapped/lnx64.o/vivado -uniq
#
# NOTE: This script was not created or supported by Xilinx and therefore any
# issues or questions related to running the script should not be directed to
# Xilinx.
###############################################################################
# => Filename of the running script.
script_name="$(basename ${BASH_SOURCE})"
# => Directory containing the running script.
script_dir="$(cd $(dirname ${BASH_SOURCE}) && pwd)"

# => Help information
usage() {
  echo "Purpose: 检查Vivado开发套件是否缺少依赖包"
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

# => Perl must be installed on your system.
if [ ! $( command -v perl ) ]; then
  error_exit "Can not find Perl executable."
fi

# => Perl脚本必须存在
if [ ! -f "${script_dir}/ldd-recursive.pl" ]; then
  error_exit "Can not find Perl script."
fi

# => Vivado Design Suite
if [ -d "${XILINX_VIVADO}" ]; then
  print_info "Vivado requires libraries:"
  perl ${script_dir}/ldd-recursive.pl ${XILINX_VIVADO}/bin/unwrapped/lnx64.o/vivado -uniq
  printf "\n"
fi

# => Xilinx Software Development Kit (XSDK):
if [ -d "${XILINX_SDK}" ]; then
  print_info "SDK requires libraries:"
  perl ${script_dir}/ldd-recursive.pl ${XILINX_SDK}/bin/unwrapped/lnx64.o/rdi_xsdk -uniq
  printf "\n"
fi

# => High-Level Synthesis (HLS)
if [ -d "${XILINX_VIVADO_HLS}" ]; then
  print_info "Vivado HLS requires libraries:"
  perl ${script_dir}/ldd-recursive.pl ${XILINX_VIVADO_HLS}/bin/unwrapped/lnx64.o/vivado_hls -uniq
  printf "\n"
fi

# => DocNav
if [ -d "${XILINX_DOCNAV}" ]; then
  # Note: DocNav is a 32-bit executable and requires the libraries listed above to run.
  print_info "DocNav requires libraries:"
  perl ${script_dir}/ldd-recursive.pl ${XILINX_DOCNAV}/docnav -uniq
  printf "\n"
fi

print_info "$(date "+%Y.%m.%d-%H.%M.%S") : Finished $(basename ${BASH_SOURCE})"
###############################################################################
# vim: set ts=2 sw=2 tw=0 et :
