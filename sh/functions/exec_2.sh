#!/bin/bash
# Copyright(c) 2023 Blacknon. All rights reserved.
# Use of this source code is governed by an MIT license
# that can be found in the LICENSE file.

# ABOUT:
#     コマンド代わりに使用するためのfunctionを記載しているファイル。
#     tmuxやssh接続先では利用しないような、基本的にローカルでしか利用しないものを定義
### -------------------------------------------------------------

# TODO(blacknon): 指定した区切り文字を使って、その方向にdiffをするfunction(or script)
#                 => hwatchのログをdiffするためのscriptとして。応用を考えたらjqにかましたあとのほうが良いのかも？という理由。
#                    とはいえ、もしかしたら最初からpythonでjsonのdiffをするscriptを作ったほうがいいのかも…

## ==========
# 文字列操作系
## ==========

# TODO(blacknon): オプションで結合文字列を指定できるようにする。
# TODO(blacknon): 結合する配列をパイプから受け付けるようにする。
# TODO(blacknon): parseする文字をオプションで指定できるようにする。
# Join array
joinby() {
  #
  local IFS="$1"
  shift
  echo "$*"
}

# 指定したカラムだけを出力する(select column)
# selc() {}

# 指定したカラムを除外して出力する(delete column)
# delc() {}

## ==========
# エンコード/デコード関係
## ==========
# パイプから受け付けたjsonをurlencodeして出力するfunction(要php)
json2url() {
  # optionをパース
  local opt
  while getopts ":e" opt; do
    case "$opt" in
    e) local is_enc=1 ;;
    esac
  done

  # 変換対象を変数に代入
  local data
  data="$(cat)"

  if [ "${is_enc}" -eq 1 ]; then
    echo "${data}" | php -r 'echo http_build_query(json_decode(trim(fgets(STDIN)),true));'
  else
    echo "${data}" | php -r 'echo urldecode(http_build_query(json_decode(trim(fgets(STDIN)),true)));'
  fi
}

# パイプから受け付けたurl encodeされたパラメータをjsonにして出力するfunction(要php)
url2json() {
  # optionをパース
  local opt
  while getopts ":e" opt; do
    case "$opt" in
    e) local is_enc=1 ;;
    esac
  done

  # 変換対象を変数に代入
  local data
  data="$(cat)"

  echo "${data}" | php -r 'parse_str(fgets(STDIN),$parsed);echo json_encode($parsed);'
}

## ==========
# ファイル操作関係
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

# 上のディレクトリに移動するfunction.
# cd(Change Directory) → ud(Up Directory)
# ...という命名方式
ud() {
  local num
  if [ $# -ne 1 ]; then
    num=1
  else
    num=$1
  fi

  eval cd $(perl -le 'print "../" x '$num)
}

# gitリポジトリのルートディレクトリに移動する
gcd() {
  # gitディレクトリ配下か確認する
  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    cd $(git rev-parse --show-toplevel)
  fi

  # shellに応じて処理を変える
  case $(basename ${SHELL}) in
  zsh*) zle .accept-line ;;
  esac
}

# gitリポジトリ内のディレクトリを選択して移動する
gscd() {
  # ローカル変数の宣言
  local selecter

  # セレクトするコマンドの有無によって切り替えをする
  # (peco>bocoの順に確認)
  if type "peco" >/dev/null 2>&1; then
    local selecter="peco"
  elif type "boco" >/dev/null 2>&1; then
    local selecter="boco"
  fi

  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    dir=$(
      cd $(git rev-parse --show-toplevel)
      find ./ -name .git -prune -or -type d | sort | $selecter
    )

    if [[ -n "$dir" ]]; then
      cd "$(git rev-parse --show-toplevel)/$dir"
    fi
  fi

  # shellに応じて処理を変える
  case $(basename ${SHELL}) in
  zsh*) zle .accept-line ;;
  esac
}

# TODO(blacknon): moreutilsの有無のチェックを追加
# TODO(blacknon): moreutilsなしでできるようにする？
# TODO(blacknon): sortのオプションを付与できるようにする
# sortしてその内容をそのまま保存する
# ※ moreutils必須
sortsave() {
  local file=$1
  sort -u $file | sponge $file
}

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
# ターミナルログ関係
## ==========
# TODO(blacknon): コマンドの実行をするオプションを追加する(引数にする)
# TODO(blacknon): 引数で出力先を指定させる(-fオプション)
# TODO(blacknon): オプションでタイムスタンプの付与を指定する(-tオプション)
# scriptコマンドで/Work配下にターミナルログを記録する
sc() {
  : ----------
  : usage:
  : "  sc \"[-f logpath,-t]\" \"[command...]\""
  : ----------

  # local変数を宣言
  local is_timestamp
  local term_log
  local cmd

  # optionをパース
  local opt
  while getopts "f:t" opt; do
    case "${opt}" in
    f)
      term_log="${OPTARG}"
      ;;
    t)
      is_timestamp=1
      ;;
    esac
  done

  shift $((OPTIND - 1))

  # commandを変数に格納する
  cmd="${@}"

  # -fオプションでterm_logの指定がない場合、デフォルトPATHにする
  # Default: ${HOME}/Work/%Y%m/%Y%m%d/log/%Y%m%d_%H%M%S_script.log
  if [ -z "${term_log}" ]; then
    # workdir を作成
    local workdir=$(date "+$HOME/Work/%Y%m/%Y%m%d/log")
    mkdir -p "${workdir}"

    # term_logを指定
    term_log="${workdir}/$(date +%Y%m%d_%H%M%S.log)"
  fi

  # scriptコマンドはOSによって挙動が異なるので、処理を分ける
  case "${OSTYPE}" in
  darwin*)
    if [ "${is_timestamp}" -eq "1" ]; then
        term_log=">(gawk '{print strftime(\"%F %T \") \$0}{fflush()}' >> ${term_log})"
    fi

    if [ -z "${cmd}" ]; then
      eval script -aq -F ${term_log}
    else
      eval script -aq -F ${term_log} ${@}
    fi
    ;;
  linux*)
    if [ "${is_timestamp}" -eq "1" ]; then
        term_log=">(awk '{print strftime(\"%F %T \") \$0}{fflush()}' >> ${term_log})"
    fi

    if [ -z "${cmd}" ]; then
      eval script -aq -f ${term_log}
    else
      eval script -aq -f ${term_log} -c "${@}"
    fi
    ;;
  esac
}

# 完全にlocalで実行する用のscのラッパーfunction。
# bashrcをsourceした状態で引数のコマンドを実行させるので、functionも実行できるようにする。
scx() {
  eval sc bash -c "'source ~/.bashrc 2>/dev/null;${@}'"
}

## ==========
# 開発補助用function
## ==========

# make install を一気に行うためのfunction
mkinst() {
  make && sudo make install && make clean
}

# 受け付けたリストのurlに対し、curlでアクセスして諸々のデータをまとめるコード
# httpステータスやレスポンスサイズ、バナーヘッダなどが考えられる？

# 指定したPIDのプロセスをサスペンドする
# TODO: 作る
# p_suspend() {}

# 指定したサスペンドされているプロセスを再開する
# TODO: 作る。なお、対象のプロセスを補完で処理できるように考慮する
# 参考: https://unix.stackexchange.com/questions/2107/how-to-suspend-and-resume-processes
# p_resume() {}

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
