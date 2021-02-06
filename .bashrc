#!/bin/bash
# Copyright(c) 2021 Blacknon. All rights reserved.
# Use of this source code is governed by an MIT license
# that can be found in the LICENSE file.

### Source global settings
[ -f /etc/bash.bashrc ] && source /etc/bash.bashrc
[ -f /etc/bashrc ] && source /etc/bashrc

### read motd
[ -f /var/run/motd.dynamic ] && cat /var/run/motd.dynamic
[ -f /etc/motd ] && cat /etc/motd

### Setup var
BASHRC_DIR=$(dirname $(realpath $BASH_SOURCE))

### Setup Prompt
[ -f $BASHRC_DIR/bash/bash_prompt ] && source $BASHRC_DIR/bash/bash_prompt

### Setup function
[ -f $BASHRC_DIR/sh/sh_function_common ] && source $BASHRC_DIR/sh/sh_function_common
[ -f $BASHRC_DIR/sh/sh_function_replace ] && source $BASHRC_DIR/sh/sh_function_replace
[ -f $BASHRC_DIR/sh/sh_function_keybind ] && source $BASHRC_DIR/sh/sh_function_keybind
[ -f $BASHRC_DIR/sh/sh_function_exec_1 ] && source $BASHRC_DIR/sh/sh_function_exec_1
[ -f $BASHRC_DIR/sh/sh_function_exec_2 ] && source $BASHRC_DIR/sh/sh_function_exec_2
[ -f $BASHRC_DIR/sh/sh_function_command_not_found_hundle ] && source $BASHRC_DIR/sh/sh_function_command_not_found_hundle

#### Setup function(imgview)
#### TODO(blacknon): iTerm2のときのみ読み込ませる(LC_TERMINALの値に応じて対応？)
[ -f $BASHRC_DIR/sh/sh_function_iterm2 ] && source $BASHRC_DIR/sh/sh_function_iterm2

### Setup export
[ -f $BASHRC_DIR/sh/sh_export ] && source $BASHRC_DIR/sh/sh_export

### Setup Alias
[ -f $BASHRC_DIR/sh/sh_alias ] && source $BASHRC_DIR/sh/sh_alias

### Setup keybind
[ -f $BASHRC_DIR/sh/sh_keybind ] && source $BASHRC_DIR/sh/sh_keybind
[ -f $BASHRC_DIR/bash/bash_keybind ] && source $BASHRC_DIR/bash/bash_keybind

### Setup other
[ -f $BASHRC_DIR/bash/bash_other ] && source $BASHRC_DIR/bash/bash_other
[ -f $BASHRC_DIR/sh/sh_other ] && source $BASHRC_DIR/sh/sh_other

#### Setup Other(bash_local)
#### ローカルマシンでしか利用しない設定を適用
[ -f $BASHRC_DIR/bash/bash_local ] && source $BASHRC_DIR/bash/bash_local

#### Setup Other(_shell)
[ -f ~/_shell/boco/sh_function_boco ] && source ~/_shell/boco/sh_function_boco
[ -f ~/_shell/substitute_line/sh_function_substitute_line ] && source ~/_shell/substitute_line/sh_function_substitute_line

#### Setup Other(_env)
#### ~/_envにおいてある、環境独自のshellファイルの読み込み
[ -f ~/_env/env_shell_function ] && source ~/_env/env_shell_function
