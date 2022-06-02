#!/bin/bash
# Copyright(c) 2021 Blacknon. All rights reserved.
# Use of this source code is governed by an MIT license
# that can be found in the LICENSE file.

# ABOUT:
#     他のfunctionから参照させるためのfunctionをまとめているファイル。
#     prefixは`____`を使用している。
### -------------------------------------------------------------

# TODO(blacknon): ヘルプ出力をするfunctionを生成する

# 各文字を1文字ずつずらした文字列を出力する(agrepで使用)
____shift1chars() {
  local str=$1

  # OSの種類に応じてsedを切り替え
  case ${OSTYPE} in
  darwin*)
    sed="gsed"
    ;;
  linux*)
    sed="sed"
    ;;
  esac

  for i in $(seq 0 $((${#str} - 1))); do
    $sed -r 's/(.{'$i'})(.)(.)/\1\3\2/' <<<$str
  done
}

# 各文字を1文字だけドット(.)にした文字列の一覧を出力する(agrepで使用)
____1char2dotchar() {
  local str=$1

  echo $str |
    grep -o . |
    gawk '
    {a=$0=a$0}
    END{
      for(i=1;i<=NR;i++){
        print gensub(/./,".",i)
      }
    }'
}

# エスケープした文字を返す
____get_escape() {
  case $(echo ${1}) in
  '"') echo "$(printf %q ${1})" ;;
  "'") echo "'""$(printf %q ${1})""'" ;;
  *) echo ${1} ;;
  esac
}

# 入力中の内容を引数で指定された文字列で囲む(カーソル位置〜行末)
____toggle_surround_format() {
  # ローカル変数定義
  local buf

  # 入力中の内容を変数に代入
  # shellに応じて処理を変える
  case $(basename ${SHELL}) in
  zsh*) buf=${RBUFFER} ;;
  bash*) buf=${READLINE_LINE:${READLINE_POINT}} ;;
  esac

  # すでにダブルクオーテーションで囲まれている場合は、前後のダブルクオーテーションを削除してエスケープ済のダブルクオーテーションを解除
  if [[ ${buf:0:${#1}} == ${1} ]] && [[ ${buf: -${#2}} == ${2} ]]; then
    buf="${buf:${#1}}"
    buf="${buf:0:-${#2}}"
    if [[ ${1} == ${2} ]]; then
      # エスケープ済の${1}が含まれている場合、解除するよう置換する
      buf="${buf//$(____get_escape ${1})/${1}}"
    else
      # エスケープ済の${1},${2}が含まれている場合、解除するよう置換する
      buf="${buf//$(____get_escape ${1})/${1}}"
      buf="${buf//$(____get_escape ${2})/${2}}"
    fi
  else
    if [[ ${1} == ${2} ]]; then
      # ${1}が含まれている場合、エスケープするよう置換する
      buf="${buf//${1}/$(____get_escape ${1})}"
    else
      buf="${buf//${1}/$(____get_escape ${1})}"
      buf="${buf//${2}/$(____get_escape ${2})}"
    fi
    buf=${1}${buf}${2}
  fi

  # 入力中の内容を置き換える
  # shellに応じて処理を変える
  case $(basename ${SHELL}) in
  zsh*) RBUFFER="${buf}" ;;
  bash*) READLINE_LINE="${READLINE_LINE::${READLINE_POINT}}${buf}" ;;
  esac
}

# ローカルマシンで使用しているbashrcやvimrcのfunctionを読み込んで
# base64にして返す関数
____get_rcdata() {
  case ${OSTYPE} in
  darwin*) BASE64_CMD="base64" ;;
  linux*) BASE64_CMD="base64 -w0" ;;
  esac

  # dotfilesとboco、substitute_lineを読み込ませる
  # TODO(blacknon): いないファイルは読ませないように書き換え
  # TODO(blacknon): iterm2のファイルは、環境変数の値に応じて読み込ませるかどうかを分岐させる
  cat ~/dotfiles/{sh/{alias.sh,export.sh,other.sh,functions/{common.sh,exec_1.sh,exec_2.sh,keybind.sh,replace.sh,iterm2.sh}},bash/{prompt.bash,other.bash,keybind.bash}} \
    ~/_shell/{boco/sh_function_boco,substitute_line/sh_function_substitute_line} \
    ~/_env/sh_function_lvim |
    eval $BASE64_CMD
}

# 現在使っているfunctionや環境変数、aliasをbase64にして返す関数
# setでfunction/envを、aliasでエイリアスを取得させる
____get_envdata() {
  local SET_DATA
  local ALIAS
  local BASE64_CMD

  case ${OSTYPE} in
  darwin*) BASE64_CMD="base64" ;;
  linux*) BASE64_CMD="base64 -w0" ;;
  esac

  # 各種データの取得
  # SHELLの種類に応じて処理を変える必要がある
  case $(basename ${SHELL}) in
  zsh*)
    SET_DATA=$(cat <(declare) <(declare -f))
    ALIAS=$(alias | sed 's/^/alias /')
    ;;
  bash*)
    SET_DATA=$(set | sed -e'/^'{BASHOPTS,BASH_VERSINFO,EUID,PPID,SHELLOPTS,UID,HOME,PWD,HISTFILE,CDHISTFILE}'/d')
    ALIAS=$(alias)
    ;;
  esac

  # base64にして返す
  # その他、以下の環境変数やaliasを定義する
  #   - cd_history
  #   - vim=lvim
  cat \
    <(echo "${SET_DATA}") \
    <(echo "${ALIAS}") \
    <(echo "export CDHISTFILE=~/cd_history") \
    <(echo "alias vim=lvim") | eval ${BASE64_CMD}
}
