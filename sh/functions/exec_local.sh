#!/bin/bash
# Copyright(c) 2024 Blacknon. All rights reserved.
# Use of this source code is governed by an MIT license
# that can be found in the LICENSE file.

# ABOUT:
#     コマンド代わりに使用するためのfunctionを記載しているファイル。
#     local machineでしか実行しない想定のもののみを記述。
### -------------------------------------------------------------

## ==========
# ファイル/ディレクトリ操作関係
## ==========

# Workディレクトリの作成・移動
ww() {
  # local変数を定義
  local today_dir="$HOME/Work/$(date +%Y%m)/$(date +%Y%m%d)"

  # ${today_dir}が存在しない場合
  if [ ! -d ${today_dir} ]; then
    # local machineか否かを識別
    if [ -z "${SSH_CLIENT}" ]; then
      # local machineの場合
      case ${OSTYPE} in
      darwin*)
        mkworkln.sh ~/dotfiles/lib/docktemplete_downloads.txt ~/dotfiles/lib/docktemplete_parallels.txt
        ;;
      linux*)
        mkworkln.sh
        ;;
      esac
    else
      # ssh接続をしている場合
      mkdir -p "${today_dir}" && cd "${today_dir}"
      if [[ ! -f "${today_dir}/today_memo.md" ]]; then
        touch "${today_dir}/today_memo.md"
      fi
    fi
  fi

  cd "${today_dir}"
  echo "${today_dir}"
}

# 本日のDownloadディレクトリへの遷移用function
wd() {
  local today_dir="$HOME/Work/$(date +%Y%m)/$(date +%Y%m%d)"
  cd ${today_dir}/Downloads
}

# 現在いるWorkディレクトリを識別し、その前日のディレクトリへ移動する
yw() {
  # 変数の宣言
  local target_day

  # 現在いるディレクトリがWorkディレクトリの場合
  if [[ $PWD =~ $HOME/Work/[0-9]{6}/[0-9]{8} ]]; then
    local directory_day=$(echo $PWD | sed -r "s,$HOME/Work/[0-9]{6}/,,")
    local target_day=$(date +%Y-%m-%d -d "$directory_day -1day")
  else
    # 現在ディレクトリがWorkディレクトリでない場合、昨日ディレクトリを直接指定
    local target_day=$(date +%Y-%m-%d -d '-1day')
  fi

  local yesterday_dir="$HOME/Work/$(date +%Y%m -d ${target_day})/$(date +%Y%m%d -d ${target_day})"
  if [[ -d ${yesterday_dir} ]]; then
    cd ${yesterday_dir}
    echo ${yesterday_dir}
  fi
}

# 現在いるWorkディレクトリを識別し、その翌日のディレクトリへ移動する
tw() {
  # 変数の宣言
  local target_day

  # 現在いるディレクトリがWorkディレクトリの場合
  if [[ $PWD =~ $HOME/Work/[0-9]{6}/[0-9]{8} ]]; then
    local directory_day=$(echo $PWD | sed -r "s,$HOME/Work/[0-9]{6}/,,")
    local target_day=$(date +%Y-%m-%d -d "$directory_day +1day")
  else
    # 現在ディレクトリがWorkディレクトリでない場合、翌日ディレクトリを直接指定
    local target_day=$(date +%Y-%m-%d -d '+1day')
  fi

  local tomorrow_dir="$HOME/Work/$(date +%Y%m -d ${target_day})/$(date +%Y%m%d -d ${target_day})"
  if [[ -d ${tomorrow_dir} ]]; then
    cd ${tomorrow_dir}
    echo ${tomorrow_dir}
  fi
}

## ==========
# snippet用function(petコマンド関係)
## ==========

# 直前に実行したコマンドをpetに登録する
prev() {
  local prev=$(fc -lrn | head -n 1)
  sh -c "pet new $(printf %q "$prev")"
}

# petからsnippetを実行する(実行後はhistoryに登録)
pe() {
  local cmd=$(pet search)
  eval $cmd
  print -s "${cmd//\\n/\\\\n}"
}

## ==========
# 環境依存系
## ==========

# バッテリー残量を取得
battery() {
  case ${OSTYPE} in
  darwin*)
    pmset -g ps | awk '/InternalBattery/{gsub(";","",$3);print $3}'
    ;;
  linux*)
    cat /sys/class/power_supply/BAT*/capacity | awk '{a=a+$0}END{printf("%3d%\n", a/NR)}'
    ;;
  esac
}

## ==========
# 開発補助用function
## ==========

# make install を一気に行うためのfunction
mkinst() {
  make && sudo make install && make clean
}

## ==========
# プロジェクト関係用function
## ==========

# my-pjのwrapper用関数. functionとして動かすcd/archiveをサブコマンドとして置き換えて使用するためのもの.
my-pj() {
  case $1 in
  # my-pjのディレクトリへcdする
  cd)
    shift
    local dir="$(command my-pj list $@ | peco | awk -F $'\t' '{print $NF}')"

    # $dirがない場合、カレントディレクトリを指定する
    if [[ "${dir}" == "" ]]; then
      dir="$(pwd)"
    fi

    echo "${dir}"
    cd "${dir}" || echo "cd error: Not found :${dir}"
    ;;

  # 引数をそのままmy-pjへ渡す
  *)
    command my-pj "$@"

    ;;

  esac
}
