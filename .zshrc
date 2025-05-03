#!/usr/bin/env zsh
# Copyright(c) 2023 Blacknon. All rights reserved.
# Use of this source code is governed by an MIT license
# that can be found in the LICENSE file.

### Setup Var
ZSHRC_DIR=$(dirname $(realpath "${(%):-%N}")) # このファイル本体のあるディレクトリ

### 読み込みファイルを個別に指定してREAD(読み込む順番があるので個別指定)
FILES=(
    $ZSHRC_DIR/zsh/prompt.zsh
    $ZSHRC_DIR/sh/functions/common.sh
    $ZSHRC_DIR/sh/functions/replace.sh
    $ZSHRC_DIR/sh/functions/keybind.sh
    $ZSHRC_DIR/sh/functions/exec_1.sh
    $ZSHRC_DIR/sh/functions/exec_2.sh
    $ZSHRC_DIR/sh/functions/exec_ddig.sh
    $ZSHRC_DIR/sh/functions/exec_pping.sh
    $ZSHRC_DIR/sh/functions/exec_local.sh
    $ZSHRC_DIR/sh/functions/exec_docker.sh
    $ZSHRC_DIR/sh/functions/command_not_found_hundle.sh
    $ZSHRC_DIR/zsh/functions/function.zsh
    $ZSHRC_DIR/sh/functions/iterm2.sh
    $ZSHRC_DIR/sh/functions/macos.sh
    $ZSHRC_DIR/sh/export.sh
    $ZSHRC_DIR/sh/alias.sh
    $ZSHRC_DIR/zsh/alias.zsh
    $ZSHRC_DIR/sh/other.sh
    $ZSHRC_DIR/zsh/other.zsh
    ~/_shell/boco/boco.bash
    ~/_shell/substitute_line/substitute_line.bash
    ~/dotfiles_private/zshrc
    ~/_env/zshrc
    ~/.local/share/cargo/env
)

for i in ${FILES}; do
    if [ -f "$i" ]; then
        source "$i" || echo "not found: $i"
    fi
done
