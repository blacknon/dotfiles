#!/bin/bash
# Copyright(c) 2023 Blacknon. All rights reserved.
# Use of this source code is governed by an MIT license
# that can be found in the LICENSE file.

# ABOUT:
#     コマンド代わりに使用するためのfunctionを記載しているファイル。
#     tmuxでもssh先でも利用する、汎用的なものを定義。
### -------------------------------------------------------------

# TODO(blacknon):
#     gistや変数に代入したpetのデータからsnippetを取得して選択・実行するfunctionを作成する
#     (どの環境でもpetのsnippetを利用できるような状態にしたい…Base64+zipでデータのやり取りする感じだろうか？)

# TODO(blacknon):
#     ccze的なfunctionの作成(ssh先でも使用するため)

# TODO(blacknon):
#     historyの同期用function(仕様等ふくめ完全に未定)
#     - (できれば)他のクライアントとも同期したい
#     - (できれば)ssh先やdockerと同期したい

# TODO(blacknon): csv2jsonとか、json2csvとかでfunctionを作る(どこでも使えるように)

## ==========
# 文字列操作系
## ==========

# 標準入力で受け付けた行頭にタイムスタンプ(YYYY-MM-DD HH:MM:SS: )を付与する
ts() {
  # カラーコードの設定
  local COLOR_START
  local COLOR_END
  if [ -t 1 ]; then
    COLOR_START="${COLOR_YELLOW}"
    COLOR_END="${COLOR_NONE}"
  fi

  # perlで処理
  perl -lne '
      use POSIX "strftime";
      $t = strftime "'${COLOR_START}'%Y-%m-%d %H:%M:%S: '${COLOR_END}'", localtime;
      print($t,$_);
    '
}

# あいまいgrepをするfunction
# (1文字違う文字列(abc=>{.bc,a.c,ab.})と、1文字ずつずらした文字列(abc=>{abc,bac,acb})でgrepをする(typoも発見できる))
aigrep() {
  unset GETOPT_COMPATIBLE
  while [ $# -gt 0 ]; do
    case $1 in
    -o) local grep_option=("${grep_option}" "${1}") ;;
    -R) local grep_option=("${grep_option}" "${1}") ;;
    -A) local grep_option=("${grep_option}" "${1}${2}") ;;
    -B) local grep_option=("${grep_option}" "${1}${2}") ;;
    -C) local grep_option=("${grep_option}" "${1}${2}") ;;
    -m) local grep_option=("${grep_option}" "${1}${2}") ;;
    *) local str="${1}" ;;
    esac
    shift
  done

  local shift_str=($(____shift1chars ${str}))
  local regex_str=($(____1char2dotchar ${str}))
  local str_list=($shift_str $regex_str)

  case ${OSTYPE} in
  darwin*)
    grep=("ggrep" "--color=auto")
    ;;
  linux*)
    grep=("grep" "--color=auto")
    ;;
  esac

  if [ -p /dev/stdin ]; then
    cat - | ${grep[@]} ${grep_option[@]} -f <(
      IFS=$'\n'
      echo "${str_list[*]}"
    )
  else
    ${grep[@]} ${grep_option[@]} -f <(
      IFS=$'\n'
      echo "${str_list[*]}"
      :
    ) ${@:2}
  fi
}

# 標準入力で受けたCamelCase => snake_caseの変換を行う
camel2snake() {
  # OS別での使用コマンドの識別
  case ${OSTYPE} in
  darwin*) local sed="gsed" ;;
  linux*) local sed="sed" ;;
  esac

  cat | ${sed} -E 's/(.)([A-Z])/\1_\2/g' | tr '[A-Z]' '[a-z]'
}

# 標準入力で受けたsnake_case => CamelCaseの変換を行う
snake2camel() {
  # OS別での使用コマンドの識別
  case ${OSTYPE} in
  darwin*) local sed="gsed" ;;
  linux*) local sed="sed" ;;
  esac

  cat | ${sed} -r 's/.*/\L\0/g; s/_([a-z0-9])/\U\1/g;'
}

## ==========
# エンコード/デコード関係
## ==========

# TODO(blacknon): 2進数、8進数、16進数の変換処理をするfunctionを生成しておく(perlでいいや)
# 標準入力から取得した値をパーセントエンコーディングする
#     -n ... nkfを使用してパーセントエンコーディングする(-a,-zは無効化)
#     -a ... ascii文字含め全部をパーセントエンコーディングする(-nのときは無効)
#     -z ... Null区切りにして改行もパーセントエンコーディング対象とする
enc_url() {
  # optionをパース
  local opt
  while getopts azn opt; do
    case $opt in
    a) local flg_a=1 ;;
    z) local flg_z=1 ;;
    n) local flg_n=1 ;;
    esac
  done
  shift $((OPTIND - 1))

  # flag_n(use nkf)の場合、nkfがPATHにない場合エラーにする
  which nkf 2>&1 >/dev/null
  if [[ $? -ne 0 ]];then
    echo "nkfコマンドがありません"
    return 1
  fi

  # 変換対象を変数に代入
  local data
  data="$(cat)"

  # -nオプションの有無でnkfを利用するか否かを指定する
  if [[ $flg_n -eq 1 ]]; then
    printf "%s" "${data}" | nkf -WwMQ | sed 's/=$//g' | tr = % | tr -d '\n'
  else
    # -a オプションの有無でPerlのコードを変更
    local perl_code
    if [[ $flg_a -eq 1 ]]; then
      perl_code='
      use URI::Escape;
      $uri=uri_escape_utf8($_,"^.");
      print uri_escape_utf8($uri, ".")
    '
    else
      perl_code='
      use URI::Escape;
      print uri_escape_utf8($_)
    '
    fi

    # -z オプションの有無でPerlのオプションを変更して実行
    if [[ $flg_z -eq 1 ]]; then
      printf "%s" "${data}" | eval perl -0lne "'"${perl_code}"'"
    else
      printf "%s" "${data}" | eval perl -lne "'"${perl_code}"'"
    fi
  fi
}

# 標準入力から取得したパーセントエンコーディングを戻す
dec_url() {
  cat - | perl -lne 'use URI::Escape; print uri_unescape($_)'
}

# 標準入力から取得した値をhtmlエンティティ形式に変換する
enc_html() {
  # optionをパース
  local opt
  while getopts azx opt; do
    case $opt in
    a) local flg_a=1 ;;
    x) local flg_x=1 ;;
    z) local flg_z=1 ;;
    esac
  done

  # 変換対象を変数に代入
  local data
  data="$(cat)"

  # -a オプションの有無でPerlのコードを変更
  local perl_code
  if [[ $flg_a -eq 1 ]]; then
    perl_code='use HTML::Entities;$ent = encode_entities($_,"^.");print encode_entities($ent, ".")'
  else
    perl_code='use HTML::Entities;print encode_entities($_);'
  fi

  # -x オプションがある場合、&#100;とか&lt;ではなく、すべてhexで変換した値を出力させる
  # (perlコードの置換処理で対応)
  if [[ $flg_x -eq 1 ]]; then
    perl_code=$(
      echo "${perl_code}" |
        sed -e 's/encode_entities/encode_entities_numeric/g' \
          -e 's/use HTML::Entities;/use HTML::Entities qw(encode_entities_numeric);/g'
    )
  fi

  # -z オプションの有無でPerlのオプションを変更して実行
  if [[ $flg_z -eq 1 ]]; then
    printf "%s" "${data}" | eval perl -0lne "'"${perl_code}"'"
  else
    printf "%s" "${data}" | eval perl -lne "'"${perl_code}"'"
  fi
}

# 標準入力から受付たhtmlエンティティ形式のデータをもとに戻す
dec_html() {
  cat - | perl -MHTML::Entities -le 'print decode_entities(<STDIN>);'
}

# 標準入力から取得した値をHex形式(\xXX)にして返す
enc_hex() {
  cat - | xxd -ps -c 0 | sed 's/../\\x&/g'
}

# 標準入力から取得した値をUnicode Escape Sequence形式に変換する
# ※ nkfが必要
enc_unicode() {
  # OS別での使用コマンドの識別
  case ${OSTYPE} in
  darwin*) local sed="gsed" ;;
  linux*) local sed="sed" ;;
  esac

  cat - |
    nkf -W -w32B0 |
    xxd -ps -c4 |
    ${sed} -r 's/^0{4}/\\u/' |
    tr -d \\n
  echo
}

# 標準入力から受け付けたjwtトークンをDecodeする
dec_jwt() {
  # OS別での使用コマンドの識別
  case ${OSTYPE} in
  darwin*) local sed="gsed" ;;
  linux*) local sed="sed" ;;
  esac

  cat - | cut -d. -f1,2 | ${sed} 's/\./\n/g' | base64 --decode
}

## ==========
# ファイル操作関係
## ==========

# ファイルの入れ替え(スイッチ)
sw() {
  local tmpfile="$2.$(date +%Y%m%d_%H%M%S)"
  mv $2 $tmpfile
  mv $1 $2
  mv $tmpfile $1
}

# サイズの大きいファイルをサーチする
find_bigfile() {
  local target="$1"
  local max="$2"
  local data

  # OS別での使用コマンドの識別
  case ${OSTYPE} in
  darwin*) local numfmt="gnumfmt" ;;
  linux*) local numfmt="numfmt" ;;
  esac

  # numfmtが入ってる場合、サイズ表示を人間が読みやすいよう変更
  which $numfmt 2>/dev/null 1>/dev/null
  if [ $? -eq 0 ]; then
    data=$(find "${target}" -type f -ls | sort -k7nr | head "-${max}" | ${numfmt} --to=iec --field=7 )
  else
    data=$(find "${target}" -type f -ls | sort -k7nr | head "-${max}")
  fi

  # 結果を出力
  echo -n "$data" | tr -s '[:blank:]' | cut -d " " -f 8,12-
}

# make today dir
todaydir() {
  local today=$(date +%Y%m%d)
  mkdir -p ./$today
  cd ./$today
}

# tarファイル内のデータをlist表示するfunction。
tarls() {
  # ローカル変数を宣言
  local opt flag_l flag_z taropt

  # optionをパース
  while getopts "lz" opt; do
    case $opt in
    "l") flag_l=1 ;;
    "z") flag_z=1 ;;
    "*") return 1 ;;
    esac
  done

  shift $((OPTIND - 1))

  taropt="tf"

  if [[ ${flag_l} -eq 1 ]]; then
    taropt="${taropt}v"
  fi

  if [[ ${flag_z} -eq 1 ]]; then
    taropt="${taropt}z"
  fi

  tar "${taropt}" "${@}"
}

# TODO(blacknon): tarファイル内部の補完処理の追加(peco等で処理をさせる)
# TODO(blacknon): エラーチェックの追加
# tarファイル内のファイルを指定して標準出lflg_l力に書き出すfunction。
tarcat() {
  # ----------
  # usage:
  # tarcat "<path(tarfile)>"
  # ----------
  # ローカル変数の宣言
  local selecter target_archive_file target_file

  # 対象ファイルの取得
  target_archive_file="${1}"

  # セレクトするコマンドの有無によって切り替えをする
  # (peco>bocoの順に確認)
  if type "peco" >/dev/null 2>&1; then
    selecter="peco"
  elif type "boco" >/dev/null 2>&1; then
    selecter="boco"
  fi

  target_file="$(tarls ${target_archive_file} | ${selecter})"

  tar xfO- "${target_archive_file}" "${target_file}"
}

# TODO(blacknon): 検索対象とするファイル名をワイルドカード指定できるようにする
# TODO(blacknon): 複数のstringを指定できるようにする
# tarファイル内のファイルに対してgrep(相当の処理)を行うfunction。
# awkを利用する。 ※ GNU tarでないと動作しないので注意
targrep() {
  # usageを残しておく
  # ----------
  # usage:
  # targrep "<string>" "<filepath>"
  # ----------

  # local変数の宣言
  local file_name    # tarファイル内のファイル名
  local target_file  # 検索対象とするtarファイルの名称を指定(ワイルドカードに対応させる)
  local string       # 検索キーワード
  local port_get_cmd # tarコマンドから実行するコマンドの生成

  # optionをパース
  local opt
  while getopts "f:" opt; do
    case "$opt" in
    f) file_name=${OPTARG} ;;
    esac
  done

  # optionの分だけ引数をシフト
  shift $((OPTIND - 1))

  # 引数から値を指定
  string=$1
  target_file=$2

  # OSの種類に応じて使用するコマンドを変更
  # TODO(blacknon): Macの場合、コマンドがない場合はエラーになるように指定する
  case ${OSTYPE} in
  darwin*)
    local sed="gsed"
    local tar="gtar"
    ;;
  linux*)
    local sed="sed"
    local tar="tar"
    ;;
  esac

  # gnu-tar内部で実行するコマンドを生成
  # ex.)
  #   : 実行するtarコマンド
  #   tar xf /path/to/file.tar.gz --to-command awk '/string/{printf(\"%s:%s\\n\",ENVIRON[\"TAR_FILENAME\"],\$0)}'
  #
  #   : --to-commandで指定しているコマンド
  #   `awk '/string/{printf(\"%s:%s\\n\",ENVIRON[\"TAR_FILENAME\"],\$0)}'`
  cmd="awk '/${string}/{printf(\"%s:%s\\\\n\",ENVIRON[\"TAR_FILENAME\"],\$0)}'"

  # terminalが出力先の場合、ヒットしたstringに色をつける処理を追加する
  if [ -t 1 ]; then
    cmd="${cmd}|${sed} 's/${string}/\\x1b[32m&\\x1b[0m/g'"
  fi

  # tarを実行
  "${tar}" xf "${target_file}" --to-command "${cmd}"
}

# zipファイル内のデータをlist表示するfunction。
zipls() {
  # ローカル変数を宣言
  local opt zipopt

  # optionをパース
  while getopts l opt; do
    case $opt in
    "l") local flg_l=1 ;;
    "*") return 1 ;;
    esac
  done
  shift $((OPTIND - 1))

  if [[ $flg_l -eq 1 ]]; then
    zipopt="-Zs"
  else
    zipopt="-Z1"
  fi

  unzip "${zipopt}" "${@}"
}

# zipファイル内のファイルを指定して標準出力に書き出すfunction。
zipcat() {
  # ローカル変数の宣言
  local selecter target_archive_file target_file

  # 対象ファイルの取得
  target_archive_file="${1}"

  # セレクトするコマンドの有無によって切り替えをする
  # (peco>bocoの順に確認)
  if type "peco" >/dev/null 2>&1; then
    selecter="peco"
  elif type "boco" >/dev/null 2>&1; then
    selecter="boco"
  fi

  target_file="$(zipls ${target_archive_file} | ${selecter})"

  unzip -p ${target_archive_file} ${target_file}
}

# zipファイル内のデータに対してgrep(相当の処理)を行うfunction。
# zipgrep() {}

# rarファイル内のデータをlist表示するfunction。
rarls() {
  # optionをパース
  local opt
  while getopts l opt; do
    case $opt in
    "l") local flg_l=1 ;;
    esac
  done
  shift $((OPTIND - 1))

  if [[ $flg_l -eq 1 ]]; then
    unrar la "${@}"
  else
    unrar lb "${@}"
  fi
}

# rarファイル内のファイルを指定して標準出力に書き出すfunction。
# rarcat() {}

# rarファイル内のデータに対してgrep(相当の処理)を行うfunction。
# rargrep() {}

## ==========
# ネットワーク関係
## ==========

# ipアドレスとinterfaceの組み合わせをシンプルなリストにして出力する
get_ip() {
  # 変数
  local interface

  # osに応じて使用するsedを切り替え(macの場合はgsedを使う)
  case ${OSTYPE} in
  darwin*) local sed='gsed' ;;
  linux*) local sed='sed' ;;
  esac

  # ipコマンドの有無を確認する
  which ip >/dev/null

  # ipコマンドの有無に応じて切り替え(`ip` or `ifconfig`)
  if [[ $? -eq 0 ]]; then
    # interfaceの一覧を取得
    interface=$(ip a | grep -E '^[0-9]+' | awk '{print $2}' | $sed 's/://')

    # interfaceごとのipアドレスを出力
    echo "$interface" |
      xargs -I{} bash -c "echo \"$COLOR_RED{}$COLOR_NONE\": \$(ip a show dev {} | awk '/inet/{print \$2}' | $sed -z 's/\n/, /g')" |
      sed 's/,$//g' | sort
  else
    # interfaceの一覧を取得
    interface=$(ifconfig | grep -oE '^[^ '$'\t''][^:]+')

    # interfaceごとのipアドレスを出力
    echo "$interface" |
      xargs -I{} bash -c "echo \"$COLOR_RED{}$COLOR_NONE\": \$(ifconfig {} | awk '/inet/{print \$2}' | $sed -z 's/\n/, /g')" |
      $sed 's/,$//g' | sort
  fi
}

# `httpbin.org`に接続してグローバルIPを取得する
# TODO: 取得する際のインターフェイスやプロキシを指定できるようにしたいお気持ち
get_globalip() {
  curl -s httpbin.org/ip | jq -r '.origin'
}

# 開いてるポートとそれに対応するプロセスのコマンドを一覧で表示する
get_open_ports() {
  # osに応じて実行する処理を切り替え
  # 公開ポート番号を取得するコマンドを実行してパース処理

  # TODO: sudoはｆlagでつけるかどうするか判断させる
  case ${OSTYPE} in
  darwin*)
    netstat -anvp tcp |
      awk \
        -v OFS="," \
        -F$' ' \
        'BEGIN{
            print "echo \"port,command\""
           }
           $6=="LISTEN"{
            print "echo "$4,"\$(ps -o command= -p "$9")"
           }
      ' 2>/dev/null |
      bash
    ;;
  linux*)
    local ss_command='ss -ntlp'
    if [[ "$EUID" -ne 0 ]];then
      ss_command="sudo ${ss_command}"
    fi
    eval "${ss_command}" |
      awk -v OFS="," -F' ' 'BEGIN{
            print "echo \"port,command\""
           }
           $1=="LISTEN"{
            print "echo "$(NF-2),"$(ps -o command= -p $(echo '\''"$NF"'\'' | grep -m1 -Eo \"pid=[0-9]+\" | sed \"s/pid=//\") 2>/dev/null)"
           }
        ' 2> /dev/null | bash
    ;;
  esac
}

# OpenSSLでの、リモートの証明書の期限をチェックするための関数
check_cert() {
  local DOMAIN=$1
  local PORT=${2:-443}
  echo | openssl s_client -connect $DOMAIN:$PORT 2>/dev/null | openssl x509 -enddate
}

# 引数で受け付けたCIDRから、IPアドレスのリストを生成する関数
gen_ip_list() {
  local cidr="$1"

  echo "${cidr}" | perl -aF[./] -E'
    $x.=sprintf("%08b",$F[$_])for 0..3;
    $y=$F[4];$z=32-$y;
    $m=2**$z;
    for($j=0;$j<$m;$j++){
        $a=substr($x,0,$y).sprintf("%0".$z."b",$j);
        $b[$j].=".".sprintf(oct("0b".substr($a,$_*8,8)))for 0..3;
        $b[$j]=~s/^\.//g;
        say $b[$j];}
    print $b'
}

## ==========
# System情報取得関係
## ==========

# system関係の定番モニタリング用function
# ※ サブコマンド形式で作成(各sysmon系のfunctionを裏で叩く感じか？)
# sysmon() {}

# 開いてるポートの一覧を/procから取得するfunction
# sysmon_port() {}

# 設定されているIPアドレス/GW/DNSなどの一覧を取得するfunction
# MEMO: /proc/net/fib_trieなど、/procや/sysの情報から取るような仕組みにしたい気持ちはある(現実的かどうかはまた別)
# sysmon_ip() {}

# 使われているcpuについて取得するfunction
#

# 使われているメモリについて取得するfunction

## ==========
# Tmux関係
## ==========

# TODO: -cオプションを付与した場合、そのコマンドの数で分割して実行
# tmux内で実行すると、ウィンドウを分割してスタートさせる
ttmux() {
  for ((i = 1; i < $1; i++)); do
    test $(($i & 1)) -eq 0 && tmux split-window -h || tmux split-window -v
    tmux select-layout tiled >/dev/null
  done
}

## ==========
# typo対策用のfunction
## ==========

# lsのtypo用function
ls-() {
  case ${OSTYPE} in
  darwin*)
    which gls 2>&1 >/dev/null
    if [ $? -eq 0 ]; then
      eval ls --color -$@
    else
      ls -G -$@
    fi
    ;;
  linux*) ls --color=auto -$@ ;;
  esac
}
