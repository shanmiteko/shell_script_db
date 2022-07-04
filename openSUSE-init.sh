#!/usr/bin/env bash

# openSUSE Tumbleweed

# 禁用官方源
sudo zypper mr -da

# 添加 TUNA 镜像源
# 开源软件
sudo zypper ar -cfg 'https://mirrors.tuna.tsinghua.edu.cn/opensuse/tumbleweed/repo/oss/' tuna-oss
# 非开源软件
sudo zypper ar -cfg 'https://mirrors.tuna.tsinghua.edu.cn/opensuse/tumbleweed/repo/non-oss/' tuna-non-oss

# See https://zh.opensuse.org/%E8%A7%A3%E7%A0%81%E5%99%A8
# 通过 Packman 安装解码器
sudo zypper ar -cfp 90 https://mirrors.ustc.edu.cn/packman/suse/openSUSE_Tumbleweed packman

# See https://en.opensuse.org/Visual_Studio_Code
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo zypper ar https://packages.microsoft.com/yumrepos/vscode vscode

# 刷新软件源
sudo zypper refresh

# 发行版升级
sudo zypper dist-upgrade --from packman --allow-vendor-change
sudo zypper dup

# 常用软件
# 使用zypper
sudo zypper install \
	zsh \
	git \
	axel \
	code \
	ripgrep \
	jq \
	proxychains-ng \
	npm \
	clash

# Font
# https://github.com/tonsky/FiraCode/releases

# C/C++
sudo zypper install -t pattern devel_C_C++

# Git
ssh-keygen -C "shanmite@hotmail.com"

# Oh My Zsh
# chsh -s $(which zsh)
# sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
# git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# Clash
# see https://github.com/Dreamacro/clash/releases

# Rust
# zypper in rustup
# rustup-init
# see https://cargo.budshome.com/reference/source-replacement.html

# Nodejs
# npm config set registry https://registry.npm.taobao.org

# python3
# pip config set global.index-url https://pypi.mirrors.ustc.edu.cn/simple/

mkdir ~/logs
printf "@reboot sleep 10 && (date; find ~/.cache/ -depth -type f -atime +60) > ~/logs/cache_clear.log 2>&1 && find ~/.cache -depth -type f -mtime +60 -delete
@reboot sleep 30 && (date; sudo zypper ref; sudo zypper dup -y) > ~/logs/zypper_dup.log 2>&1
" | crontab -
