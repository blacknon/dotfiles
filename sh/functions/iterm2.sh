#!/bin/bash
# Copyright(c) 2023 Blacknon. All rights reserved.
# Use of this source code is governed by an MIT license
# that can be found in the LICENSE file.

# ____print_osc():
#   about:
#     tmuxなどの場合にOSCエスケープシーケンスを出力するためのfunction。
____print_osc() {
    if [[ $TERM == screen* ]]; then
        printf "\033Ptmux;\033\033]"
    else
        printf "\033]"
    fi
}

# ____print_st():
#   about:
#     More of the tmux workaround described above.
____print_st() {
    if [[ $TERM == screen* ]]; then
        printf "\a\033\\"
    elif [ x"$TERM" = "xscreen" ]; then
        printf "\a\033\\"
    else
        printf "\a"
    fi
}

# ____check_dependency():
#   about:
#     コマンドの有無を確認するfunction。
____check_dependency() {
    if ! (builtin command -V "$2" >/dev/null 2>&1); then
        echo "$1: missing dependency: can't find $2" 1>&2
        exit 1
    fi
}

# ____print_image():
#   about:
#     iTerm2にイメージを出力するimgview用のfunction
____print_image() {
    # local変数を宣言
    local BASE64ARG

    ____print_osc
    printf '1337;File='
    if [[ -n "$1" ]]; then
        printf 'name='$(printf "%s" "$1" | base64)";"
    fi

    VERSION=$(base64 --version 2>&1)
    if [[ "$VERSION" =~ fourmilab ]]; then
        BASE64ARG=-d
    elif [[ "$VERSION" =~ GNU ]]; then
        BASE64ARG=-di
    else
        BASE64ARG=-D
    fi

    printf "%s" "$3" | base64 $BASE64ARG | wc -c | awk '{printf "size=%d",$1}'
    printf ";inline=$2"
    printf ":"
    printf "%s" "$3"
    ____print_st
    printf '\n'
    if [[ -n "$4" ]]; then
        echo $1
    fi
}

# ____show_error():
#   about:
#     エラーメッセージを出力するfunction
____show_error() {
    echo "ERROR: $*" 1>&2
}

# ____show_imgview_help():
#   about:
#     imgview用のhelpを出力するためのfunction
____show_imgview_help() {
    echo "Usage:"
    echo "  imgview [-p] filename ..." 1>&2
    echo "  cat filename | imgview" 1>&2
}

# ____show_imgls_list_file():
#   about:
#     imglsの結果を出力するfunction
____show_imgls_list_file() {
    # local変数の宣言
    local fn
    local dims
    local rc

    fn=$1
    test -f "$fn" || return 0
    dims=$(php -r 'if (!is_file($argv[1])) exit(1); $a = getimagesize($argv[1]); if ($a==FALSE) exit(1); else { echo $a[0] . "x" .$a[1]; exit(0); }' -- "$fn")
    rc=$?
    if [[ $rc == 0 ]]; then
        ____print_osc
        printf '1337;File=name='$(echo -n "$fn" | base64)";"
        wc -c -- "$fn" | awk '{printf "size=%d",$1}'
        printf ";inline=1;height=3;width=3;preserveAspectRatio=true"
        printf ":"
        base64 <"$fn"
        ____print_st
        if [ x"$TERM" == "xscreen" ]; then
            printf '\033[4C\033[Bx'
        else
            printf '\033[A'
        fi

        echo -n "$dims "
        ls -ld -- "$fn"
    else
        ls -ld -- "$fn"
    fi
}

# imgview():
#   about:
#     iTerm2上で画像ファイルを表示するfunction
#   origin:
#      https://www.iterm2.com/utilities/imgcat
# TODO(blacknon): show_helpと同様の処理を他の主要functionにも実装できるか検討する
imgview() {
    # local変数の宣言
    local has_stdin
    local print_filename
    local encoded_image

    # Main
    if [ -t 0 ]; then
        has_stdin=f
    else
        has_stdin=t
    fi

    # Show help if no arguments and no stdin.
    if [ $has_stdin = f -a $# -eq 0 ]; then
        ____show_imgview_help
        return
    fi

    ____check_dependency imgview awk
    ____check_dependency imgview base64
    ____check_dependency imgview wc

    # Look for command line flags.
    while [ $# -gt 0 ]; do
        case "$1" in
        -h | --h | --help)
            ____show_imgview_help
            return
            ;;
        -p | --p | --print)
            print_filename=1
            ;;
        -u | --u | --url)
            check_dependency curl
            encoded_image=$(curl -s "$2" | base64) || (
                ____show_error "No such file or url $2"
                exit 2
            )
            has_stdin=f
            ____print_image "$2" 1 "$encoded_image" "$print_filename"
            set -- ${@:1:1} "-u" ${@:3}
            if [ "$#" -eq 2 ]; then
                return
            fi
            ;;
        -*)
            ____show_error "Unknown option flag: $1"
            ____show_imgview_help
            return
            ;;
        *)
            if [ -r "$1" ]; then
                has_stdin=f
                ____print_image "$1" 1 "$(base64 <"$1")" "$print_filename"
            else
                ____show_error "imgview: $1: No such file or directory"
                return
            fi
            ;;
        esac
        shift
    done

    # Read and print stdin
    if [ $has_stdin = t ]; then
        ____print_image "" 1 "$(cat | base64)" ""
    fi
}

# TODO(blacknon): 引数でPATHを指定するように書き換える
# TODO(blacknon): オプションを付与する
# imgls():
#   about:
#     iTerm2上で画像ファイルをls状に表示するfunction
#   origin:
#     https://www.iterm2.com/utilities/imgls
#   require:
#     - php
imgls() {
    ____check_dependency imgls php
    ____check_dependency imgls base64
    ____check_dependency imgls wc

    if [ $# -eq 0 ]; then
        for fn in *; do
            ____show_imgls_list_file "$fn"
        done < <(ls -ls)
    else
        for fn in "$@"; do
            ____show_imgls_list_file "$fn"
        done
    fi

}
