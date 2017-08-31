#!/bin/bash -e
###############################################################################
# Copyright (C) 2017 by Yujiang Lin <linyujiang@hotmail.com>
#
# This program is free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# => 参考资料：
#
# => Flash Memory Programmer
#
# Usage:  program_flash   <FLASH OPTIONS>   <CABLE & DEVICE OPTIONS>
#
# [FLASH OPTIONS]:
#   -f <image file>       : Image to be written onto the flash memory
#   -offset <address>     : Offset within the flash memory at which the image
#                           should be written
#   -no_erase             : Do not erase the flash memory before programming
#   -erase_only           : Only erases the flash as per size of the image file
#   -blank_check          : Check if the flash memory is erased
#   -verify               : Check if the flash memory is programmed correctly
#   -fsbl <fsbl file>     : For NAND & NOR flash types only (Zynq only)
#   -erase_sector <size>  : For flashes whose erase sector is other than 64KB
#                           (size in bytes)
#   -flash_type <type>    : Supported flash memory types
#                             For Zynq Devices
#                               1. qspi_single
#                               2. qspi_dual_parallel
#                               3. qspi_dual_stacked
#                               4. nand_8
#                               5. nand_16
#                               6. nor
#                             For Zynq MP Devices
#                               1. qspi_single
#                               2. qspi_dual_parallel
#                               3. qspi_dual_stacked
#                               4. nand_8
#                             For Non-Zynq Devices
#                               Please use the command line option -partlist
#                               to list all the flash types
#   -partlist <bpi|spi> <micron|spansion>
#                         : List all the flash parts for Non-Zynq devices
#                             List all flashes          - program_flash -partlist
#                             List Micron BPI flashes   - program_flash -partlist bpi micron
#                             List Spansion SPI flashes - program_flash -partlist spi spansion
# [CABLE & DEVICE OPTIONS]:
#   -cable type xilinx_tcf esn <cable_esn> url <URL of the TCF agent>
#   -debugdevice deviceNr <jtag chain no>
#
# EXAMPLES:
#  1. Zynq (QSPI Single)
#    program_flash -f BOOT.bin -flash_type qspi_single -blank_check \
#       -verify -cable type xilinx_tcf url tcp:localhost:3121
#
#  2. Zynq (NOR)
#    program_flash -f BOOT.bin -fsbl fsbl.elf -flash_type nor -blank_check \
#       -verify -cable type xilinx_tcf url tcp:localhost:3121
#
#  3. Non-Zynq (BPI)
#    program_flash -f hello.mcs -flash_type 28f00ap30t-bpi-x16 -blank_check \
#       -verify -cable type xilinx_tcf url tcp:localhost:3121
#
#  4. Zynq MP (QSPI Dual Parallel)
#    program_flash -f BOOT.bin -fsbl fsbl.elf -flash_type qspi_dual_parallel \
#    -blank_check -verify -cable type xilinx_tcf url tcp:localhost:3121
###############################################################################
# => Filename of the running script.
script_name="$(basename ${BASH_SOURCE})"
# => Directory containing the running script.
script_dir="$(cd $(dirname ${BASH_SOURCE}) && pwd)"

# => Help information
usage() {
    echo "Purpose: 部署QSPI Flash镜像"
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

# 目标文件
QSPI_IMAGE_BIN=${ZN_QIMG_DIR}/qspi_image.bin
QSPI_IMAGE_MCS=${ZN_QIMG_DIR}/qspi_image.mcs

# 检查目标文件是否存在
if [ -f "${QSPI_IMAGE_MCS}" ]; then
    QSPI_IMAGE=${QSPI_IMAGE_MCS}
elif [ -f "${QSPI_IMAGE_BIN}" ]; then
    QSPI_IMAGE=${QSPI_IMAGE_BIN}
else
    error_exit "未找到相关镜像..."
fi

# 烧录QSPI镜像
program_flash -f ${QSPI_IMAGE} -offset 0 -flash_type qspi_single -cable type \
    xilinx_tcf url TCP:127.0.0.1:3121

print_info "$(date "+%Y.%m.%d-%H.%M.%S") : Finished $script_name"
###############################################################################
# vim: set ts=2 sw=2 tw=0 et :
