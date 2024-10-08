#!/usr/bin/env zsh
# Copyright(c) 2023 Blacknon. All rights reserved.
# Use of this source code is governed by an MIT license
# that can be found in the LICENSE file.

# プロンプトの時刻をリアルタイムに更新する
autoload -Uz vcs_info
setopt prompt_subst
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' stagedstr "%F{yellow}!"
zstyle ':vcs_info:git:*' unstagedstr "%F{red}+"
zstyle ':vcs_info:*' formats "%F{green}%c%u[%b]%f"
zstyle ':vcs_info:*' actionformats '[%b|%a]'

TMOUT=1

# function使用中は、タイムスタンププロンプトの表示更新を停止させる
TRAPALRM() {
    if [ "$WIDGET" != "expand-or-complete" ] && \
       [ "$WIDGET" != "backward-char" ] && \
       [ "$WIDGET" != "forward-char" ] && \
       [ "$WIDGET" != "up-line-or-history" ] && \
       [ "$WIDGET" != "down-line-or-history" ] && \
       [ "$WIDGET" != "history-incremental-search-backward" ] && \
       [ "$WIDGET" != "history-search-forward" ] && \
       [ "$WIDGET" != "history-search-backward" ] && \
       [ "$WIDGET" != "self-insert" ] && # プロンプトに何かしらの文字が入ってる場合は更新を停止  \
       [ "$WIDGET" != "self-insert-unmeta" ] && # プロンプトに何かしらの文字が入ってる場合は更新を停止  \
       [ "$WIDGET" != "__history_selection" ] && \
       [ "$WIDGET" != "__history_selection_insert" ] && \
       [ "$WIDGET" != "__cd_selection" ] && \
       [ "$WIDGET" != "gscd" ] && \
       [ "$WIDGET" != "__substitute_line" ] && \
       [ "$WIDGET" != "__pet_set" ] \
       ; then
            zle .reset-prompt
    fi
}


# accept-line時にpromptがリセットされるようにする
# TODO(blacknon): historyを~/Work配下にも記録するような処理を追加する
re-prompt() {
    # promptをreset
    zle .reset-prompt

    # BUFFERのサイズに応じて処理を切り替える
    if [ ! ${#BUFFER} -eq 0 ];then
        # local関数の宣言
        local log_dir
        local log_file

        # logを出力するPATH(~/Work/YYYYMM/YYYYMMDD/log)を指定する
        log_dir=$(date "+${HOME}/Work/%Y%m/%Y%m%d/log")
        log_file="zsh_history_$$.log"

        # mkdir
        mkdir -p ${log_dir}

        # logファイルへコマンドの出力
        date "+TimeStamp: %Y-%m-%d %H:%M:%S" >>${log_dir}/${log_file}
        echo "CurrentDir: ${PWD}" >>${log_dir}/${log_file}
        echo "Command: $BUFFER" >>${log_dir}/${log_file}
        echo "==========" >>${log_dir}/${log_file}
    fi

    # accept-lineを実行
    zle .accept-line
}
zle -N accept-line re-prompt

# 左右のプロンプトを2行にするため、プロンプト表示前にコマンドを実行するように定義する
precmd_prompt() {
    local EXIT="$?"
    local BATTERY
    local SED
    local GREP
    local HOST_INFO
    local PATH_INFO
    local GIT_INFO
    local TOP_LPROMPT
    local TOP_RPROMPT

    # 1行空ける
    print

    case ${OSTYPE} in
        darwin*)
            SED="gsed"
            GREP="ggrep"
            ;;
        linux*)
            SED="sed"
            GREP="grep"
            ;;
    esac

    # 1行目左プロンプト
    HOST_INFO="%F{white}%n%f@%F{cyan}%m%f"
    PATH_INFO="%{%F{yellow}%}%~%{%f%}%(?.%{%F{green}%}.%{%F{magenta}%})"
    TOP_LPROMPT="%F{white}[%f$HOST_INFO%F{white}]%f%F{white}[%f$PATH_INFO%F{white}]%f"

    # エラーコードの追記
    if [ "${EXIT}" -ne "0" ]; then
        local err_code=(
		    [1]=error [2]='builtin error' [126]='not executable'[127]='command not found'
		    [128]=SIGHUP [129]=SIGINT [130]=SIGQUIT [131]=SIGILL [132]=SIGTRAP
		    [133]=SIGABRT [134]=SIGEMT [135]=SIGFPE [136]=SIGKILL [137]=SIGBUS
		    [138]=SIGSEGV [139]=SIGSYS [140]=SIGPIPE [141]=SIGALRM [142]=SIGTERM
		    [143]=SIGURG [144]=SIGSTOP [145]=SIGTSTP [146]=SIGCONT [147]=SIGCHLD
		    [148]=SIGTTIN [149]=SIGTTOU [150]=SIGIO [151]=SIGXCPU [152]=SIGXFSZ
		    [153]=SIGVTALRM [154]=SIGPROF [155]=SIGWINCH [156]=SIGINFO [157]=SIGUSR1
		    [158]=SIGUSR2
	    )
        TOP_LPROMPT="${TOP_LPROMPT}[%F{red}${err_code[${EXIT}]}%F{white}]"
    fi

    # 1行目右プロンプト
    vcs_info

    # battery functionがあれば実行する
    if typeset -f battery > /dev/null ;then
        BATTERY="$(battery|$SED 's/%/&&/g')"
        if [[ ${#BATTERY} -eq 0 ]];then
            BATTERY="NONE"
        fi
    else
        BATTERY="NONE"
    fi

    if [ ${#vcs_info_msg_0_} -eq 0 ];then
        TOP_RPROMPT="%F{white}[%fBATTERY:%F{cyan}$BATTERY%f%F{white}]%f "
    else
        GIT_INFO="${vcs_info_msg_0_} "
        TOP_RPROMPT="%F{white}[%fBATTERY:%F{cyan}$BATTERY%f%F{white}]%f $GIT_INFO"
    fi

    # テキストを装飾する場合、エスケープシーケンスをカウントしないようにします
    local INVISIBLE='%([BSUbfksu]|([FK]|){*})'
    local L_WIDTH="${#${(S%%)TOP_LPROMPT//$~INVISIBLE/}}"
    local R_WIDTH="${#${(S%%)TOP_RPROMPT//$~INVISIBLE/}}"
    local PAD_WIDTH="$(($COLUMNS - ($L_WIDTH + $R_WIDTH) % $COLUMNS))"

    # $TOP_LPROMPTおよび$TOP_RPROMPTに全角文字が含まれている場合、その文字数分PADからマイナスする
    local ZENKAKU=$(print -P "${TOP_LPROMPT}${TOP_RPROMPT}" | $GREP -o -P '[^\x00-\x7F]' | wc -l | tr -d ' ')
    if [ ${ZENKAKU} -ne 0 ];then
        local PAD_WIDTH=$(($PAD_WIDTH - $ZENKAKU))
    fi

    # ターミナルのタイトルを変更
    local TITLE="\e]0;$(whoami)@$(hostname -s)\007"

    print -P $TOP_LPROMPT${(r:$PAD_WIDTH:: :)}$TOP_RPROMPT

    # Ctrl + Cで表示がおかしくなった場合への対策
    # (sttyの設定をもとの状態に戻しておく)
    stty sane
    stty -ixon
}

precmd_functions=""
precmd_functions+=(precmd_prompt)


# Default Prompt
PROMPT="$TITLE%(?.%{%F{green}%}.%{%F{magenta}%})%(?!(｀・ω・´%)  <!(´ ；ω；\\\`%)? <)%{%f%} "
PROMPT2="%F{yellow}%(?!(｀・ω・´%)  <!(´；ω；\\\`%)? <)%f "

# Right Prompt
RPROMPT="%F{white}[%f%F{yellow}%D{%Y/%m/%d %H:%M:%S (%a) %Z}%f%F{white}]%f"

# もしかして？時のプロンプト
SPROMPT=$'\n'"%F{yellow}((( ;ﾟДﾟ)))? %f%F{cyan}< もしかして%F{white} %B%r%b %F{cyan}かな? [そう!(%F{white}y%F{cyan}), 違う!(%F{white}n%F{cyan}),%F{white}a%F{cyan},%F{white}e%F{cyan}]:%f "
