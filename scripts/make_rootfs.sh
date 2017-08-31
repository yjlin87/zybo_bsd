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
  echo "Purpose: 编译、安装Buildroot"
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

# => 检查buildroot源码是否存在
if [ "`ls -A ${ZN_BUILDROOT_DIR}`" = "" ]; then
  error_exit "未找到Buildroot源码！！！"
else
  cd ${ZN_BUILDROOT_DIR}
fi

# => 编译根文件系统
make
if [ "$?" -ne 0 ]; then
  error_exit "根文件系统编译失败！！！"
fi

# => Housekeeping...
${sudo_cmd} rm -rf ${ZN_ROOTFS_MOUNT_POINT}/*
${sudo_cmd} rm -f  ${ZN_TARGET_DIR}/ramdisk.image
${sudo_cmd} rm -f  ${ZN_TARGET_DIR}/ramdisk.image.gz

# => 1. Create an empty ramdisk image
####################################
# 8M    16M    32M    64M
# 8192  16384  32768  65536
####################################
# 创建一个64MB大小的ramdisk镜像，此时ramdisk.image文件里面没有任何目录，可以通
# 过hexdump命令看到里面是全0.
dd if=/dev/zero of=${ZN_TARGET_DIR}/ramdisk.image bs=1024 count=65536

# => 2. create an ext2/ext3/ext4 filesystem
# 此时通过hexdump命令可以看到里面已经有了一些数据
${sudo_cmd} mke2fs -t ext4 -F ${ZN_TARGET_DIR}/ramdisk.image -L "ramdisk" -b 1024 -m 0

# => 3. 禁用时间检查
# tune2fs是调整和查看ext2/ext3文件系统的文件系统参数，Windows下面如果出现意外断
# 电死机情况，下次开机一般都会出现系统自检。Linux系统下面也有文件系统自检，而且
# 是可以通过tune2fs命令，自行定义自检周期及方式。
${sudo_cmd} tune2fs ${ZN_TARGET_DIR}/ramdisk.image -i 0

# => 4. 改变ramdisk.image的访问属性
chmod a+rwx ${ZN_TARGET_DIR}/ramdisk.image

# => 5. 将ramdisk.image挂载到rootfs目录
${sudo_cmd} mount -o loop ${ZN_TARGET_DIR}/ramdisk.image ${ZN_ROOTFS_MOUNT_POINT}

# => 6. Make changes in the mounted filesystem.
if [ ! -f "${ZN_BUILDROOT_DIR}/output/images/rootfs.tar" ]; then
  error_exit "找不到rootfs.tar"
else
  ${sudo_cmd} tar xvf ${ZN_BUILDROOT_DIR}/output/images/rootfs.tar -C ${ZN_ROOTFS_MOUNT_POINT}
fi

# => 7. Unmount ramdisk images:
${sudo_cmd} umount ${ZN_ROOTFS_MOUNT_POINT}

# => 8. Compress ramdisk image
gzip ${ZN_TARGET_DIR}/ramdisk.image

# => 9. Wrapping the image with a U-Boot header
mkimage -A arm -T ramdisk -C gzip -d ${ZN_TARGET_DIR}/ramdisk.image.gz \
  ${ZN_TARGET_DIR}/uramdisk.image.gz

print_info "$(date "+%Y.%m.%d-%H.%M.%S") : Finished $script_name"
###############################################################################
# vim: set ts=2 sw=2 tw=0 et :
