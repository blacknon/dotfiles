#!/usr/bin/env bash
# Copyright(c) 2023 Blacknon. All rights reserved.
# Use of this source code is governed by an MIT license
# that can be found in the LICENSE file.

# OSの種類に応じて処理を切り替える
# MacOS/Ubuntu/Arch(Manjaro)によって切り替える
case ${OSTYPE} in
darwin*)
    # brewからパッケージ類をインストールしてくる
    echo "MacOS"
    ;;
linux*)
    # pacmanがある場合、pacmanでパッケージ類をインストールしてくる
    which pacman 2>/dev/null >/dev/null
    if [ $? -eq 0]; then
        # 既存ファイルのアップデート
        pacman -Syyu --noconfirm

        # pkglistの内容をアップデート
        pkglist=$(<~/dotfiles/pkglist/pacman.list)
        sudo pacman -S --noconfirm ${pkglist}
    fi

    # yayがある場合、yayでパッケージ類をインストールしてくる
    which yay 2>/dev/null >/dev/null
    if [ $? -eq 0]; then
        # pkglistの内容をアップデート
        pkglist=$(<~/dotfiles/pkglist/yay.list)
        yay -S --noconfirm ${pkglist}
    fi
    ;;

    # Ubuntuがある場合、aptでパッケージ類をインストールしてくる
    # 現在はUbuntu/Debianを使ってないので処理いらない
esac

# zsh
mkdir -p ~/.zsh && cd $_
git clone https://github.com/zsh-users/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestion
git clone https://github.com/zsh-users/zsh-history-substring-search
cd ~/

# pip
pkglist=$(<~/dotfiles/pkglist/pip.list)
sudo pip install ${pkglist}

# go
pkglist=$(<~/dotfiles/pkglist/go.list)
for pkg in ${pkglist}; do
    go get -u ${pkg}
done

# ディレクトリの作成
mkdir -p ~/Key
mkdir -p ~/Work
mkdir -p ~/Work/Project
mkdir -p ~/Work/ProjectTemplete
mkdir -p ~/iso
mkdir -p ~/log
mkdir -p ~/_ansible
mkdir -p ~/_docker
mkdir -p ~/_env
mkdir -p ~/_go
mkdir -p ~/_javascript
mkdir -p ~/_php
mkdir -p ~/_python
mkdir -p ~/_ruby
mkdir -p ~/_rust
mkdir -p ~/_shell
mkdir -p ~/_text
mkdir -p ~/.vimbackup
sudo mkdir -p /images

# シンボリックリンクの作成
mkdir -p ~/.config/peco
ln -s ~/dotfiles/.zshrc ~/.zshrc
ln -s ~/dotfiles/.bashrc ~/.bashrc
ln -s ~/dotfiles/.vimrc ~/.vimrc
ln -s ~/dotfiles/.tmux.conf ~/.tmux.conf
ln -s ~/dotfiles/bin ~/bin
ln -s ~/dotfiles/pet ~/.config/pet
ln -s ~/dotfiles/peco_config.json ~/.config/peco/config.json

# 自分のプロジェクトをクローン・インストール
# Go
mkdir -p ~/_go/src/github.com/blacknon && cd $_

## lssh
git clone git@github.com:blacknon/lssh.git
cd lssh
sudo mkinst
cd ../

## other
git clone git@github.com:blacknon/go-sshlib.git
git clone git@github.com:blacknon/go-scplib.git

cd ~/

# Javascript

# Python
cd ~/_python

## ashape
git clone git@github.com:blacknon/ashape.git
cd ashape
pip install -U ./
cd ../

## leetutils
git clone git@github.com:blacknon/leetutils.git
cd leetutils
pip install -U ./
cd ../

## tb
git clone git@github.com:blacknon/tb.git
cd tb
pip install -U ./
cd ../

## websearch
git clone git@github.com:blacknon/websearch.git
cd websearch
pip install -U ./
cd ../

cd ~/

# Ruby
cd ~/_ruby

## homebrew-lssh
git clone git@github.com:blacknon/homebrew-lssh.git

## homebrew-hwatch
git clone git@github.com:blacknon/homebrew-hwatch.git

cd ~/

# Rust
curl https://sh.rustup.rs -sSf | sh
cd ~/_rust

## hwatch
git clone git clone git@github.com:blacknon/hwatch.git
cargo install -f --path ./hwatch

cd ~/

# Shell
cd ~/_shell

git clone git clone git@github.com:blacknon/boco.git
git clone git clone git@github.com:blacknon/shfutils.git
git clone git clone git@github.com:blacknon/substitute_line.git

cd ~/

# text
cd ~/_text
git clone git clone git@github.com:blacknon/wordlist.git

# Sublime Textのパッケージ導入

# VSCodeのパッケージ導入

# 各設定を前提としたOS別の設定処理
case ${OSTYPE} in
# MacOSの場合
darwin*)
    # スクリーンショットの保存先を~/Today(`~/Work/YYYYMM/YYYYMMDD/`)に変更
    defaults write com.apple.screencapture location ~/Today/
    killall SystemUIServer
    ;;
esac
