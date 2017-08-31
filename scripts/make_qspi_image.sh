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

# => 检查目标文件是否存在
targets=(                        \
  "fsbl.elf"                     \
  "system.bit"                   \
  "u-boot.elf"                   \
  "uImage"                       \
  "devicetree.dtb"               \
  "ramdisk.image.gz"             \
  "uramdisk.image.gz"            \
  )

for target in "${targets[@]}"; do
  if [ ! -f "${ZN_TARGET_DIR}/${target}" ]; then
    print_info "找不到目标文件：${target}."
  fi
done

# => 确定目标路径存在
if [ ! -d "${ZN_QIMG_DIR}" ]; then
    mkdir -p ${ZN_QIMG_DIR}
fi

# => Create a new bif files...
BIF_FILE=${ZN_TARGET_DIR}/qspi_image.bif
#
# 每次都重新生成qspi_image.bif文件，这样，就可以解决手动修改路径的问题。
echo "//arch = zynq; split = false; format = BIN"                 > ${BIF_FILE}
echo "the_ROM_image:"                                             >>${BIF_FILE}
echo "{"                                                          >>${BIF_FILE}
# The files we need are:
# 1. the first stage boot loader
echo "	[bootloader]${ZN_TARGET_DIR}/fsbl.elf"                    >>${BIF_FILE}
# 2. FPGA bit stream
if [ -f "${ZN_TARGET_DIR}/system.bit" ]; then
    echo "	${ZN_TARGET_DIR}/system.bit"                          >>${BIF_FILE}
fi
# 3. Das U-Boot boot loader
echo "	${ZN_TARGET_DIR}/u-boot.elf"                              >>${BIF_FILE}
# 4. Linux kernel with modified header for U-Boot
echo "	[offset = 0x500000]${ZN_TARGET_DIR}/uImage.bin"           >>${BIF_FILE}
# 5. Device tree blob
echo "	[offset = 0xA00000]${ZN_TARGET_DIR}/devicetree.dtb"       >>${BIF_FILE}
# 6. Root filesystem
echo "	[offset = 0xA20000]${ZN_TARGET_DIR}/uramdisk.image.gz"    >>${BIF_FILE}
echo "}"                                                          >>${BIF_FILE}

QSPI_IMAGE_BIN=${ZN_QIMG_DIR}/qspi_image.bin
QSPI_IMAGE_MCS=${ZN_QIMG_DIR}/qspi_image.mcs

QSPI_IMAGE=${QSPI_IMAGE_BIN}

bootgen -image ${BIF_FILE} -o ${QSPI_IMAGE} -w on

# cd ${ZN_TARGET_DIR}
# bootgen -image ${BIF_FILE} -o ${QSPI_IMAGE} -w on -split bin
# cd -

print_info "$(date "+%Y.%m.%d-%H.%M.%S") : Finished $script_name"
###############################################################################
# vim: set ts=2 sw=2 tw=0 et :
