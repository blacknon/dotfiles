#!/bin/bash
# Copyright(c) 2023 Blacknon. All rights reserved.
# Use of this source code is governed by an MIT license
# that can be found in the LICENSE file.

# ABOUT:
#     コマンド代わりに使用するためのfunctionを記載しているファイル。
#     よく使うことが多い、pping funcitonのみを分離して記述。
### -------------------------------------------------------------

# TODO(blacknon): port指定版の際、レスポンスヘッダの一部を出力するように変更する
# ex.)
#     pping target1 target2...
# parallel port ping
pping() {
  # ローカル変数を宣言
  local port
  local num
  local timeout
  local sed
  local options

  # オプションの取得(p,n,m)
  while getopts p:n:m: OPT; do
    case $OPT in
    p)
      port="${OPTARG}"
      ;;
    n)
      num="${OPTARG}"
      ;;
    m)
      timeout="${OPTARG}"
      ;;
    esac
  done
  shift $((OPTIND - 1))

  # osに応じて変数の値を切り替える
  # ※ optionについても同様
  case ${OSTYPE} in
  darwin*)
    # 利用するsedを指定
    sed='gsed'
    ;;
  linux*)
    # 利用するsedを指定
    sed='sed'
    ;;
  esac

  # port指定の有無で処理を切り替え
  if [ -z "${port}" ]; then
    # port指定が無い場合、通常のping(icmp)を実行
    # optionの指定
    if [ -z "${port}" ]; then
      # timeoutの有無でタイムアウトの秒数を指定
      [ -n "${timeout}" ] && options="-W ${timeout} "

      # numの有無でカウント数を指定
      [ -n "${num}" ] && options=${options}"-c ${num} "
    fi

    echo "${@}" | fmt -1 |
      xargs -P "${#@}" -I@ -n 1 bash -c "
        ping ${options} @ | \
        ${sed} -u 's/^/@ :/;s/@/\x1b[32m&\x1b[0m/g'
      " 2>&1 |
      ts
  else
    # portが指定されている場合、curlなどを使って指定されたportへ疎通確認する
    # timeoutが指定されていない場合、2秒をデフォルトとして指定する
    [ -z "${timeout}" ] && timeout=2
    [ -z "${num}" ] && num=0

    echo "${@}" | fmt -1 |
      xargs -P "${#@}" -n1 -I@ bash -c "
        H=\$0;i=0;while :;do
          echo | curl -s -m ${timeout} telnet://\${H}:${port} 2>&1 >/dev/null \
            && echo \"\${H}:${port} ${COLOR_LGREEN}PING OK${COLOR_NONE}\" \
            || echo \"\${H}:${port} ${COLOR_RED}PING NG${COLOR_NONE}\";
          i=\$((i+1));
          [[ \$i -eq ${num} ]] && break;
          sleep 1;
        done
      " @ |
      ts
  fi
}
