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
  echo "Purpose: 安装开发环境所需要的软件包"
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

# => Beginning with Vivado 2015.1, 32-bit Operating System and application
# support has been removed for all design entry and implementation flows
ARCH=$(uname -m)
if [ "$ARCH" == "i686" -o "$ARCH" == "i386" -o "$ARCH" == "x86" ]; then
  error_exit "Only available for 64 bit machines."
fi

# => Distribution Detection
# Try lsb_release, fallback with /etc/issue then uname command
distributions="(Debian|Ubuntu|RedHat|CentOS|openSUSE|SUSE)"
distribution=$(                                           \
  lsb_release -d 2>/dev/null | grep -Eo $distributions    \
  || grep -Eo $distributions /etc/issue 2>/dev/null       \
  || grep -Eo $distributions /etc/*-release 2>/dev/null   \
  || uname -s                                             \
  )

case ${distribution} in
  Debian)
    print_info "Debian"
    ;;
  Ubuntu)
    source /etc/os-release
    print_info "${NAME} ${VERSION}"

    read -p "你确定继续吗？ (Y|n) : " confirm_continue
    if [ -z "$confirm_continue" ]; then
      confirm_continue="Y"
    fi
    if [ "$confirm_continue" == "n" -o "$confirm_continue" == "no" ]; then
      exit
    fi

    ###
    # http://www.wiki.xilinx.com/Install+Xilinx+tools
    ###
    # => Platform specific hints & tips
    # Ubuntu 12.04 LTS x86_64 users may run into issues related to missing
    # dependencies when installing the Xilinx tools. This release of Ubuntu
    # lacks some needed 32-bit libraries which need to be installed. This
    # can be done by executing

    # => Update the Package Index
    # The APT package index is essentially a database of available packages
    # from the repositories defined in the /etc/apt/sources.list file and
    # in the /etc/apt/sources.list.d directory. To update the local package
    # index with the latest changes made in the repositories, type the
    # following:
    $sudo_cmd apt-get update

    # => Upgrade Packages
    # Over time, updated versions of packages currently installed on your
    # computer may become available from the package repositories (for
    # example security updates). To upgrade your system, first update your
    # package index as outlined above, and then type:
    $sudo_cmd apt-get upgrade

    # Informational list of build-essential packages
    $sudo_cmd apt-get install build-essential
    # generic dependencies
    $sudo_cmd apt-get install make curl xz-utils
    # U-Boot build dependencies
    $sudo_cmd apt-get install libssl-dev device-tree-compiler u-boot-tools
    # secure chroot
    $sudo_cmd apt-get install schroot
    # QEMU
    $sudo_cmd apt-get install qemu qemu-user qemu-user-static
    # 32 bit libraries
    $sudo_cmd apt-get install lib32ncurses5 lib32z1

    # 使用 screen 管理你的远程会话
    $sudo_cmd apt-get install screen

    # 'make menuconfig' requires the ncurses libraries.
    $sudo_cmd apt-get install libncurses5-dev

    # Fixed: Missing gmake path
    if [ ! -f /usr/bin/gmake ]; then
      $sudo_cmd ln -s /usr/bin/make /usr/bin/gmake
    fi

    # The Yocto Project
    $sudo_cmd apt-get install gawk wget git-core diffstat unzip texinfo gcc-multilib \
      build-essential chrpath socat cpio python python-pip python3 python3-pip \
      python3-pexpect xz-utils debianutils iputils-ping libsdl1.2-dev xterm

    # For vim
    $sudo_cmd apt-get install vim ctags cscope global silversearcher-ag

    # For YouCompleteMe
    # http://valloric.github.io/YouCompleteMe/#ubuntu-linux-x64
    $sudo_cmd apt-get install build-essential cmake python-dev python3-dev

    # For Python
    pip install flake8 yapf

    ;;
  RedHat)
    print_info "RedHat"
    ;;
  CentOS)
    print_info "CentOS"
    ;;
  SUSE)
    print_info "SUSE"
    ;;
  openSUSE)
    source /etc/os-release
    print_info "${NAME} ${VERSION}"

    read -p "你确定继续吗？ (Y|n) : " confirm_continue
    if [ -z "$confirm_continue" ]; then
      confirm_continue="Y"
    fi
    if [ "$confirm_continue" == "n" -o "$confirm_continue" == "no" ]; then
      exit
    fi

    # => NetworkManager
    # 开机启用 NetworkManager：
    # systemctl enable NetworkManager
    # 立即启动 NetworkManager：
    # systemctl start NetworkManager

    # => opensuse开机自动登陆root用户：
    # vim /etc/sysconfig/displaymanager
    # DISPLAYMANAGER_AUTOLOGIN="root"

    # => 软件源
    # https://lug.ustc.edu.cn/sites/opensuse-guide/repositories.php
    read -p "仅使用DVD光盘源？ (y|N) : " enable_dvd_repo
    if [ -z "$enable_dvd_repo" ]; then
      enable_dvd_repo="N"
    fi
    if [ "$enable_dvd_repo" == "Y" -o "$enable_dvd_repo" == "y" ]; then
      $sudo_cmd zypper modifyrepo --disable --all
      $sudo_cmd zypper modifyrepo --enable openSUSE-${VERSION}-0
    else
      read -p "是否使用阿里软件源？ (y|N) : " enable_aliyun_repo
      if [ -z "$enable_aliyun_repo" ]; then
        enable_aliyun_repo="N"
      fi

      if [ "$enable_aliyun_repo" == "Y" -o "$enable_aliyun_repo" == "y" ]; then
        # 禁用原有软件源
        $sudo_cmd zypper modifyrepo --disable --all
        ###
        # 添加阿里软件源
        ###
        # Main Repository (OSS)（开源的软件）
        $sudo_cmd zypper --gpg-auto-import-keys addrepo -f http://mirrors.aliyun.com/opensuse/distribution/leap/$VERSION/repo/oss/ openSUSE-$VERSION-Oss
        # Main Repository (NON-OSS)（非开源软件）
        $sudo_cmd zypper --gpg-auto-import-keys addrepo -f http://mirrors.aliyun.com/opensuse/distribution/leap/$VERSION/repo/non-oss/ openSUSE-$VERSION-Non-Oss
        # Main Update Repository（开源软件安全更新）
        $sudo_cmd zypper --gpg-auto-import-keys addrepo -f http://mirrors.aliyun.com/opensuse/update/leap/$VERSION/oss openSUSE-$VERSION-Update-Oss
        # Main Update Repository (NON-OSS)（非开源软件安全更新）
        $sudo_cmd zypper --gpg-auto-import-keys addrepo -f http://mirrors.aliyun.com/opensuse/update/leap/$VERSION/non-oss/ openSUSE-$VERSION-Update-Non-Oss
        # Packman Repository (多媒体编解码器-播放器、Broadcom无线网卡驱动、游戏等)
        $sudo_cmd zypper --gpg-auto-import-keys addrepo -f http://mirrors.aliyun.com/packman/openSUSE_Leap_$VERSION/ aliyun-packman

        # 手动刷新软件源
        $sudo_cmd zypper refresh
        #
        # 更新系统
        $sudo_cmd zypper update
      fi
    fi

    # => 安装开发环境
    print_info "x86 Runtime Environment..."
    $sudo_cmd zypper --non-interactive install --type pattern x86

    print_info "64-Bit Runtime Environment..."
    $sudo_cmd zypper --non-interactive install --type pattern 64bit

    print_info "Install Base Development..."
    $sudo_cmd zypper --non-interactive install --type pattern devel_basis

    print_info "C/C++ Development..."
    $sudo_cmd zypper --non-interactive install --type pattern devel_C_C++

    print_info "Install Linux Kernel Development..."
    $sudo_cmd zypper --non-interactive install --type pattern devel_kernel
    $sudo_cmd zypper --non-interactive install cscope

    print_info "Install U-Boot build dependencies..."
    $sudo_cmd zypper --non-interactive install libopenssl-devel

    # The Yocto Project
    $sudo_cmd zypper install python gcc gcc-c++ git chrpath make wget python-xml \
      diffstat makeinfo python-curses patch socat python3 python3-curses tar python3-pip \
      python3-pexpect xz which libSDL-devel xterm

    print_info "Fix Petalinux dependencies..."
    $sudo_cmd zypper --non-interactive install xvfb-run
    $sudo_cmd zypper --non-interactive install chrpath
    $sudo_cmd zypper --non-interactive install socat
    $sudo_cmd zypper --non-interactive install python-curses
    $sudo_cmd zypper --non-interactive install dblatex
    $sudo_cmd zypper --non-interactive install xmlto
    $sudo_cmd zypper --non-interactive install xlsclients

    # How do I find out which libraries are required to run Vivado tools in Linux?
    # https://www.xilinx.com/support/answers/66184.html
    #
    # Although Vivado is 64bit only nowadays, DocNav is still a 32bit application.
    # If you want to use it, you will need some additional libraries.
    print_info "Fix DocNav dependencies..."
    # Qt 4 GUI related libraries
    # libqtgui4:i386
    $sudo_cmd zypper --non-interactive install libqt4-x11-32bit
    # X Session Management library
    # libsm6:i386
    $sudo_cmd zypper --non-interactive install libSM6-32bit
    # X Rendering Extension library
    # libxrender1:i386
    $sudo_cmd zypper --non-interactive install libXrender1-32bit
    # Common extensions to the X11 protocol
    # libxext6:i386
    $sudo_cmd zypper --non-interactive install libXext6-32bit
    # Core X11 protocol client library
    # libx11-6:i386
    $sudo_cmd zypper --non-interactive install libX11-6-32bit
    # Library for Font Configuration
    # libfontconfig1:i386
    $sudo_cmd zypper --non-interactive install fontconfig-32bit
    # The GTK+ toolkit library (version 2)
    # libgtk2.0-0:i386
    $sudo_cmd zypper --non-interactive install libgtk-2_0-0-32bit
    # The standard C++ shared library
    # lib32stdc++6
    $sudo_cmd zypper --non-interactive install libstdc++6-32bit
    # libpng12.so.0 => not found
    $sudo_cmd zypper --non-interactive install libpng12-0 libpng12-devel libpng12-devel-32bit

    # => 压缩，解压 rar 文件
    $sudo_cmd zypper --non-interactive install rar unrar

    # => 支持 7zip 压缩包
    $sudo_cmd zypper --non-interactive install p7zip

    # => MPlayer是一款开源多媒体播放器，以GNU通用公共许可证发布。
    print_info "Install MPlayer..."
    $sudo_cmd zypper --non-interactive install smplayer

    # => mlocate is a merging locate and database package.
    $sudo_cmd zypper --non-interactive install mlocate mlocate-lang
    print_info "update a database for mlocate ..."
    $sudo_cmd updatedb

    # => 使用 GitBook 写文档
    # GitBook是一个基于 Node.js 的命令行工具，可使用 Markdown 来制作精美的电子书。
    print_info "Install GitBook..."
    # 安装npm (Node Package Manager)
    $sudo_cmd zypper --non-interactive install npm calibre
    # 通过npm安装GitBook
    $sudo_cmd npm install -g gitbook-cli
    # Display running versions of gitbook and gitbook-cli
    gitbook --version

    ;;
  *)
    error_exit "Your OS or distribution are not supported by this script."
    ;;
esac

print_info "$(date "+%Y.%m.%d-%H.%M.%S") : Finished $script_name"
###############################################################################
# vim: set ts=2 sw=2 tw=0 et :
