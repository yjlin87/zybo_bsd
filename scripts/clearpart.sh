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
  echo "Purpose: 清除磁盘分区"
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

# # => Root user detection
# if [ `whoami` != root ]; then
#   error_exit "Please run this script as root or using sudo"
# fi
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

# 0. Plug in your SD Card to your Linux machine.

# 1、显示磁盘分区信息
print_info "硬盘分区信息"
lsblk --nodeps
echo ""

# 2、确定SD卡
read -p "请选择磁盘 [hdX|sdX|mmcblkX] 或者输入q退出: " DISK
# 若用户输入的是大写字母，在这里直接转换为小写字母
DISK=`echo ${DISK} | tr '[:upper:]' '[:lower:]'`
# 2.1、用户选择退出程序
if [ ${DISK} = "q" ];then
  exit 0
fi
# 2.2、用户选择的磁盘是系统所在磁盘
if [ ${DISK} = "hda" ] || [ ${DISK} = "sda" ];then
  error_exit "您输入的是系统存放的硬盘，脚本退出!!!"
fi
# 2.3、
if [ ! -b /dev/${DISK} ]; then
  error_exit "输入有误!!!"
fi
# 2.4 The partition name prefix depends on the device name:
# - /dev/sdb -> /dev/sdb1
# - /dev/mmcblk0 -> /dev/mmcblk0p1
if echo ${DISK} | grep -q mmcblk ; then
  PART="p"
else
  PART=""
fi

# 3. 再次确认是否删除分区
print_warning "磁盘 ${DISK} 上的数据即将被删除。"
read -p "是否继续？ [y/n] " choice
case $choice in
  y|Y)
    if [ $( command -v ${sudo_cmd} fdisk ) ]; then
      print_info "删除分区前，磁盘信息："
      ${sudo_cmd} fdisk -l /dev/${DISK}
    fi

    if [ $( command -v ${sudo_cmd} parted) ]; then
      ###
      # 使用parted工具删除分区
      ###
      print_info "正在删除分区..."
      # listing existing partitions:
      for i in $( ${sudo_cmd} parted -s /dev/${DISK} print | awk '/^ / {print $1}')
      do
        # Unmount all existing partitions:
        if [ -n "`df -h | grep /dev/${DISK}${PART}${i}`" ]; then
          ${sudo_cmd} umount /dev/${DISK}${PART}${i}
        fi

        # Remove all existing partitions:
        ${sudo_cmd} parted -s /dev/${DISK} rm ${i}
      done

    else
      ###
      # 使用dd命令删除分区
      # 注意：使用该方法删除分区后，虽然可以通过fdisk看到分区已经删除，但
      # 系统仍然无法更新分区信息，需要拔插SD卡才能解决
      ###
      ${sudo_cmd} dd if=/dev/zero of=/dev/${DISK} bs=512 count=1 conv=notrunc
    fi

    if [ $( command -v ${sudo_cmd} fdisk ) ]; then
      print_info "删除分区后，磁盘信息："
      ${sudo_cmd} fdisk -l /dev/${DISK}
    fi
    ;;
  n|N)
    ;;
  *)
    ;;
esac

print_info "$(date "+%Y.%m.%d-%H.%M.%S") : Finished $script_name"
###############################################################################
# vim: set ts=2 sw=2 tw=0 et :
