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
  echo "Purpose: 部署Linaro镜像"
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

# 0. Plug in your SD Card to your Linux machine.

# 1、显示SD卡分区信息
print_info "硬盘分区信息："
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
# - /dev/sde -> /dev/sde1
# - /dev/mmcblk0 -> /dev/mmcblk0p1
if echo ${DISK} | grep -q mmcblk ; then
  PART="p"
else
  PART=""
fi

# 3、Unmount any automatically mounted partitions of the sd card.
print_info "Unmounting all existing partitions on the device..."
for i in $(parted -s /dev/$DISK print|awk '/^ / {print $1}')
do
    [ -n "`df -h | grep /dev/${DISK}${PART}${i}`" ] && { umount /dev/${DISK}${PART}${i}; }
done

# 4. 重新分区并格式化
print_warning "All data on ${DISK} now will be destroyed!!!"
read -p "Do you want to continue? [y/n]" choice
case $choice in
    y|Y)
        # 删除原有的所有分区
        for i in $(parted -s /dev/$DISK print|awk '/^ / {print $1}')
        do
            parted -s /dev/$DISK rm ${i}
        done

        # 重新分区
        #create a 100MB ext4 partition
        parted -s /dev/$DISK mkpart primary 0 100MiB
        #create a partition from where we left off to the end of the disk
        parted -s /dev/$DISK mkpart primary 100MiB 100%

        # Format the partition
        mkfs.vfat -F 32 -n BOOT /dev/${DISK}${PART}1
        mkfs.ext4 -T largefile -F -L ROOTFS /dev/${DISK}${PART}2

        # 挂载磁盘分区
        BOOT_PART=/dev/${DISK}${PART}1
        ROOT_PART=/dev/${DISK}${PART}2

        BOOT_MOUNT_POINT=${ZN_SDCARD_MOUNT_POINT}/boot
        ROOT_MOUNT_POINT=${ZN_SDCARD_MOUNT_POINT}/rootfs

        mount ${BOOT_PART} ${BOOT_MOUNT_POINT}
        mount ${ROOT_PART} ${ROOT_MOUNT_POINT}

        # Install Bootloader
        cp ${ZN_SDCARD_IMAGES_DIR}/BOOT.bin       ${BOOT_MOUNT_POINT}
        # Copy Kernel Device Tree Binaries
        cp ${ZN_SDCARD_IMAGES_DIR}/devicetree.dtb ${BOOT_MOUNT_POINT}
        # Copy Kernel Image
        cp ${ZN_SDCARD_IMAGES_DIR}/uImage         ${BOOT_MOUNT_POINT}

        # Plain text file to set U-Boot environmental variables to boot from the SD card
        UENV_TXT=${BOOT_MOUNT_POINT}/uEnv.txt
        # 解决手动修改的问题。
        echo "uenvcmd=run linaro_sdboot"                                                                          > ${UENV_TXT}
        echo ""                                                                                                   >>${UENV_TXT}
        echo "linaro_sdboot=echo Copying Linux from SD to RAM... && \\"                                           >>${UENV_TXT}

        # The files we need are:
        # Linux kernel with modified header for U-Boot
        echo "fatload mmc 0 0x3000000 \${kernel_image} && \\"                                                     >>${UENV_TXT}

        # Device tree blob
        echo "fatload mmc 0 0x2A00000 \${devicetree_image} && \\"                                                 >>${UENV_TXT}

        # Root filesystem
        # 若找到uramdisk.image.gz，则启动基于BusyBox的嵌入式Linux系统
        echo "if fatload mmc 0 0x2000000 \${ramdisk_image}; \\"                                                   >>${UENV_TXT}
        echo "then bootm 0x3000000 0x2000000 0x2A00000; \\"                                                       >>${UENV_TXT}
        # 否则启动Linaro
        echo "else bootm 0x3000000 - 0x2A00000; fi"                                                               >>${UENV_TXT}
        echo ""                                                                                                   >>${UENV_TXT}

        if [ "${ZN_BOARD_NAME}" == "miz702n" ]; then
            echo "bootargs=console=ttyPS0,115200 root=/dev/mmcblk1p2 rw earlyprintk rootfstype=ext4 rootwait" >>${UENV_TXT}
        elif [ "${ZN_BOARD_NAME}" == "zedboard" ]; then
            echo "bootargs=console=ttyPS0,115200 root=/dev/mmcblk0p2 rw earlyprintk rootfstype=ext4 rootwait" >>${UENV_TXT}
        else
            echo "bootargs=console=ttyPS0,115200 root=/dev/mmcblk0p2 rw earlyprintk rootfstype=ext4 rootwait" >>${UENV_TXT}
        fi

        echo ""                                                                                                   >>${UENV_TXT}

        # Creating Linaro Ubuntu Root Filesystem
        # Basic Requirements
        #
        # ARM Cross Compiler – Linaro: http://www.linaro.org
        #     Linaro Toolchain Binaries: http://www.linaro.org/downloads/
        # ARM based rootfs
        #     Debian: https://www.debian.org
        #     Ubuntu: http://www.ubuntu.com
        #
        # Download Linaro Ubtunu ARM rootfs  archive:
        # wget http://releases.linaro.org/ubuntu/images/gnome/15.12/linaro-vivid-gnome-20151215-714.tar.gz

        # Extract the root filesystem onto the SD card.
        printf_info "正在制作文件系统..."
        # Extract the contents of the rootfs directly on to SD media card which is
        # inserted on you linux PC using the below command.
        tar --strip-components=3 -C ${ROOT_MOUNT_POINT} -xzpf   \
            ${ZN_DL_DIR}/linaro-o-ubuntu-desktop-tar-20111219-0.tar.gz \
            binary/boot/filesystem.dir

        # 3.9、Remove microSD/SD card
        sync
        # 方法一：通常，您可以使用 eject <挂载点|设备>命令弹出碟片。
        # eject /dev/${DISK}
        # 方法二：just umount
        umount ${ZN_SDCARD_MOUNT_POINT}/{boot,rootfs}

        ;;

    n|N)
        ;;

    *)
        ;;

esac

print_info "$(date "+%Y.%m.%d-%H.%M.%S") : Finished $script_name"
###############################################################################
# vim: set ts=2 sw=2 tw=0 et :
