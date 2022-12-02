#!/bin/bash
# Copyright(c) 2021 Blacknon. All rights reserved.
# Use of this source code is governed by an MIT license
# that can be found in the LICENSE file.
#
# Description: シェル関数とその説明を`sh_function*`ファイルから取得してtableにするスクリプト
# =============================================

# usage
function usage() {
    cat <<_EOT_
Usage:
  $0 [dir]

Description:
  指定されたdotfilesディレクトリ配下にあるsh/配下のfunctionをリストアップしてmarkdown tableとして表示する

_EOT_
    exit 1
}

# option check
while getopts h OPT; do
    case $OPT in
    h)
        echo "h option. display help"
        usage
        exit 0
        ;;
    esac
done

shift $((OPTIND - 1))

# ~/dotfilesに移動
if [ -z $1 ]; then
    dir=~/dotfiles
else
    dir=$1
fi

cd "$dir" || exit 1

# sh_functionファイルの一覧を取得する
files=$(ls -1 ./{sh,bash,zsh}/functions/* 2>/dev/null)

echo "| File | 関数名 | 概要 |"
echo "| ---- | ----- | --- |"

for file in ${files[@]}; do
    # ファイルをtacで逆順にして、その状態でのfuctionの行を取得する
    tac_file=$(tac ${file})
    tac_func_num=$(grep -En '^[a-zA-Z_1-9]+ *\(\) {' <<<"${tac_file}" | cut -d: -f1)

    for tac_line_num in ${tac_func_num[@]}; do
        # functionの宣言より↑にあるコメント行を取得する(`TODO`を含む行は削除)
        func_data=$(awk "NR==$tac_line_num,/^\$/" <<<"${tac_file}" | tac | grep -v "TODO")

        # function名だけを取得
        func_name=$(tail -n1 <<<"${func_data}" | sed 's/() *{/()/')

        # function宣言より↑にかかれているコメントを取得(OSの種類による分岐)
        case ${OSTYPE} in
        # MacOS Xの場合
        darwin*)
            func_note=$(ghead -n -1 <<<"${func_data}")

            # functionの説明(func_note)から、改行を消すなどの整形処理
            func_note=$(echo "${func_note}" | gsed -r "s/^# //g" | gsed -z 's,\n,<br/>,g' | gsed 's,^<br/>,,g;s,<br/>$,,g')
            ;;
        linux*)
            func_note=$(head -n -1 <<<"${func_data}")

            # functionの説明(func_note)から、改行を消すなどの整形処理
            func_note=$(echo "${func_note}" | sed -r "s/^# //g" | sed -z 's,\n,<br/>,g' | sed 's,^<br/>|<br/>$,,')
            ;;
        esac

        # 関数のいる行を取得する(Lつける処理が雑だけどいいや…)
        func_line_range=$(awk "/^${func_name}/,/^}/{print NR}" ${file} | tee >(head -n1) >(tail -n1) >/dev/null)
        func_line_tag=$(echo "${func_line_range}" | sort | tr \\n - | sed "s/-$//;s/-/-L/")

        # テーブルデータの出力
        echo "| [${file}](${file}) | [${func_name}](${file}#L${func_line_tag}) | ${func_note} |"
    done

done
