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
# ファイル/ディレクトリ操作関係
## ==========

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

# 受け付けたリストのurlに対し、curlでアクセスして諸々のデータをまとめるコード
# httpステータスやレスポンスサイズ、バナーヘッダなどが考えられる？

# 指定したPIDのプロセスをサスペンドする
# TODO: 作る
# p_suspend() {}

# 指定したサスペンドされているプロセスを再開する
# TODO: 作る。なお、対象のプロセスを補完で処理できるように考慮する
# 参考: https://unix.stackexchange.com/questions/2107/how-to-suspend-and-resume-processes
# p_resume() {}
