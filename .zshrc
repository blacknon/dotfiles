#!/bin/zsh
# Copyright(c) 2019 Blacknon. All rights reserved.
# Use of this source code is governed by an MIT license
# that can be found in the LICENSE file.

### Setup Var
ZSHRC_DIR=$(dirname $(realpath ${(%):-%N})) # このファイル本体のあるディレクトリ

### Setup Prompt
[ -f $ZSHRC_DIR/zsh/zsh_prompt ] && source $ZSHRC_DIR/zsh/zsh_prompt

### Setup func
[ -f $ZSHRC_DIR/sh/sh_function_common ] && source $ZSHRC_DIR/sh/sh_function_common
[ -f $ZSHRC_DIR/sh/sh_function_replace ] && source $ZSHRC_DIR/sh/sh_function_replace
[ -f $ZSHRC_DIR/sh/sh_function_keybind ] && source $ZSHRC_DIR/sh/sh_function_keybind
[ -f $ZSHRC_DIR/sh/sh_function_exec_1 ] && source $ZSHRC_DIR/sh/sh_function_exec_1
[ -f $ZSHRC_DIR/sh/sh_function_exec_2 ] && source $ZSHRC_DIR/sh/sh_function_exec_2
[ -f $ZSHRC_DIR/sh/sh_function_command_not_found_hundle ] && source $ZSHRC_DIR/sh/sh_function_command_not_found_hundle

#### Setup function(zsh_function)
[ -f $ZSHRC_DIR/zsh/zsh_function ] && source $ZSHRC_DIR/zsh/zsh_function

#### Setup function(imgview/imgls)
#### TODO(blacknon): iTerm2のときのみ読み込ませる(LC_TERMINALの値に応じて対応？)
[ -f $ZSHRC_DIR/sh/sh_function_iterm2 ] && source $ZSHRC_DIR/sh/sh_function_iterm2

### Setup export
[ -f $ZSHRC_DIR/sh/sh_export ] && source $ZSHRC_DIR/sh/sh_export

### Setup Alias
[ -f $ZSHRC_DIR/sh/sh_alias ] && source $ZSHRC_DIR/sh/sh_alias

### Setup Other
[ -f $ZSHRC_DIR/sh/sh_other ] && source $ZSHRC_DIR/sh/sh_other
[ -f $ZSHRC_DIR/zsh/zsh_other ] && source $ZSHRC_DIR/zsh/zsh_other

#### Setup Other(_shell)
[ -f ~/_shell/boco/sh_function_boco ] && source ~/_shell/boco/sh_function_boco
[ -f ~/_shell/substitute_line/sh_function_substitute_line ] && source ~/_shell/substitute_line/sh_function_substitute_line

#### Setup Other(_env)
##### ~/_envにおいてある、環境独自のshellファイルの読み込み
[ -f ~/_env/env_shell_function ]&& source ~/_env/env_shell_function

