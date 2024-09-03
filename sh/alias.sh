#!/bin/bash
# Copyright(c) 2023 Blacknon. All rights reserved.
# Use of this source code is governed by an MIT license
# that can be found in the LICENSE file.

# TODO: 流石に雑すぎだろ…と思うので、いい感じにforで回すように変更する。。。そのうち。

# 一部のコマンドをfunctionに置き換え
alias mkdir='__mkdirfunc'
alias ping='__pingfunc'

# shellの種類に応じて使用するオプションを変更する
case $(basename $SHELL) in
zsh*)
  ALIAS_OPTION="-g"
  ;;

bash*)
  ALIAS_OPTION=""
  ;;
esac

# ssh接続先かどうかによる分岐
if [ -z "${SSH_CLIENT}" ]; then
  # ローカルの場合
  alias sudo='sudo -E '
else
  # リモートの場合
  alias sudo='__sudofunc '
fi

# OSの種類による分岐
case ${OSTYPE} in
# MacOS Xの場合
darwin*)
  # ls(gnu)
  which gls 2>&1 >/dev/null
  [ $? -eq 0 ] && alias ls='gls --color=auto' lsc='gls --color=always' || alias "${ALIAS_OPTION}" ls='ls -G' 2>/dev/null || alias ls='ls -G'

  # grep(gnu)
  which ggrep 2>&1 >/dev/null
  [ $? -eq 0 ] && alias grep='ggrep --color=auto' || alias "${ALIAS_OPTION}" grep='grep --color=auto' 2>/dev/null || alias grep='grep --color=auto'

  # find(gnu)
  which gfind 2>&1 >/dev/null
  [ $? -eq 0 ] && alias "${ALIAS_OPTION}" find='gfind' 2>/dev/null || alias find='gfind'

  # sed(gnu)
  which gsed 2>&1 >/dev/null
  [ $? -eq 0 ] && alias "${ALIAS_OPTION}" sed='gsed' 2>/dev/null || alias sed='gsed'

  # date(gnu)
  which gdate 2>&1 >/dev/null
  [ $? -eq 0 ] && alias "${ALIAS_OPTION}" date='gdate' 2>/dev/null || alias date='gdate'

  # du(gnu)
  which gdu 2>&1 >/dev/null
  [ $? -eq 0 ] && alias "${ALIAS_OPTION}" du='gdu' 2>/dev/null || alias du='gdu'

  # cat(gnu)
  which gcat 2>&1 >/dev/null
  [ $? -eq 0 ] && alias "${ALIAS_OPTION}" cat='gcat' 2>/dev/null || alias cat='gcat'

  # cut(gnu)
  which gcut 2>&1 >/dev/null
  [ $? -eq 0 ] && alias "${ALIAS_OPTION}" cut='gcut' 2>/dev/null || alias cut='gcut'

  # shuf(gnu)
  which gshuf 2>&1 >/dev/null
  [ $? -eq 0 ] && alias "${ALIAS_OPTION}" shuf='gshuf' 2>/dev/null || alias shuf='gshuf'

  # join(gnu)
  which gjoin 2>&1 >/dev/null
  [ $? -eq 0 ] && alias "${ALIAS_OPTION}" join='gjoin' 2>/dev/null || alias join='gjoin'

  # paste(gnu)
  which gpaste 2>&1 >/dev/null
  [ $? -eq 0 ] && alias "${ALIAS_OPTION}" paste='gpaste' 2>/dev/null || alias paste='gpaste'

  # numfmt(gnu)
  which gnumfmt 2>&1 >/dev/null
  [ $? -eq 0 ] && alias "${ALIAS_OPTION}" numfmt='gnumfmt' 2>/dev/null || alias numfmt='gnumfmt'

  # sort(gnu)
  which gsort 2>&1 >/dev/null
  [ $? -eq 0 ] && alias "${ALIAS_OPTION}" sort='gsort' 2>/dev/null || alias sort='gsort'

  # head(gnu)
  which ghead 2>&1 >/dev/null
  [ $? -eq 0 ] && alias "${ALIAS_OPTION}" head='ghead' 2>/dev/null || alias head='ghead'

  # tail(gnu)
  which gtail 2>&1 >/dev/null
  [ $? -eq 0 ] && alias "${ALIAS_OPTION}" tail='gtail' 2>/dev/null || alias tail='gtail'

  # tar(gnu)
  which gtar 2>&1 >/dev/null
  [ $? -eq 0 ] && alias "${ALIAS_OPTION}" tar='gtar' 2>/dev/null || alias tar='gtar'

  # xargs(gnu)
  which gxargs 2>&1 >/dev/null
  [ $? -eq 0 ] && alias "${ALIAS_OPTION}" xargs='gxargs' 2>/dev/null || alias xargs='gxargs'

  # tree
  which tree 2>&1 >/dev/null
  [ $? -eq 0 ] && alias "${ALIAS_OPTION}" tree='tree -N ' 2>/dev/null

  ;;
linux*)
  alias "${ALIAS_OPTION}" ls='ls --color=auto ' 2>/dev/null || alias ls='ls --color=auto '
  alias "${ALIAS_OPTION}" lsc='ls --color=always ' 2>/dev/null || alias lsc='ls --color=always '
  alias "${ALIAS_OPTION}" grep='grep --color=auto ' 2>/dev/null || alias grep='grep --color=auto '
  ;;
esac

# 上書きの有無を確認させる
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Python2/3関係
alias "${ALIAS_OPTION}" pip='pip3' 2>/dev/null || alias pip='pip3'
alias "${ALIAS_OPTION}" python='python3' 2>/dev/null || alias python='python3'

# その他
alias "${ALIAS_OPTION}" man='man -P less' 2>/dev/null || alias man='man -P less'
alias "${ALIAS_OPTION}" l='ls' 2>/dev/null || alias l='ls'
alias "${ALIAS_OPTION}" ll='ls -la' 2>/dev/null || alias ll='ls -la'
alias "${ALIAS_OPTION}" lh='ls -lahS' 2>/dev/null || alias lh='ls -lahS'
alias "${ALIAS_OPTION}" sl='ls' 2>/dev/null || alias sl='ls'
alias "${ALIAS_OPTION}" clr='clear' 2>/dev/null || alias clr='clear'
alias "${ALIAS_OPTION}" dig='dig +short ' 2>/dev/null || alias dig='dig +short ' # shortでの出力を基本にする

# その他主要ツールのalias
# bat
which bat 2>/dev/null >/dev/null
[ $? -eq 0 ] && alias bat='bat -n' bcat='BAT_PAGER="cat" \bat -p' batlog='bat --paging=never -l log'

# hwatch
which hwatch 2>/dev/null >/dev/null
[ $? -eq 0 ] && alias hwatch='hwatch -s '\''zsh -c "source ~/.zshrc; {COMMAND}"'\'' -l $HOME/Today/log/hwatch/hwatch_$(date +%Y%m%d_%H%M%S)_hwatch.log '
