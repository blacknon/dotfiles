#!/bin/bash
# Copyright(c) 2023 Blacknon. All rights reserved.
# Use of this source code is governed by an MIT license
# that can be found in the LICENSE file.

### Setup var
BASHRC_DIR="$(dirname $(realpath $BASH_SOURCE))"

### 読み込みファイルを個別に指定してREAD(読み込む順番があるので個別指定)
FILES=(
    /etc/bash.bashrc
    /etc/bashrc
    /var/run/motd.dynamic
    /etc/motd
    "${BASHRC_DIR}"/bash/prompt.bash
    "${BASHRC_DIR}"/sh/functions/common.sh
    "${BASHRC_DIR}"/sh/functions/replace.sh
    "${BASHRC_DIR}"/sh/functions/keybind.sh
    "${BASHRC_DIR}"/sh/functions/exec_1.sh
    "${BASHRC_DIR}"/sh/functions/exec_2.sh
    "${BASHRC_DIR}"/sh/functions/command_not_found_hundle.sh
    "${BASHRC_DIR}"/sh/functions/iterm2.sh # iterm2用のfunctionファイル
    "${BASHRC_DIR}"/sh/export.sh
    "${BASHRC_DIR}"/sh/alias.sh
    "${BASHRC_DIR}"/sh/keybind.sh
    "${BASHRC_DIR}"/bash/keybind.bash
    "${BASHRC_DIR}"/bash/other.bash
    "${BASHRC_DIR}"/sh/other.sh
    "${BASHRC_DIR}"/bash/local.bash # ローカルにしか無い設定ファイル
    ~/_shell/boco/boco.bash
    ~/_shell/substitute_line/substitute_line.bash
    ~/dotfiles_private/bashrc # プライベートdotfiles用ファイル群
    ~/_env/bashrc             # 環境に依存したファイル群
)
for i in "${FILES[@]}"; do
    if [ -f "$i" ]; then
        source "$i" || echo "not found $i"
    fi
done
. "/Users/uesugi/.local/share/cargo/env"
