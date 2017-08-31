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
# http://antmicro.com/
# https://github.com/kgugala/linux
# http://nanopi.org/NanoPi_Development.html
###############################################################################
# => Version Information
export ZN_VERSION=${ZN_VERSION:-1.0.0}

# => Help information
usage() {
  echo "Purpose: 初始化环境变量"
  echo "Usage: source $script_name"
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

# => Make sure the script is being source'd, not executed.  Otherwise,
# environment variables set here will not stick.
if [ ${BASH_SOURCE[0]} == "$0" ]; then
  error_info "Please execute the script, such as : source `basename "$0"`"
  exit 1;
fi

# => Prevent script from running twice.
if [ "$CROSS_COMPILE" != "" ];then
  error_info "It is already in cross compiling mode."
  return 1;
fi

###############################################################################
print_info "$(date "+%Y.%m.%d-%H.%M.%S") : Starting $(basename ${BASH_SOURCE})"

####===========================================================================
# => 开发流程一：
# Project basic settings
####===========================================================================
# ==> The Board Name
export ZN_BOARD_NAME="zybo"
print_info "板子名称: ${ZN_BOARD_NAME}"

# ==> The Project Name
export ZN_PROJECT_NAME="zybo_bsd"
print_info "项目名称: ${ZN_PROJECT_NAME}"

# ==> The Project Directory
export ZN_PROJECT_DIR="$(cd $(dirname ${BASH_SOURCE}) && pwd)"
print_info "项目目录: ${ZN_PROJECT_DIR}"

# ==> The Scripts Directory
export ZN_SCRIPTS_DIR="${ZN_PROJECT_DIR}/scripts"
if [ "`ls -A ${ZN_SCRIPTS_DIR}`" = "" ]; then
  error_info "脚本目录为空！！！"
else
  export PATH=${ZN_SCRIPTS_DIR}:$PATH
  print_info "脚本目录: ${ZN_SCRIPTS_DIR}"
fi

# ==> 存放开发所需的源代码
export ZN_SOURCES_DIR=${ZN_PROJECT_DIR}/sources

# ==> 存放开发所需的源码包、软件包等
export ZN_DOWNLOAD_DIR=${ZN_PROJECT_DIR}/packages

# ==> Host tools, compiler, utilities
export ZN_TOOLS_DIR=${ZN_PROJECT_DIR}/tools

# ==> The Build Output Directory
export ZN_OUTPUT_DIR=${ZN_PROJECT_DIR}/output

# ==> The Build Target Directory
export ZN_TARGET_DIR=${ZN_OUTPUT_DIR}/target

# ==> The Build Log Directory
export ZN_LOGFILE_DIR=${ZN_OUTPUT_DIR}/logfile

# ==> The Build temp Directory
export ZN_TEMP_DIR=${ZN_OUTPUT_DIR}/temp

# ==> 用于挂载根文件系统
export ZN_ROOTFS_MOUNT_POINT=${ZN_OUTPUT_DIR}/rootfs

# ==> 用烧录 QSPI Flash 的系统镜像
export ZN_QIMG_DIR=${ZN_PROJECT_DIR}/images/qspi_img

# ==> 用烧录 SD Card 的系统镜像
export ZN_SIMG_DIR=${ZN_PROJECT_DIR}/images/sdcard_img

# Invoke a second make in the output directory, passing relevant variables
# check that the output directory actually exists
mkdir -p ${ZN_SOURCES_DIR} ${ZN_DOWNLOAD_DIR} ${ZN_TOOLS_DIR} ${ZN_OUTPUT_DIR} \
  ${ZN_TARGET_DIR} ${ZN_LOGFILE_DIR} ${ZN_TEMP_DIR} ${ZN_ROOTFS_MOUNT_POINT} \
  ${ZN_QIMG_DIR} ${ZN_SIMG_DIR}

####===========================================================================
# => 开发流程二：
# Describe the toolchain for developing an embedded Linux operating system
####===========================================================================
# ==> ARCH指明目标体系架构，即编译好的内核运行在什么平台上，如x86、arm或mips等。
export ARCH=arm

# ==> 设置交叉编译工具
# 其中，CROSS_COMPILE指定使用的交叉编译器的前缀:
export ZN_TOOLCHAIN_PATH=${ZN_TOOLS_DIR}/cross_compiler
if [ -d "${ZN_TOOLCHAIN_PATH}/bin" ]; then
  # 指定交叉编译器
  export PATH=$PATH:${ZN_TOOLCHAIN_PATH}/bin
  ###
  # http://www.wiki.xilinx.com/Install+Xilinx+tools
  ###
  if which arm-linux-gnueabihf-gcc > /dev/null 2>&1 ; then
    # Zynq-7000 (Linaro - hard float)
    export ZN_TOOLCHAIN_PREFIX=arm-linux-gnueabihf
    export CROSS_COMPILE=${ZN_TOOLCHAIN_PREFIX}-
  elif which arm-xilinx-linux-gnueabi-gcc > /dev/null 2>&1 ; then
    # Zynq-7000 (CodeSourcery - soft floatb
    export ZN_TOOLCHAIN_PREFIX=arm-xilinx-linux-gnueabi
    export CROSS_COMPILE=${ZN_TOOLCHAIN_PREFIX}-
  else
    error_info "无法找到交叉编译器!!!"
    return 1;
  fi
else
  error_info "无法找到交叉编译器!!!"
  return 1;
fi

# ==> 并行编译
# Scale the maximum concurrency with the number of CPUs.
# http://www.verydemo.com/demo_c131_i121360.html
NUMBER_THREADS=`cat /proc/cpuinfo | grep "processor" | wc -l`
if [ ${NUMBER_THREADS} -le 8 ] ; then
  export MAKE_JOBS="-j${NUMBER_THREADS}"
  export PARALLEL_MAKE="-j${NUMBER_THREADS}"
else
  export MAKE_JOBS="-j`expr ${NUMBER_THREADS} / 2`"
  export PARALLEL_MAKE="-j`expr ${NUMBER_THREADS} / 2`"
fi

####===========================================================================
# => 开发流程三：
# System Hardware Design
# 1. Configure PS
# 2. Develop RTL/IP
# 3. Add/Integrate IP
# 4. Genrate Bitstream
# 5. Export to SDK
####===========================================================================
# => Current Vivado/LabTool/SDK Version (Example:2016.4).
export VIVADO_VERSION="${VIVADO_VERSION:-2016.4}"
print_info "Vivado工具版本 : ${VIVADO_VERSION}"

# => Set Xilinx installation path (Default: /opt/Xilinx/).
export XILINX="${XILINX:-/mnt/workspace/Xilinx}"
print_info "Vivado工具目录 : ${XILINX}"

# ==> Vivado工程名称（根据项目需求进行修改）
export ZN_VIVADO_PROJECT_NAME="${ZN_PROJECT_NAME}"
print_info "Vivado工程名称 : ${ZN_VIVADO_PROJECT_NAME}"

# ==> Vivado工程路径（根据项目需求进行修改）
export ZN_VIVADO_PROJECT_DIR="${ZN_SOURCES_DIR}/hardware/proj"
print_info "Vivado工程路径 : ${ZN_VIVADO_PROJECT_DIR}"

# ==> SDK工程路径（根据项目需求进行修改）
export ZN_SDK_PROJECT_DIR="${ZN_VIVADO_PROJECT_DIR}/${ZN_VIVADO_PROJECT_NAME}.sdk"
print_info "SDK工程路径 : ${ZN_SDK_PROJECT_DIR}"

# ==> block design name
export ZN_BD_NAME="system";
# ==> Vivado export a hardware description file for use whith the SDK
export ZN_HW_DESC_FILE_DIR="${ZN_SDK_PROJECT_DIR}/${ZN_BD_NAME}_wrapper_hw_platform_0"


####===========================================================================
# => 开发流程四：
# System Software Development
####===========================================================================
# 1. Create the First Stage Boot Loader (FSBL) or U-BOOT spl bootloader
export ZN_FSBL_NAME=zynq_fsbl
export ZN_FSBL_DIR=${ZN_SOURCES_DIR}/zynq_fsbl
# Invoke a second make in the output directory, passing relevant variables
# check that the output directory actually exists
mkdir -p ${ZN_FSBL_DIR}

# 2. Create Device Tree
# ==> DTG
export ZN_DTG_DIR=${ZN_SOURCES_DIR}/dtg
# ==> DTS (Device Tree Source)
export ZN_DTS_NAME="zynq-zybo.dts"
export ZN_DTS_DIR=${ZN_SOURCES_DIR}/dts
# ==> DTB (Device Tree Blob)
export ZN_DTB_NAME="devicetree.dtb"
export ZN_DTB_DIR=${ZN_TARGET_DIR}
# ==> DTC (Device Tree Compiler) {{{
# When enabling verified boot you are going to build device tree files,
# therefore you also must install the device tree compiler.
# 方法一：单独下载dtc源码
# export ZN_DTC_DIR=${ZN_TOOLS_DIR}/dtc
# export PATH=${ZN_DTC_DIR}:$PATH
#
# 方法二：使用内核里的dtc（注：已经将该部分移到Linux小节进行配置）
# export ZN_DTC_DIR=${ZN_KERNEL_DIR}/scripts/dtc
# export PATH=${ZN_DTC_DIR}:$PATH
#
# 方法三： Ubuntu 12.04 LTS (Precise Pangolin) and later provide a version
# which is recent enough:
# sudo apt-get install device-tree-compiler
# }}}
# Invoke a second make in the output directory, passing relevant variables
# check that the output directory actually exists
mkdir -p ${ZN_DTG_DIR} ${ZN_DTS_DIR}

# 3. Build U-Boot
# ssbl : this folder stores all the U-Boot code.
export ZN_UBOOT_DIR=${ZN_SOURCES_DIR}/u-boot
# The uImage target of the Linux kernel compilation needs a recent mkimage tool
# which is actually built during U-Boot compilation as explained further below.
# Ensure that one is included in PATH:
export PATH=${ZN_UBOOT_DIR}/tools:$PATH
# Invoke a second make in the output directory, passing relevant variables
# check that the output directory actually exists
mkdir -p ${ZN_UBOOT_DIR}

# 4. Build Linux
# ==> kernel : this folder stores the object files (not sources) of the kernel
# build process.
export ZN_KERNEL_DIR=${ZN_SOURCES_DIR}/kernel
# ==> modules : this folder stores the user kernel  modules. This is the place
# to create custom kernel modules.  Each module has to be in a subfolder of
# this one.
export ZN_MODULE_DIR=${ZN_SOURCES_DIR}/modules
# ==> 使用内核里的dtc
export ZN_DTC_DIR=${ZN_KERNEL_DIR}/scripts/dtc
export PATH=${ZN_DTC_DIR}:$PATH
# Invoke a second make in the output directory, passing relevant variables
# check that the output directory actually exists
mkdir -p ${ZN_KERNEL_DIR} ${ZN_MODULE_DIR}

# 5. Create RamDisk
# ==> 方法一：使用Xilinx预编译的ramdisk
# ==> 方法二：使用Linaro等
# ==> 方法三：使用Busybox
# Buildroot : Buildroot is a simple, efficient and easy-to-use tool to generate
# embedded Linux systems through cross-compilation.
export ZN_BUILDROOT_DIR=${ZN_SOURCES_DIR}/buildroot
# setup Buildroot download cache directory
export BR2_DL_DIR=${ZN_DOWNLOAD_DIR}/buildroot
# Invoke a second make in the output directory, passing relevant variables
# check that the output directory actually exists
mkdir -p ${ZN_BUILDROOT_DIR} ${BR2_DL_DIR}

####===========================================================================
# => 开发流程四：
# Application Development
# SDK: Build & Compile Application Code
####===========================================================================
export ZN_APPS_DIR=${ZN_SOURCES_DIR}/apps
# Invoke a second make in the output directory, passing relevant variables
# check that the output directory actually exists
mkdir -p ${ZN_APPS_DIR}


print_info "$(date "+%Y.%m.%d-%H.%M.%S") : Finished $(basename ${BASH_SOURCE})"
###############################################################################
# vim: set ts=2 sw=2 tw=0 et :
