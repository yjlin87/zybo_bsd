#!/bin/bash -e
###############################################################################
# Copyright (C) 2017 by Yujiang Lin <linyujiang@hotmail.com>
#
# This program is free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
###############################################################################
printf "[INFO] $(date "+%Y.%m.%d-%H.%M.%S"): Starting $(basename ${BASH_SOURCE})"

# => Xilinx Design Tools Version
ZN_XILINX_VERSION="2017.2"

# => Xilinx Tools Directory
ZN_XILINX_DIR="/mnt/workspace/Xilinx"

# => Xilinx Software Development Kit Directory
ZN_XILINX_SDK_DIR="${ZN_XILINX_DIR}/SDK/${ZN_XILINX_VERSION}"

# => Update ARM Cross Compiler
ZN_CROSS_COMPILER_DIR="$(cd $(dirname ${BASH_SOURCE}) && pwd)/cross_compiler"
# ==> 若已经存在交叉编译器，则删除原来的交叉编译器
if [ -d "${ZN_CROSS_COMPILER_DIR}" ]; then
  rm -rf ${ZN_CROSS_COMPILER_DIR}
fi
# ==> 从Vivado安装目录中拷贝所需要的交叉编译器
# A. Zynq-7000 (CodeSourcery - soft floatb)
if [ -d ${ZN_XILINX_SDK_DIR}/gnu/arm/lin ]; then
  cp -R ${ZN_XILINX_SDK_DIR}/gnu/arm/lin ${ZN_CROSS_COMPILER_DIR}
else
  error_exit "无法找到交叉编译器"
fi
# B. Zynq-7000 (Linaro - hard float)
# if [ -d ${ZN_XILINX_SDK_DIR}/gnu/aarch32/lin/gcc-arm-linux-gnueabi ]; then
#   cp -R ${ZN_XILINX_SDK_DIR}/gnu/aarch32/lin/gcc-arm-linux-gnueabi ${ZN_CROSS_COMPILER_DIR}
# else
#   error_exit "无法找到交叉编译器"
# fi

printf "[INFO] $(date "+%Y.%m.%d-%H.%M.%S"): Finished $(basename ${BASH_SOURCE})"
# vim: set ts=2 sw=2 tw=0 et :
