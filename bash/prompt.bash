#!/bin/bash
# Copyright(c) 2023 Blacknon. All rights reserved.
# Use of this source code is governed by an MIT license
# that can be found in the LICENSE file.

# __command_prompt
function __command_prompt() {
  local EXIT="$?"

  # 端末に記録されているコマンド履歴をファイルに追加する
  history -a

  # 端末に記録されているコマンド履歴を消去する
  history -c

  # ファイルに書き込まれているコマンド履歴を端末に読み込む
  history -r

  # 改行
  echo

  local START_BRACKET="\[${COLOR_LGRAY}\][\[${COLOR_NONE}\]" # "["
  local END_BRACKET="\[${COLOR_LGRAY}\]]\[${COLOR_NONE}\]"   # "]"

  local HOST_INFO="\[${COLOR_PURPLE}\]\h\[${COLOR_NONE}\]" # hostname
  local PATH_INFO="\[${COLOR_YELLOW}\]\w\[${COLOR_NONE}\]" # pwd
  local DATE_INFO="$(TZ='Asia/Tokyo' date '+%Y-%m-%d %H:%M:%S (%a) %Z')"

  # ユーザ名がrootの場合は赤文字にする
  local USER="$(whoami)"
  if [ ${USER} = "root" ]; then
    local USER_INFO="\[${COLOR_RED}\]\u\[${COLOR_NONE}\]"
  else
    local USER_INFO="\[${COLOR_GREEN}\]\u\[${COLOR_NONE}\]"
  fi

  local LEFT_TOP_PROMPT="$START_BRACKET$USER_INFO@$HOST_INFO$END_BRACKET"      # [user@host]
  local LEFT_TOP_PROMPT="$LEFT_TOP_PROMPT$START_BRACKET$PATH_INFO$END_BRACKET" # [user@host][~]

  local TITLE="\[\e]0;\u@\h\007\]"

  # SSH_CLIENT変数がある場合、プロンプトの頭に"[REMOTE]"を追加
  # また、ターミナルのタイトルにremoteという文言を追加
  if [ -n "${SSH_CLIENT}" ]; then
    # [REMOTE][user@host][~]
    local LEFT_TOP_PROMPT="$START_BRACKET\[${COLOR_RED}\]REMOTE\[${COLOR_NONE}\]$END_BRACKET$LEFT_TOP_PROMPT"
    local TITLE="\[\e]0;(remote)\u@\h\007\]"
  fi

  # /.dockerenvファイルがある場合、プロンプトの頭に"[DOCKER]"を追加
  if [ -e /.dockerenv ]; then
    local LEFT_TOP_PROMPT="$START_BRACKET\[${COLOR_YELLOW}\]DOCKER\[${COLOR_NONE}\]$END_BRACKET$LEFT_TOP_PROMPT"
  fi

  # 前のコマンドの終了コードに応じてプロンプトの種類を変更
  if [ $EXIT -eq 0 ]; then
    PROMPT_BOTTOM='\[${COLOR_GREEN}\](｀・ω・´)\[${COLOR_NONE}\]'
  else
    local -A err_code=(
      [1]=error [2]='builtin error' [126]='not executable' [127]='command not found'
      [128]=SIGHUP [129]=SIGINT [130]=SIGQUIT [131]=SIGILL [132]=SIGTRAP
      [133]=SIGABRT [134]=SIGEMT [135]=SIGFPE [136]=SIGKILL [137]=SIGBUS
      [138]=SIGSEGV [139]=SIGSYS [140]=SIGPIPE [141]=SIGALRM [142]=SIGTERM
      [143]=SIGURG [144]=SIGSTOP [145]=SIGTSTP [146]=SIGCONT [147]=SIGCHLD
      [148]=SIGTTIN [149]=SIGTTOU [150]=SIGIO [151]=SIGXCPU [152]=SIGXFSZ
      [153]=SIGVTALRM [154]=SIGPROF [155]=SIGWINCH [156]=SIGINFO [157]=SIGUSR1
      [158]=SIGUSR2
    )
    PROMPT_BOTTOM='\[${COLOR_RED}\](´ ；ω；\`)\[${COLOR_NONE}\]'
    LEFT_TOP_PROMPT="${LEFT_TOP_PROMPT}[${COLOR_RED}${err_code[$EXIT]}${COLOR_NONE}]"
  fi

  # 右プロンプトの出力
  local RIGHT_PROMPT="$DATE_INFO"
  local n=$(($COLUMNS - ${#RIGHT_PROMPT} - 2))

  printf "%${n}s$RIGHT_PROMPT\r"

  # プロンプトを出力
  export PS1="$TITLE$LEFT_TOP_PROMPT"$'\n'"$PROMPT_BOTTOM < "

  # Ctrl + Cで表示がおかしくなった場合への対策
  # (sttyの設定をもとの状態に戻しておく)
  stty sane
}

PROMPT_COMMAND=__command_prompt
