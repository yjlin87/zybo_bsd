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
# Cscope Tutorial
# https://courses.cs.washington.edu/courses/cse451/12sp/tutorials/tutorial_cscope.html

# cscope的选项分析：
# -R     ：表示包含此目录的子目录，而非仅仅是当前目录；
# -b     ：此参数告诉cscope生成数据库后就自动退出；
# -q     ：生成cscope.in.out和cscope.po.out文件，加快cscope的索引速度
#
# 可能会用到的其他选项：
# -k     ：在生成索引时，不搜索/usr/include目录；
# -i     ：如果保存文件列表的文件名不是cscope.files时，需要加此选项告诉cscope到
#          哪里去找源文件列表；
# -I dir ：在-I选项指出的目录中查找头文件
# -u     ：扫描所有文件，重新生成交叉索引文件；
# -C     ：在搜索时忽略大小写；
# -P path：在以相对路径表示的文件前加上的path，这样你不用切换到你数据库文件的目
#          录也可以使用它了。
#
# 说明：要在VIM中使用cscope的功能，需要在编译Vim时选择”+cscope”。Vim的cscope接
# 口会先调用cscope的命令行接口，然后分析其输出结果找到匹配处显示给用户。
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

# Generate cscope.files with a list of files to be scanned.  The following
# command will recursively find all of the .c, .cpp, .h, and .hpp files in your
# current directory and any subdirectories, and store the list of these
# filenames in cscope.files:
find . -name "*.c" -o -name "*.cpp" -o -name "*.h" -o -name "*.hpp" > cscope.files
# Depending on your project, you can use additional file extensions in this
# command, such as .java, .py, .s, etc.

# Generate the Cscope database.
cscope -q -R -b -i cscope.files

print_info "$(date "+%Y.%m.%d-%H.%M.%S") : Finished $script_name"
###############################################################################
# vim: set ts=2 sw=2 tw=0 et :
