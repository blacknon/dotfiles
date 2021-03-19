#!/bin/zsh
# Copyright(c) 2021 Blacknon. All rights reserved.
# Use of this source code is governed by an MIT license
# that can be found in the LICENSE file.

### Setup Var
ZSHRC_DIR=$(dirname $(realpath "${(%):-%N}")) # このファイル本体のあるディレクトリ

### 読み込みファイルを個別に指定してREAD(読み込む順番があるので個別指定)
FILES=(
    $ZSHRC_DIR/zsh/zsh_prompt
    $ZSHRC_DIR/sh/sh_function_common
    $ZSHRC_DIR/sh/sh_function_replace
    $ZSHRC_DIR/sh/sh_function_keybind
    $ZSHRC_DIR/sh/sh_function_exec_1
    $ZSHRC_DIR/sh/sh_function_exec_2
    $ZSHRC_DIR/sh/sh_function_command_not_found_hundle
    $ZSHRC_DIR/zsh/zsh_function
    $ZSHRC_DIR/sh/sh_function_iterm2
    $ZSHRC_DIR/sh/sh_export
    $ZSHRC_DIR/sh/sh_alias
    $ZSHRC_DIR/sh/sh_other
    $ZSHRC_DIR/zsh/zsh_other
    ~/_shell/boco/sh_function_boco
    ~/_shell/substitute_line/sh_function_substitute_line
    ~/_env/env_shell_function
    ~/dotfiles_private/sh/sh_export_key
)
for i in ${FILES}; do
    if [ -f "$i" ]; then
        source "$i"
    fi
done
