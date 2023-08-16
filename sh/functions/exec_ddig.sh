#!/bin/bash
# Copyright(c) 2023 Blacknon. All rights reserved.
# Use of this source code is governed by an MIT license
# that can be found in the LICENSE file.

# ABOUT:
#     コマンド代わりに使用するためのfunctionを記載しているファイル。
#     Macデフォルトのdigではなく、Bindをインストールして利用できるdigを使っているため、Linux等と同じバイナリを使っている前提。
#     よく使うことが多い、ddig funcitonのみを分離して記述。
### -------------------------------------------------------------

# TODO(blacknon): パラレルで実行できるようにする => 一度コマンドを作って、後でxargsでパラレル実行がいいかも
# TODO(blacknon): ddigの結果をjsonやMarkdown table、csv風に出力できるようなオプション(or command/function)が欲しいかも？
#
# スペース区切りでリストを引数として与えると、その名前解決の結果をカンマ区切りで出力するdigのwrapper関数
# ex.)
#     ddig abc{1..10}.com @{8.8.8.8,1.1.1.1}
#     ddig MX TXT A abc{1..10}.com @{8.8.8.8,1.1.1.1}
ddig() {
  # カラーコードの設定
  local COLOR_TARGET_START
  local COLOR_RECORD_START
  local COLOR_DNS_START
  local COLOR_END
  if [ -t 1 ]; then
    COLOR_TARGET_START=${COLOR_LGREEN}
    COLOR_RECORD_START=${COLOR_LPURPLE}
    COLOR_DNS_START=${COLOR_CYAN}
    COLOR_END=${COLOR_NONE}
  fi

  local grep
  case ${OSTYPE} in
  darwin*)
    grep="ggrep"
    ;;
  linux*)
    grep="grep"
    ;;
  esac

  # レコードリスト
  local RECORD_TYPE_LIST=(A CNAME ANY MX NS SOA HINFO AXFR TXT)

  # 配列として定義
  local arg
  local record_type=()
  local target=()
  local dns=()
  local options=()

  # 引数を一括で抽出
  for arg in ${@}; do
    # レコードタイプを追加
    if printf '%s\n' ${RECORD_TYPE_LIST[@]} | "${grep}" -qEx '^'${arg}'$' ; then
      record_type+=("${arg}")
      continue
    fi

    # optionの追加
    if printf '%s\n' "${arg}" | "${grep}" -q -e '^-' -e '^+'; then
      options+=("${arg}")
      continue
    fi

    # DNSサーバを追加
    if printf '%s\n' "${arg}" | "${grep}" -qE '^@'; then
      dns+=("${arg}")
      continue
    fi

    # 名前解決を行うホストを追加
    target+=("${arg}")
  done

  # record_type デフォルト値の指定
  if [[ ${#record_type[*]} -eq 0 ]]; then
    record_type=(A CNAME MX TXT)
  fi

  # dns デフォルト値の指定
  if [[ ${#dns[*]} -eq 0 ]]; then
    dns=(@8.8.8.8 @1.1.1.1)
  fi

  # target単位でloop
  while read t; do
    # dnsサーバ単位でloop
    while read d; do
      # record type単位でloop
      while read r; do
        # コマンドを組み立てて出力
        printf "${COLOR_TARGET_START}%s${COLOR_END} [${COLOR_RECORD_START}%s${COLOR_END}] in ${COLOR_DNS_START}%s${COLOR_END}: %s\n" \
          "${t}" "${r}" "${d}" "$(dig +short +time=30 +tries=3 ${options} ${r} ${t} ${d} | sort -V | tr $'\n' , | sed 's/,$//')"
      done < <(printf '%s\n' "${record_type[@]}")
    done < <(printf '%s\n' "${dns[@]}")
  done < <(printf '%s\n' "${target[@]}")
}
