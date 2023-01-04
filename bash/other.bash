#!/bin/bash
# Copyright(c) 2023 Blacknon. All rights reserved.
# Use of this source code is governed by an MIT license
# that can be found in the LICENSE file.

# ヒストリー件数を定義
export HISTSIZE=50000000

if [[ -d "${XDG_STATE_HOME}/bash/" ]]; then
  export HISTFILE="${XDG_STATE_HOME}/bash/bash_history"
  export CDHISTFILE="${XDG_STATE_HOME}/bash/bash_cd_history"
else
  export HISTFILE="${HOME}/.bash_history"
  export CDHISTFILE="${HOME}/.bash_cd_history"
fi

# 重複した履歴を保存しない
export HISTCONTROL="ignoredups"

# fg,bg,history,cd,clearの履歴を保存しない
export HISTIGNORE="fg*:bg*:history*:cd*:clear"

# historyにタイムスタンプを付与させる
HISTTIMEFORMAT=':%Y%m%d %T: '
export HISTTIMEFORMAT

# セッションクローズ時のヒストリファイルへの自動追記を無効化
shopt -u histappend

# SHELLにbashを入れる
export SHELL="$(which bash)"

# complete
complete -cf sudo

# bash-completion
case ${OSTYPE} in
darwin*)
  if [ -f "$(brew --prefix)/etc/bash_completion" ]; then
    source "$(brew --prefix)/etc/bash_completion"
  fi
  ;;
linux*) ;;

esac
