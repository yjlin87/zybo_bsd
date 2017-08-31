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
# https://builder.timesys.com/docs/gsg/zc706
###############################################################################
# => Filename of the running script.
script_name="$(basename ${BASH_SOURCE})"
# => Directory containing the running script.
script_dir="$(cd $(dirname ${BASH_SOURCE}) && pwd)"

# => Help information
usage() {
  echo "Purpose: 打开串口终端"
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

# The Zynq uses a USB serial debug port to communicate with the host machine.
# The commands discussed in this section are meant to be performed by a
# privileged user account. This requires the root login or prepending each
# command with sudo.
#
# on SUSE based systems (like SLES and Leap), you can run:
if grep "openSUSE Leap 42.1" /etc/issue >/dev/null 2>&1; then

  # Using GNU Screen
  # Note:-You can also use minicom, but screen is much easier to use!  Also in
  # most cases the virtual USB serial port is ttyUSB0.
  #
  # To quickly connect to a board using Gnu Screen, execute the following:
  if [ $( command -v screen) ]; then
    if [ -c /dev/ttyUSB1 ]; then
      ${sudo_cmd} screen /dev/ttyUSB1 115200 8n1
    else
      echo "The /dev/ttyUSB1 is not exist!" && exit
    fi
  else
    echo "The screen is not exist!" && exit
  fi
  # For more information about using screen, please consult the man page, or view
  # the manual online at http://www.gnu.org/software/screen/manual/screen.html

else
  echo "不支持当前系统." && exit

fi

print_info "$(date "+%Y.%m.%d-%H.%M.%S") : Finished $script_name"
###############################################################################
# vim: set ts=2 sw=2 tw=0 et :
