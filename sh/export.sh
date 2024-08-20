#!/bin/bash
# Copyright(c) 2023 Blacknon. All rights reserved.
# Use of this source code is governed by an MIT license
# that can be found in the LICENSE file.

# TODO: awkのfunctionとかを環境変数につっこんでおく
# TODO: awkのaliasで↑の環境変数を読み込ませておく
#       ex.)
#         ```bash
#         export HOGE="function abc(x){return x\"と\"x}"
#         seq 1 3 | awk -f <(echo $HOGE) --source '{print abc($1)}'
#         ```
# TODO: awkで使える区切り文字等の正規表現系の値を↓のような感じで整理してexportしておく
#       ex.) 設定例
#         ```bash
#         export ENVVALUE_AWK_CSVSEP=""'"[^"]*"|[^,]*'
#         ```
#
#       ex.) 使用例
#         ```bash
#         cat xyz.csv | awk -v FPAT=$ENVVALUE_AWK_CSVSEP -v OFS="---" '{print $1,$2}'
#         ```
# TODO: awkやsedのワンライナーでよく使うコードとかを環境変数に入れておいて、差し込みをするような使い方について模索してみる

# XDG Base Directoryの定義を行う
# =======================================================
# ユーザー個別の設定が書き込まれるディレクトリ (/etc と類似).
if [ -z "${XDG_CONFIG_HOME}" ]; then
  if [ -z "${SSH_CLIENT}" ]; then
    export XDG_CONFIG_HOME="${HOME}/.config"
  else
    export XDG_CONFIG_HOME="${HOME}"
  fi
fi

# ユーザー個別の重要でない (キャッシュ) データが書き込まれるディレクトリ (/var/cache と類似).
if [ -z "${XDG_CACHE_HOME}" ]; then
  if [ -z "${SSH_CLIENT}" ]; then
    export XDG_CACHE_HOME="${HOME}/.cache"
  else
    export XDG_CACHE_HOME="${HOME}"
  fi
fi

# ユーザー個別のデータファイルが書き込まれるディレクトリ (/usr/share と類似).
if [ -z "${XDG_DATA_HOME}" ]; then
  if [ -z "${SSH_CLIENT}" ]; then
    export XDG_DATA_HOME="${HOME}/.local/share"
  else
    export XDG_DATA_HOME="${HOME}"
  fi
fi

# ユーザー個別の状態ファイルをが書き込まれるディレクトリ (/var/lib と類似).
if [ -z "${XDG_STATE_HOME}" ]; then
  if [ -z "${SSH_CLIENT}" ]; then
    export XDG_STATE_HOME="${HOME}/.local/state"
  else
    export XDG_STATE_HOME="${HOME}"
  fi
fi

# ユーザー個別の状態ファイルをが書き込まれるディレクトリ (/var/lib と類似).
if [ -z "${XDG_RUNTIME_DIR}" ]; then
  if [ -z "${SSH_CLIENT}" ]; then
    export XDG_RUNTIME_DIR="${HOME}/.run"
  fi
fi

# XDG Base Directoryの設定に伴うPATH指定処理
# =======================================================
# aws-cli
export AWS_SHARED_CREDENTIALS_FILE="${XDG_CONFIG_HOME}/aws/credentials"
export AWS_CONFIG_FILE="${XDG_CONFIG_HOME}/aws/config"

# azure-cli
export AZURE_CONFIG_DIR="${XDG_DATA_HOME}/azure"

# docker
export DOCKER_CONFIG="${XDG_CONFIG_HOME}/docker"

# rust cargo
export CARGO_HOME="${XDG_DATA_HOME}/cargo"

# rust rustup
export RUSTUP_HOME="${XDG_DATA_HOME}/rustup"

# python
export PYTHONSTARTUP="${XDG_CONFIG_HOME}/python/.pythonstartup"
export PYLINTHOME="${XDG_CACHE_HOME}/pylint"

# Ruby gem
export GEM_HOME="${XDG_DATA_HOME}/gem"
export GEM_SPEC_CACHE="${XDG_CACHE_HOME}/gem"

# GnuPG
export GNUPGHOME="${XDG_DATA_HOME}/gnupg"

# Packer
export PACKER_CONFIG_DIR="${XDG_CONFIG_HOME:-${HOME}/.config}/packer"
export PACKER_CACHE_DIR="${XDG_CACHE_HOME:-${HOME}/.cache}/packer"

# PostgreSQL
export PSQLRC="${XDG_CONFIG_HOME}/pg/psqlrc"
export PSQL_HISTORY="${XDG_CACHE_HOME}/pg/psql_history"
export PGPASSFILE="${XDG_CONFIG_HOME}/pg/pgpass"
export PGSERVICEFILE="${XDG_CONFIG_HOME}/pg/pg_service.conf"

# NodeJS
export NODE_REPL_HISTORY="${XDG_DATA_HOME}/node_repl_history"

# npm
export NPM_CONFIG_USERCONFIG="${XDG_CONFIG_HOME}/npm/npmrc"

# wget
# WGETRCはローカルホスト以外では使用しない
if [ -z "${XDG_CONFIG_HOME}" ]; then
  if [ -z "${SSH_CLIENT}" ]; then
    export WGETRC="${XDG_CONFIG_HOME}/wgetrc"
  fi
fi

# Gradle
export GRADLE_USER_HOME="$XDG_DATA_HOME"/gradle

# X Window System(x11)
case ${OSTYPE} in
darwin*)
  export XAUTHORITY="${HOME}/.Xauthority"
  ;;
linux*)
  export XAUTHORITY="${XDG_CACHE_HOME}/Xauthority"
esac
export ICEAUTHORITY="${XDG_CACHE_HOME}/ICEauthority"

# color code
# =======================================================
export COLOR_RED=$'\E[0;31m'
export COLOR_GREEN=$'\E[0;32m'
export COLOR_ORANGE=$'\E[0;33m'
export COLOR_BLUE=$'\E[0;34m'
export COLOR_PURPLE=$'\E[0;35m'
export COLOR_CYAN=$'\E[0;36m'
export COLOR_LGRAY=$'\E[0;37m'
export COLOR_DGRAY=$'\E[1;30m'
export COLOR_LRED=$'\E[1;31m'
export COLOR_LGREEN=$'\E[1;32m'
export COLOR_YELLOW=$'\E[1;33m'
export COLOR_LBLUE=$'\E[1;34m'
export COLOR_LPURPLE=$'\E[1;35m'
export COLOR_LCYAN=$'\E[1;36m'
export COLOR_WHITE=$'\E[1;37m'
export COLOR_NONE=$'\E[0m'

# set less color(manで見るときのcolor code)
# =======================================================
export LESS_TERMCAP_mb="${COLOR_LRED}"
export LESS_TERMCAP_md="${COLOR_PURPLE}"
export LESS_TERMCAP_me="${COLOR_NONE}"
export LESS_TERMCAP_se="${COLOR_NONE}"
export LESS_TERMCAP_so=$'\E[01;44;32m'
export LESS_TERMCAP_ue="${COLOR_NONE}"
export LESS_TERMCAP_us="${COLOR_YELLOW}"

# PATH
# =======================================================
# GOPATH(PATHより前に定義)
export GOPATH="${HOME}/_go"

# 最後に存在チェックして突っ込んでくPATHリスト
PATH_LIST=()

case ${OSTYPE} in
darwin*)
  # PATH
  PATH_LIST+=("${GOPATH}/bin")
  PATH_LIST+=("${HOME}/dotfiles/AppleScripts")
  PATH_LIST+=("/usr/local/opt/ncurses/bin")
  PATH_LIST+=("/usr/local/opt/mysql-client/bin")
  PATH_LIST+=("/usr/local/opt/openssl@1.1/bin")
  PATH_LIST+=("/usr/local/opt/icu4c/bin")

  # DYLD_LIBRARY_PATH
  export DYLD_LIBRARY_PATH="/opt/homebrew/lib:$DYLD_LIBRARY_PATH"

  # LIBRARY_PATH
  export LIBRARY_PATH="${LIBRARY_PATH}:/usr/local/opt/ncurses/lib/"

  # LDFLAGS
  export LDFLAGS=" -L/usr/local/opt/ncurses/lib"
  export LDFLAGS=${LDFLAGS}" -L/usr/local/opt/openssl@1.1/lib"

  # CPPFLAGS
  export CPPFLAGS=" -I/usr/local/opt/ncurses/include"
  export CPPFLAGS=${CPPFLAGS}" -I/usr/local/opt/openssl@0.1/include"
  ;;
linux*)
  # PATH
  PATH_LIST+=("${GOPATH}/bin")
  PATH_LIST+=("/usr/local/go/bin")
  ;;
esac

PATH_LIST+=("${CARGO_HOME}/bin")             # Rust(Cargo)用PATH
PATH_LIST+=("${XDG_CONFIG_HOME}/vendor/bin") # php(composer)用のPATH
PATH_LIST+=("${GEM_HOME}/ruby/bin")          # Ruby gem用PATH
PATH_LIST+=("${HOME}/.nodebrew/current/bin") # NodeJS用PATH
PATH_LIST+=("${XDG_DATA_HOME}/npm/bin")      # npm用PATH
PATH_LIST+=("${HOME}/.local/bin")            # Python(pip)用PATH
PATH_LIST+=("${HOME}/.nimble/bin")           # Nim用PATH
PATH_LIST+=("${HOME}/bin")                   # 自作スクリプト群の配置用ディレクトリPATH
PATH_LIST+=("${HOME}/dotfiles/bin")          # 自作スクリプト群の配置用ディレクトリPATH
PATH_LIST+=("/user/local/bin")               # 上書きするため

# OSXの場合
case ${OSTYPE} in
darwin*)
  # PATH
  # arm64版のMacだった場合、homebrewのディレクトリが/opt/homebrew/binに変わっているためPATHに追加
  if [[ "$(uname -m)" == "arm64" ]]; then
    PATH_LIST+=("/opt/homebrew/bin")
  fi
  ;;
esac

# PATHを一気に追加
for p in "${PATH_LIST[@]}"; do
  if [ -d "$p" ]; then
    export PATH="$p:$PATH"
  fi
done

# historys
# =======================================================
# docker history
export DOCKER_HISTORY="${XDG_STATE_HOME}/docker/docker_history"

# mysql history
export MYSQL_HISTFILE="${XDG_STATE_HOME}/mysql/mysql_history"

# less history
export LESSHISTFILE="${XDG_STATE_HOME}/less/history"

# その他
# =======================================================
# hwatch
export HWATCH="--no-help-banner"

# less
export LESS="-R" # lessでスクロールが効くようにする

# bat
export BAT_PAGER="less -RF" # batのpagerを設定
export BAT_THEME="Coldark-Dark" # batのColor Theme

# python encode
export PYTHONIOENCODING='UTF-8'

# editor
export EDITOR='vim'

# ssh agent用のsockファイル
if [ -z "${SSH_CLIENT}" ]; then
  export SSH_AUTH_SOCK="$XDG_CACHE_HOME/ssh/agent" # ssh-agentのSOCK用PATH
fi
