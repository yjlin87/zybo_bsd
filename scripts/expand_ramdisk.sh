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
# 知识一：
# 如果想要查看某个磁盘分区的文件系统类型，可以使用 blkid DEVICE 命令，如：
#
# [root@localhost ~]# blkid /dev/sdb3
# /dev/sdb3: UUID="259690de-5ec4-4356-b590-02ba11c31730" TYPE="ext4"
#
# 这里可以看到/dev/sdb3这个设备的UUID号和文件系统类型。之所以要为磁盘分区生成
# UUID （全局唯一识别标识），是因为在实际生产环境中，一台服务器上可以挂载的磁盘
# 分区可以达到成千上万台，故需要使用UUID对其进行区分。
#
# 知识二：
# 所谓挂载，就是将某个磁盘分区和一个目录建立关联关系的过程。挂载使用的命令为
# mount，其格式为：
#
# mount [-t fstype] DEVICE MOUNT_POINT
#
# mount [-t fstype] LABEL=”Volume_label” MOUNT_POINT
#
# mount [-t fstype] UUID=”UUID” MOUNT_POINT
#
# 这里[DEVICE]是要挂载的文件系统，MOUNT_POINT为挂载点，即要挂载的位置。在使用
# mount命令时，通常需要指定所挂载的文件系统的类型。如果不指定，那么mount命令会
# 自动调用blkid命令来判断该文件系统的类型。
#
# 所谓卸载，就是解除某个磁盘分区和目录的关联关系。卸载（拆除关联关系）使用的命
# 令为umont，其格式为：
#
# umount DEVICE
#
# 或者
#
# umount MOUNT_POINT
#
# 拆除关联关系只需要指定一个，或者是设备，或者是挂载点。
###############################################################################
# => Filename of the running script.
script_name="$(basename ${BASH_SOURCE})"
# => Directory containing the running script.
script_dir="$(cd $(dirname ${BASH_SOURCE}) && pwd)"

# => Help information
usage() {
  echo "Purpose: 扩展ramdisk"
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

# => 检查ramdisk.image.gz文件是否存在
if [ ! -f "${ZN_TARGET_DIR}/ramdisk.image.gz" ]; then
  if [ ! -f "${ZN_DOWNLOAD_DIR}/ramdisk.image.gz" ]; then
    error_exit "找不到ramdisk.image.gz"
  else
    cp ${ZN_DOWNLOAD_DIR}/ramdisk.image.gz ${ZN_TARGET_DIR}
  fi
fi

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
# 创建一个临时目录用于存放旧的ramdisk镜像
ramdisk=`mktemp -d ${ZN_TEMP_DIR}/ramdisk.XXXXXX`
# 如果创建成功，则将旧的ramdisk镜像中的东西拷贝到新的ramdisk镜像中
if [ -d ${ramdisk} ];then
  # 创建用于挂载旧的ramdisk镜像的目录
  mkdir -p ${ramdisk}/rootfs
  # 将旧的ramdisk镜像移到临时目录
  mv ${ZN_TARGET_DIR}/ramdisk.image.gz ${ramdisk}
  # 解压旧的ramdisk镜像
  gunzip ${ramdisk}/ramdisk.image.gz
  # 改变旧的ramdisk镜像的访问属性
  chmod u+rwx ${ramdisk}/ramdisk.image
  # 挂载旧的ramdisk镜像
  ${sudo_cmd} mount -o loop ${ramdisk}/ramdisk.image ${ramdisk}/rootfs
  # 将旧的ramdisk镜像中的东西拷贝到新的ramdisk镜像中
  ${sudo_cmd} cp -rf ${ramdisk}/rootfs/* ${ZN_ROOTFS_MOUNT_POINT}
  # Unmount old ramdisk images:
  ${sudo_cmd} umount ${ramdisk}/rootfs
  # 删除临时目录
  rm -rf ${ramdisk}
else
  error_info "无法将旧的ramdisk镜像中的东西拷贝到新的ramdisk镜像中！！！"
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
