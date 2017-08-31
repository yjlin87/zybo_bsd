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

export LANG=C
export LC_ALL=C
[ -n "$ZN_PROJECT_DIR" ] && cd $ZN_PROJECT_DIR

try_version() {
  [ -f version ] || return 1
  REV="$(cat version)"
  [ -n "$REV" ]
}

try_svn() {
  [ -d .svn ] || return 1
  REV="$(svn info | awk '/^Last Changed Rev:/ { print $4 }')"
  REV="${REV:+r$REV}"
  [ -n "$REV" ]
}

try_git() {
  git rev-parse --git-dir >/dev/null 2>&1 || return 1
  REV="$(git describe --tags | sed "s/trunk-\([0-9]*\)-.*/\1/g")"
  REV="$((REV+12009))"
  [ -n "$REV" ]
}

try_hg() {
  [ -d .hg ] || return 1
  REV="$(hg log -r-1 --template '{desc}' | awk '{print $2}' | sed 's/\].*//')"
  REV="${REV:+$REV}"
  [ -n "$REV" ]
}

try_version || try_git || try_hg || REV="unknown"
echo "$REV"

print_info "$(date "+%Y.%m.%d-%H.%M.%S") : Finished $script_name"
###############################################################################
# vim: set ts=2 sw=2 tw=0 et :
