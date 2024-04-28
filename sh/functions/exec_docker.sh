#!/bin/bash
# Copyright(c) 2023 Blacknon. All rights reserved.
# Use of this source code is governed by an MIT license
# that can be found in the LICENSE file.

# ABOUT:
#     コマンド代わりに使用するためのfunctionを記載しているファイル。
#     docker系のfunctionを記述する。
### -------------------------------------------------------------

## ==========
# Docker関係
## ==========

# TODO(blacknon): 操作ログを取得させる(scriptコマンド？)
# dockerコンテナを起動してログインするためのfunction。
# usage:
#     docker_runin コンテナ名
#     docker_runin -e コンテナ名 # 現在のfunctionを利用して起動・ログイン
#     docker_runin -r コンテナ名 # rcファイルを利用して起動・ログイン
#     docker_runin -v ローカルPATH:コンテナPATH コンテナ名 # マウント指定(-r/-eオプション併用可)
# NOTE: docker-machine環境下でvolume mountがうまくいかなくなった場合、とりあえずアップグレードすることで直る場合がある。まずはそれをやってみること。
docker_runin() {
  # container
  local cnt

  # flag
  local is_rc
  local is_env

  # arg
  local volarg
  local volume

  # optionをパース
  local opt
  while getopts ":rev:" opt; do
    case "$opt" in
    r) is_rc=1 ;;
    e) is_env=1 ;;
    v) volume=${OPTARG} ;;
    esac
  done

  # セレクトするコマンドの有無によって切り替えをする
  # (peco>bocoの順に確認)
  if type "peco" >/dev/null 2>&1; then
    local selecter="peco"
  elif type "boco" >/dev/null 2>&1; then
    # printfで制御コードを出力させないオプションを付与する
    local selecter="boco"
  fi

  # セレクトに使うコマンドがbocoの場合、長い行を表示させるために以下のコマンドを実行する
  if [[ ${selecter} =~ ^boco ]]; then
    printf '\033[?7l'
  fi

  # 入るコンテナを選択する
  cnt=$(docker image ls | awk 'NR>1{print $1}' | sort | uniq | eval $selecter | tr -d $'\n')

  # contaner check
  if [ "${cnt}" = "" ]; then
    echo "not set container"
    return
  fi

  # volume mount option
  if [ ! "${volume}" = "" ]; then
    volarg="-v ${volume}"
  fi

  # dockerへの接続前に実行するコマンド
  eval "${EXEC_BEFORE_DOCKER_IN}"

  # ~/.docker_historyをtouchしておく
  mkdir -p "$(dirname ${DOCKER_HISTORY})"
  touch "${DOCKER_HISTORY}"

  # docker runをして接続する
  if [[ ${is_rc} -eq 1 ]]; then
    local cmd="'bash --rcfile <(echo $(____get_rcdata)|base64 -d)'"
    eval docker run -v "${DOCKER_HISTORY}:/root/.bash_history" --rm "${volarg}" -it "${cnt}" bash -c "${cmd}"
  elif [[ ${is_env} -eq 1 ]]; then
    local cmd="'bash --rcfile <(echo $(____get_envdata)|base64 -d)'"
    eval docker run -v "${DOCKER_HISTORY}:/root/.bash_history" "${volarg}" --rm -it "${cnt}" bash -c "${cmd}"
  else
    eval docker run -v "${DOCKER_HISTORY}:/root/.bash_history" "${volarg}" --rm -it "${cnt}" bash
  fi

  # dockerへの接続後に実行するコマンド
  eval "${EXEC_AFTER_DOCKER_IN}"
}

# TODO(blacknon): 操作ログを取得させる(scriptコマンド？)
# TODO(blacknon): -vは対応しない(できない)が、historyの同期をどうやるべきか考えておく。
# 起動中のdockerコンテナにログインするためのfunction。
# usage:
#     docker_login コンテナ名
#     docker_login -e コンテナ名 # 現在のfunctionを利用してログイン
#     docker_login -r コンテナ名 # rcファイルを利用してログイン
docker_login() {
  # container
  local cnt

  # flag
  local is_rc
  local is_env

  # optionをパース
  local opt
  while getopts ":re:" opt; do
    case "$opt" in
    r) is_rc=1 ;;
    e) is_env=1 ;;
    esac
  done

  # セレクトするコマンドの有無によって切り替えをする
  # (peco>bocoの順に確認)
  if type "peco" >/dev/null 2>&1; then
    local selecter="peco"
  elif type "boco" >/dev/null 2>&1; then
    # printfで制御コードを出力させないオプションを付与する
    local selecter="boco -p -q"
  fi

  # セレクトに使うコマンドがbocoの場合、長い行を表示させるために以下のコマンドを実行する
  if [[ ${selecter} =~ ^boco ]]; then
    printf '\033[?7l'
  fi

  # 入るコンテナを選択する
  cnt=$(docker ps | awk 'NR>1{print $2"("$1")"}' | sort | uniq | eval $selecter)

  # contaner check
  if [ "${cnt}" = "" ]; then
    echo "not set container"
    return
  fi

  # `()`で囲まれた内容(コンテナID)を抽出
  cnt=$(awk -F'[)(]' '{print $2}' <<<"${cnt}")

  # dockerへの接続前に実行するコマンド
  eval "${EXEC_BEFORE_DOCKER_IN}"

  # docker runをして接続する
  if [[ ${is_rc} -eq 1 ]]; then
    local cmd="bash --rcfile <(echo $(____get_rcdata)|base64 -d)"
    docker exec -it "${cnt}" bash -c "${cmd}"
  elif [[ ${is_env} -eq 1 ]]; then
    local cmd="bash --rcfile <(echo $(____get_envdata)|base64 -d)"
    docker exec -it "${cnt}" bash -c "${cmd}"
  else
    docker exec -it "${cnt}" bash
  fi

  # dockerへの接続後に実行するコマンド
  eval "${EXEC_AFTER_DOCKER_IN}"
}
