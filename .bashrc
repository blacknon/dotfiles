#!/bin/bash
# Copyright(c) 2021 Blacknon. All rights reserved.
# Use of this source code is governed by an MIT license
# that can be found in the LICENSE file.

### Setup var
BASHRC_DIR=$(dirname $(realpath $BASH_SOURCE))

### 読み込みファイルを個別に指定してREAD(読み込む順番があるので個別指定)
FILES=(
    /etc/bash.bashrc
    /etc/bashrc
    /var/run/motd.dynamic
    /etc/motd
    $BASHRC_DIR/bash/bash_prompt
    $BASHRC_DIR/sh/sh_function_common
    $BASHRC_DIR/sh/sh_function_replace
    $BASHRC_DIR/sh/sh_function_keybind
    $BASHRC_DIR/sh/sh_function_exec_1
    $BASHRC_DIR/sh/sh_function_exec_2
    $BASHRC_DIR/sh/sh_function_command_not_found_hundle
    $BASHRC_DIR/sh/sh_function_iterm2 # iterm2用のfunctionファイル
    $BASHRC_DIR/sh/sh_export
    $BASHRC_DIR/sh/sh_alias
    $BASHRC_DIR/sh/sh_keybind
    $BASHRC_DIR/bash/bash_keybind
    $BASHRC_DIR/bash/bash_other
    $BASHRC_DIR/sh/sh_other
    $BASHRC_DIR/bash/bash_local # ローカルにしか無い設定ファイル
    ~/_shell/boco/sh_function_boco
    ~/_shell/substitute_line/sh_function_substitute_line
    ~/_env/env_shell_* # 環境に依存したファイル群
    ~/_env/sh_export   # 環境に依存したファイル
    ~/dotfiles_private/bashrc
)
for i in "${FILES[@]}"; do
    if [ -f "$i" ]; then
        source "$i"
    fi
done
