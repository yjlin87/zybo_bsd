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
  echo "Purpose: 制作SD卡镜像"
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
if [ ! -d "${ZN_SIMG_DIR}" ]; then
  mkdir -p ${ZN_SIMG_DIR}
fi

# => 清空旧文件
if [ "`ls -A ${ZN_SIMG_DIR}`" != "" ]; then
  # 1. the boot image: BOOT.BIN
  rm -f ${ZN_SIMG_DIR}/BOOT.bin
  # 2. the FIT image: fit.itb
  rm -f ${ZN_SIMG_DIR}/fit.itb
fi

# => 1. Generate the boot image BOOT.BIN
# This consists of the FSBL (first stage boot loader), the system.bit
# configuration bitstream, and the U-boot Linux boot-loader u-boot.elf.
# 1.1 Create a new bif files...
BIF_FILE=${ZN_TARGET_DIR}/sd_image.bif
#
# 每次都重新生成sd_image.bif文件，这样，就可以解决手动修改路径的问题。
echo "//arch = zynq; split = false; format = BIN" > ${BIF_FILE}
echo "the_ROM_image:"                             >>${BIF_FILE}
echo "{"                                          >>${BIF_FILE}
# 1.1.1 the first stage boot loader
echo "  [bootloader]${ZN_TARGET_DIR}/fsbl.elf"    >>${BIF_FILE}
# 1.1.2 FPGA bit stream
if [ -f "${ZN_TARGET_DIR}/system.bit" ]; then
  echo "  ${ZN_TARGET_DIR}/system.bit"            >>${BIF_FILE}
fi
# 1.1.3 u-boot.elf: Das U-Boot boot loader
echo "  ${ZN_TARGET_DIR}/u-boot.elf"              >>${BIF_FILE}
echo "}"                                          >>${BIF_FILE}
# 1.2
bootgen -image ${BIF_FILE} -o ${ZN_SIMG_DIR}/BOOT.bin -w on

###
# U-Boot and Flat Image Tree (FIT)
###
# U-Boot firmware supports the booting of images in the Flattened Image
# Tree (FIT) format.  The FIT format uses a device tree structure to
# describe a kernel image, device tree blob, ramdisk, etc.  This script
# creates an Image Tree Source (.its file) which can be passed to the
# 'mkimage' utility to generate an Image Tree Blob (.itb file).  The .itb
# file can then be booted by U-Boot (or other bootloaders which support
# FIT images).  See doc/uImage.FIT/howto.txt in U-Boot source code for
# additional information on FIT images.

echo "/dts-v1/;

/ {
        description = \"Kernel, ramdisk and FDT blob\";
        #address-cells = <1>;

        images {
                kernel@1 {
                        description = \"Linux Kernel 4.0.0\";
                        data = /incbin/(\"zImage\");
                        type = \"kernel\";
                        arch = \"arm\";
                        os = \"linux\";
                        compression = \"none\";
                        load = <0x00008000>;
                        entry = <0x00008000>;
                        hash@1 {
                            algo = \"crc32\";
                        };
                        hash@2 {
                            algo = \"sha1\";
                        };
                        hash@3 {
                            algo = \"md5\";
                        };
                };

                ramdisk@1 {
                        description = \"Ramdisk for Zynq-7000\";
                        data = /incbin/(\"ramdisk.image.gz\");
                        type = \"ramdisk\";
                        arch = \"arm\";
                        os = \"linux\";
                        compression = \"gzip\";
                        load = <0x00000000>;
                        entry = <0x00000000>;
                        hash@1 {
                            algo = \"crc32\";
                        };
                        hash@2 {
                            algo = \"sha1\";
                        };
                        hash@3 {
                            algo = \"md5\";
                        };
                };

                fdt@1 {
                        description = \"FDT for ZYBO\";
                        data = /incbin/(\"devicetree.dtb\");
                        type = \"flat_dt\";
                        arch = \"arm\";
                        compression = \"none\";
                        hash@1 {
                            algo = \"crc32\";
                        };
                        hash@2 {
                            algo = \"sha1\";
                        };
                        hash@3 {
                            algo = \"md5\";
                        };
                };

        };

        configurations {
                default = \"config@1\";

                config@1 {
                        description = \"ZYBO Configuration\";
                        kernel = \"kernel@1\";
                        ramdisk = \"ramdisk@1\";
                        fdt = \"fdt@1\";
                };
        };
};"  > ${ZN_TARGET_DIR}/fit.its

# make a FIT image
mkimage -f ${ZN_TARGET_DIR}/fit.its ${ZN_SIMG_DIR}/fit.itb

print_info "$(date "+%Y.%m.%d-%H.%M.%S") : Finished $script_name"
###############################################################################
# vim: set ts=2 sw=2 tw=0 et :
