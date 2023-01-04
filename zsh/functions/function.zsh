#!/bin/bash
# Copyright(c) 2023 Blacknon. All rights reserved.
# Use of this source code is governed by an MIT license
# that can be found in the LICENSE file.

# ※ zsh独自の挙動をするfunctionを定義

# keybindでls -laを実行させるためのfunction
function __zsh_lsla() {
    # 入力されている文字列を変数$BUFに代入
    local BUF=${BUFFER}

    # 入力されている文字列を削除
    zle kill-whole-line
    echo

    # ls -laを実行(colorオプション付きで出力させるため)
    case ${OSTYPE} in
        darwin*)
            which gls 2>&1 > /dev/null
            if [ $? -eq 0 ];then
                gls --color=always -la
            else
                ls -G
            fi
            ;;
        linux*)
            ls --color=always -la
            ;;
    esac

    zle .accept-line

    # 入力されていた文字列を再度入力する
    if [ ! ${#BUF} -eq 0 ];then
        zle -U ${BUF}
    fi
}

# keybindで上のディレクトリに移動するためのfunction
function __zsh_up_cd() {
    # 入力されている文字列を変数$BUFに代入
    local BUF=${BUFFER}

    # 入力されている文字列を削除
    zle kill-whole-line

    # cd ../を実行
    \cd ..
    zle .accept-line

    # 入力されていた文字列を再度入力する
    if [ ! ${#BUF} -eq 0 ];then
        zle -U ${BUF}
    fi
}

# keybindでclearコマンドを実行させるためのfunction
function __zsh_clear() {
    zle kill-whole-line
    zle -U clear$'\n'
}

# keybindでlsshコマンドを実行させるためのfunction
function __zsh_lssh() {
    zle kill-whole-line
    zle -U lssh$'\n'
}

# keybindで本日の日付をyyyymmddで入力補佐するためのfunction
function __zsh_input_yyyymmdd() {
    zle -U $(date +%Y%m%d)
}

# keybindでカーソルより左を削除する
function __unix-line-discard() {
    BUFFER=${RBUFFER}
    CURSOR=0
}
