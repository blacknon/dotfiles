#!/usr/bin/env bash
# -*- encoding: UTF-8 -*-
# Copyright(c) 2025 Blacknon. All rights reserved.
# Use of this source code is governed by an MIT license
# that can be found in the LICENSE file.
#
# Description: Johnを使ってOfficeファイルのパスワード解析をするスクリプト(MacOS用).
# =============================================

# usage
function usage() {
    cat <<_EOT_
Usage:
  $0 [office_file] [password_list]

Description:
  Johnを使ってOfficeファイルのパスワード解析をするスクリプト(MacOS用).

_EOT_
    exit 1
}

# option check
while getopts fh OPT; do
    case $OPT in
    h)
        echo "h option. display help"
        usage
        exit 0
        ;;
    esac
done

shift $((OPTIND - 1))

# OS種別のチェック
# MacOSでのみ使用するscriptのため、OSのチェックをして読み込ませる(Mac以外の場合はreturnする)
case ${OSTYPE} in
darwin*) : ;;
*)
    echo "MacOS以外では動作しません"
    usage
    exit 1
    ;;
esac

# johnの有無を確認
# johnのスクリプトファイル群用ディレクトリが存在している場合、PATHに追加する
if [ ! -d "/opt/homebrew/Cellar/john-jumbo/" || ! -d "/usr/local/Cellar/john-jumbo/" ]; then
    echo "john-jumboが入っていません"
    usage
    exit 1
fi

# 引数の数が2以上の場合はエラーとする
if [ $# -ne 2 ]; then
    echo "引数は2つ必要です"
    usage
    exit 1
fi

# 暗号化を解除するファイル
TARGET_FILE="${1}"

# パスワードリスト
PASSWORD_LIST="${2}"

# tmpファイルの生成
TMP_FILE=_$(date +%Y%M%d_%H%M%S | md5 | awk '{print $1}')

# ファイルの拡張子を取得し、切り替え
TARGET_FILE_EXT=$(basename "${TARGET_FILE}" | sed 's/^.*\.\([^\.]*\)$/\1/')

case ${TARGET_FILE_EXT} in
pdf)
    # hash値を取得する
    /opt/homebrew/bin/python3 ~/bin/pdf2john.py "${TARGET_FILE}" >"${TMP_FILE}"
    ;;
*)
    /opt/homebrew/bin/python3 ~/bin/office2john.py "${TARGET_FILE}" >"${TMP_FILE}"
    ;;
esac

# wordlistベースで解析を行う
john --wordlist="${2}" $TMP_FILE

rm $TMP_FILE
