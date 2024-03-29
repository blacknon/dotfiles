#!/bin/bash
# Copyright(c) 2023 Blacknon. All rights reserved.
# Use of this source code is governed by an MIT license
# that can be found in the LICENSE file.

# ABOUT:
#     keybindで読み込ませるためのfunctionを記録しているファイル。
#     prefixは`__`を使用している。
### -------------------------------------------------------------

# TODO(blacknon): Processをkillするためのfunctionを生成(psでリストを取得=>pecoなどで選択後対象のプロセスをkill)
# TODO(blacknon): Processの向き先を変更するためのfunctionを生成(可能なのかどうか？という点も含めて検証)

# cdのhistoryを記録するためのfunction
__cd_record() {
  echo ${PWD} >> ${CDHISTFILE}
}


# Ctrl + X, Ctrl + Dでcdを行うためのfunction(bash/zsh共通)
__cd_selection() {
  # local変数の宣言
  local selecter
  local target_dir

  # セレクトするコマンドの有無によって切り替えをする
  # (peco>bocoの順に確認)
  if type "peco" > /dev/null 2>&1;then
    selecter="peco --prompt 'DIR>'"
  elif type "boco" > /dev/null 2>&1;then
    selecter="boco -p" # printfを出力させないオプションを付与する
  fi

  # ディレクトリの選択
  target_dir=$(
    cat ${CDHISTFILE} | \
    sort | uniq -c | sort -k1nr | \
    sed -e 's/^[ ]*[0-9]*[ ]*//' | \
    sed -e "s/^${HOME//\//\\/}/~/" | \
    eval "${selecter}"
  )

  # ディレクトリの存在有無確認+移動
  # ※ target_dirの取得が正常終了出ない場合はエラーになる
  [ -n "${target_dir}" ] && [ "$?" -eq 0 ] && cd ${target_dir/#\~/$HOME}

  # shellに応じて処理を変える
  case $(basename ${SHELL}) in
    zsh*) zle .accept-line ;;
  esac
}


# Ctrl + X, Cで、現在のプロンプトのコマンドをコピーする(ssh先でも使えるように、OSCエスケープシーケンスを使用)
# TODO: クライアント側のOS種類識別を行うようにする
# NOTE: 【前提】 Macの場合、iTerm2を使ってることが前提
# NOTE: 【前提】 iTerm2の場合、`Perferences`で`Applications in terminal may access clipboard`にチェックが入ってる必要がある
__copy_current_command() {
  # 入力中の内容を変数に代入
  # shellに応じて処理を変える
  case $(basename ${SHELL}) in
    zsh*)  local buf=${BUFFER} ;;
    bash*) local buf=${READLINE_LINE} ;;
  esac

  # TODO: bufのサイズに応じて処理を切り替え(0だったら処理を終了する)

  # TODO: 使っているクライアントOSに応じて処理を切り替え
  #       ※ 現在はMacOS iTermでの利用決め打ち
  printf "\033]52;;%s\033\\" $(printf "${buf}"|base64)
  # case ${OSTYPE} in
  #   darwin*)
  #     # OSCエスケープシーケンスの
  #     printf "\033]52;;%s\033\\" "$(printf ${buf}|base64)"
  #     ;;
  #   # linux*)

  #   #   ;;
  # esac
}


# TODO(blacknon): zshで入力中の内容がそのまま残ることがあるので、強制的に消す方法を考える
# TODO(blacknon): zshでpeco貼付け時にメタキャラクタまで入力される事がある。対策を考える。
# Ctrl + R でhistory検索をする(peco,bocoを使用)
__history_selection() {
  # optionをパース
  local opt
  while getopts "x" opt; do
    case "$opt" in
    x) local flg_x=1 ;;
    esac
  done

  # 逆順に出力するコマンド
  if which tac >/dev/null; then
    local reverse="tac"
  else
    # tacがない場合、たいていはMacなのでMac用のオプションを付けたtailを実行する
    local reverse="\tail -r"
  fi

  # 入力中の値をクエリとして渡すため、変数に代入
  case $(basename "${SHELL}") in
    zsh*)  local data="${BUFFER}" ;;
    bash*) local data="${READLINE_LINE}" ;;
  esac

  # セレクトするコマンドの有無によって切り替えをする
  # (peco>bocoの順に確認)
  if type "peco" > /dev/null 2>&1;then
    if [[ $flg_x -eq 1 ]];then
      local selecter="peco --prompt 'HISTORY>'"
    else
      local selecter="peco --prompt 'HISTORY>' --query \"${data}\""
    fi
  elif type "boco" > /dev/null 2>&1;then
    if [[ $flg_x -eq 1 ]];then
      local selecter="boco"
    else
      # printfで制御コードを出力させないオプションを付与する
      local selecter="boco -p -q \"${data}\""
    fi
  fi

  # セレクトに使うコマンドがbocoの場合、長い行を表示させるために以下のコマンドを実行する
  if [[ ${selecter} =~ ^boco ]];then
    printf '\033[?7l'
  fi

  # shellに応じて処理を変える
  case $(basename "${SHELL}") in
    zsh*)
      if [[ $flg_x -eq 1 ]];then
        BUFFER=${LBUFFER}$(history -n 1 | eval "${reverse}" | awk '!a[$0]++' | eval "${selecter}")${RBUFFER} # 入力中のコマンドに差し込み
        CURSOR="${#LBUFFER}" # カーソル位置を移動
      else
        BUFFER=$(history -n 1 | eval "${reverse}" | awk '!a[$0]++' | eval "${selecter}") # 入力中のコマンドの内容を上書き
        CURSOR="${#BUFFER}" # カーソル位置を移動
      fi
      ;;
    bash*)
      if [[ -n ${HISTTIMEFORMAT} ]];then # $HISTTIMEFORMATに値が入っている場合 => history番号とタイムスタンプを削除する
        local buffer=$(history | sed -r 's/^[ 0-9]+:* *[0-9]+ [0-9]{2}:[0-9]{2}:[0-9]{2} *:* *//g' | eval ${reverse} | awk '!a[$0]++' | eval ${selecter})
      else # $HISTTIMEFORMATに値が入ってない(空っぽ)場合 => history番号だけ削除する
        local buffer=$(history | sed -r 's/^ *[0-9*]+ +//g' | eval ${reverse} | awk '!a[$0]++' | eval ${selecter})
      fi

      if [[ $flg_x -eq 1 ]];then
        echo 1
      else
        READLINE_LINE="${buffer}" # 入力中のコマンドの内容を上書き
        READLINE_POINT="${#READLINE_LINE}" # カーソル位置を移動
      fi
      ;;
  esac

  if [[ ${selecter} =~ ^boco ]];then
    printf '\033[?7h'
  fi
}


# Ctrl + R でhistory検索をして現在カーソルに差し込みをするfunction
__history_selection_insert() {
  __history_selection -x
}


# pet searchをしてコマンドラインを置き換えるkeybind用のfunction
__pet_set() {
  # petからsnippetを取得する
  local cmd="$(pet search)"

  # 入力中のコマンドラインの内容を書き換える
  case $(basename "${SHELL}") in
    zsh*)
      BUFFER="${LBUFFER}${cmd}${RBUFFER}"
      CURSOR=$((${#LBUFFER}+${#cmd}))
      ;;

    bash*)
      READLINE_LINE=${READLINE_LINE::${READLINE_POINT}}${cmd}${READLINE_LINE:${READLINE_POINT}:}
      READLINE_POINT=$((${READLINE_POINT}+${#cmd}))
      ;;

  esac
}


# コマンド置換形式に変換する
__toggle_substitution_format() {
  ____toggle_surround_format '$(' ')'
}


# 入力中の内容をシングルクオーテーションで囲む
__toggle_singlequote_format() {
  ____toggle_surround_format \' \'
}


# 入力中の内容をダブルクオーテーションで囲む
__toggle_doublequote_format() {
  ____toggle_surround_format \" \"
}


# wwをkeybindで実行する
__ww() {
  ww
  case $(basename ${SHELL}) in
  zsh*) zle .accept-line ;;
  esac
}

# ywをkeybindで実行する
__yw() {
  yw
  case $(basename ${SHELL}) in
  zsh*) zle .accept-line ;;
  esac
}

# twをkeybindで実行する
__tw() {
  tw
  case $(basename ${SHELL}) in
  zsh*) zle .accept-line ;;
  esac
}
