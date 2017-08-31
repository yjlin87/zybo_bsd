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
# 1. Vivado HLx Editions QuickTake Video Tutorials
# https://www.xilinx.com/video/category/vivado-quicktake.html
#
# 2. Setting Zynq-7000 Development Environment Variables
# http://www.wiki.xilinx.com/Install+Xilinx+Tools
#
# 其它资料：
# https://wiki.trenz-electronic.de/index.action
# http://www.fpgadeveloper.com/2016/11/tcl-automation-tips-for-vivado-xilinx-sdk.html
###############################################################################
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

###############################################################################
print_info "$(date "+%Y.%m.%d-%H.%M.%S") : Starting $(basename ${BASH_SOURCE})"

# Installation and Licensing
# => Current Vivado/LabTool/SDK Version (Example:2016.4).
export VIVADO_VERSION="${VIVADO_VERSION:-2016.4}"
print_info "Vivado工具版本 : ${VIVADO_VERSION}"

# => Set Xilinx installation path (Default: /opt/Xilinx/).
export XILINX="${XILINX:-/mnt/workspace/Xilinx}"
print_info "Vivado工具目录 : ${XILINX}"

# => License information
# A. Xilinx default license locations
# B. XILINXD_LICENSE_FILE environment variable
export XILINXD_LICENSE_FILE="$(cd $(dirname ${BASH_SOURCE}) && pwd)/licenses"
# C. LM_LICENSE_FILE environment variable

# => Vivado Design Suite
export XILINX_VIVADO=${XILINX}/Vivado/${VIVADO_VERSION}
# => Xilinx Software Development Kit (XSDK):
# (only needed to build the FSBL).
export XILINX_SDK=${XILINX}/SDK/${VIVADO_VERSION}
# => High-Level Synthesis (HLS)
export XILINX_VIVADO_HLS=${XILINX}/Vivado_HLS/${VIVADO_VERSION}
# => Docnav
export XILINX_DOCNAV=${XILINX}/DocNav

# => The Vivado Environment needs to be setup beforehand
###
# Note: There are two settings files available in the Vivado toolset:
# settings64.sh for use on 64-bit machines with bash;
# settings64.csh for use on 64-bit machines with C Shell.
###
if [ -d "${XILINX_VIVADO}" ]; then
    source ${XILINX_VIVADO}/settings64.sh
else
    error_exit "找不到Vivado设计套件！！！"
fi

###
# Fixed: librdi_common* not found executing vivado
# https://forums.xilinx.com/t5/Installation-and-Licensing/librdi-common-not-found-executing-vivado/td-p/536991
###
if [ -n "${LD_LIBRARY_PATH}" ]; then
    export LD_LIBRARY_PATH=${XILINX_VIVADO}/lib/lnx64.o:$LD_LIBRARY_PATH
else
    export LD_LIBRARY_PATH=${XILINX_VIVADO}/lib/lnx64.o
fi

###
# Fixed: SWT issues in Eclipse
###
# Try lsb_release, fallback with /etc/issue then uname command
distributions="(Debian|Ubuntu|RedHat|CentOS|openSUSE|SUSE)"
distribution=$(                                           \
  lsb_release -d 2>/dev/null | grep -Eo $distributions    \
  || grep -Eo $distributions /etc/issue 2>/dev/null       \
  || grep -Eo $distributions /etc/*-release 2>/dev/null   \
  || uname -s                                             \
  )

case ${distribution} in
  Ubuntu)
    export SWT_GTK3=0
    ;;
  *)
    ;;
esac

print_info "$(date "+%Y.%m.%d-%H.%M.%S") : Finished $(basename ${BASH_SOURCE})"
###############################################################################
# vim: set ts=2 sw=2 tw=0 et :
