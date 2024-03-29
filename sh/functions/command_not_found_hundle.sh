#!/bin/bash
# Copyright(c) 2023 Blacknon. All rights reserved.
# Use of this source code is governed by an MIT license
# that can be found in the LICENSE file.

# コマンドがない場合に出力されるテキスト
function __command_not_found_animation() {
    echo "${COLOR_PURPLE}(#｀･ω ･´) ${COLOR_NONE}「${COLOR_CYAN}$1${COLOR_NONE}」なんて代物はねぇぞ！こんにゃろーめ！！"
}

# コマンドが無い場合に実行される処理の定義
function __command_not_found() {
    # compopt(bashの補完用コマンド)の場合、コマンドは無いものとして処理
    if [ "$1" == "compopt" ]; then
        return 127
    fi

    case ${OSTYPE} in
    darwin*)
        __command_not_found_animation "$1"
        return 127
        ;;
    linux*)
        if [ -x /usr/lib/command-not-found ] || [ -x /usr/share/command-not-found/command-not-found ]; then
            if [ -x /usr/lib/command-not-found ]; then
                /usr/lib/command-not-found -- "$1"
                __command_not_found_animation "$1"
                return 127
            elif [ -x /usr/share/command-not-found/command-not-found ]; then
                /usr/share/command-not-found/command-not-found -- "$1"
                __command_not_found_animation "$1"
                return 127
            fi
        else
            __command_not_found_animation "$1"
            return 127
        fi
        ;;
    esac
}

# command_not_found_handle(zshの場合はcommand_not_found_handler)の定義
case $(basename "${SHELL}") in
zsh*)
    function command_not_found_handler() {
        trap '' 1 2 3 15
        __command_not_found "$1"
    }
    ;;
bash*)
    function command_not_found_handle() {
        __command_not_found "$1"
    }
    ;;
esac
