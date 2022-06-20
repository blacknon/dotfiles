#!/bin/bash
# Copyright(c) 2021 Blacknon. All rights reserved.
# Use of this source code is governed by an MIT license
# that can be found in the LICENSE file.

# コマンド修正機能を使う
setopt correct

# PCRE 互換の正規表現を使う
setopt re_match_pcre

# PROMPT変数内で変数参照する
setopt prompt_subst

# 重複を記録しない
setopt hist_ignore_dups

# 開始と終了を記録
setopt EXTENDED_HISTORY

# historyを共有
setopt share_history

# ヒストリに追加されるコマンド行が古いものと同じなら古いものを削除
setopt hist_ignore_all_dups

# スペースで始まるコマンド行はヒストリリストから削除
setopt hist_ignore_space

# ヒストリを呼び出してから実行する間に一旦編集可能
setopt hist_verify

# 余分な空白は詰めて記録
setopt hist_reduce_blanks

# 古いコマンドと同じものは無視
setopt hist_save_no_dups

# historyコマンドは履歴に登録しない
setopt hist_no_store

# 補完時にヒストリを自動的に展開
setopt hist_expand

# 履歴をインクリメンタルに追加
setopt inc_append_history

# 拡張globを使用する
setopt extended_glob

# 明確なドットの指定なしで.から始まるファイルをマッチ
setopt globdots

# Ctrl+Dでzshを終了しない
setopt ignore_eof

#日本語ファイル名等8ビットを通す
setopt print_eight_bit

# キーワードの途中でもカーソル位置で補完
setopt complete_in_word

# カーソル位置は保持したままファイル名一覧を順次その場で表示
setopt always_last_prompt

# cd省略
setopt auto_cd

# ディレクトリ履歴の保存
setopt auto_pushd

# glob展開をさせない
setopt nonomatch

### Key Bind
#### 想定一覧(デフォルト含む)
#### 【Ctrlキー】
#### - Ctrl + A : カーソルを行頭へ
#### - Ctrl + E : カーソルを行末へ
#### - Ctrl + M : 改行(プロンプト)
#### - Ctrl + P : カーソル位置を考慮してhistoryを遡る(前へ)
#### - Ctrl + N : カーソル位置を考慮してhistoryを遡る(次へ)
#### - Ctrl + U : 上のディレクトリへ移動(行の全部切り取りは使わない)
#### - Ctrl + L : clear
#### - Ctrl + J : 現在実行中のコマンドをバックグラウンドジョブ化する(TODO: 作成する)
#### - Ctrl + R : 履歴検索
#### - Ctrl + B : 左の単語を切り取り(1文字削除はバックスペースで代用)
#### - Ctrl + F : 右の単語を切り取り
#### - Ctrl + K : カーソルから行末までを切り取り
#### - Ctrl + G : カーソルから行頭までを切り取り
#### - Ctrl + Y : 戻った内容を戻す(redo)
#### - Ctrl + Z : 編集内容を戻す(undo)
####
#### 【Ctrlキー + Xキー】: 実行etc..系
#### - Ctrl + X, Ctrl + Y: __copy_current_command(現在プロンプトに入力されているコマンドをクリップボードにコピー)
#### - Ctrl + X, Ctrl + M: __cd_selection(移動先を選択してcdで移動する)
#### - Ctrl + X, Ctrl + G: gscd(gitリポジトリ配下のディレクトリを、移動先を選択してcdで移動する)
#### - Ctrl + X, Ctrl + L: ls -la
#### - Ctrl + X, Ctrl + T: 日付をYYYYMMDD形式で自動入力
#### - Ctrl + X, Ctrl + E: コマンドをエディタ編集モードで編集
#### - Ctrl + X, Ctrl + R: 履歴検索(現在のカーソル位置に差し込み)
#### - Ctrl + X, Ctrl + P: Petの内容をペースト(現在のカーソル位置に差し込み)
#### - Ctrl + X, Ctrl + S: コマンドの置換
#### - Ctrl + X, Ctrl + X, Ctrl + L: lssh
#### - Ctrl + D, Ctrl + W: Workディレクトリへの移動
####
#### 【Ctrlキー + Dキー】: Work Directory系
#### - Ctrl + D, Ctrl + D: ww(当日のWorkディレクトリに移動する)
#### - Ctrl + D, Ctrl + P: yw(前日のWorkディレクトリに移動する)
#### - Ctrl + D, Ctrl + N: tw(翌日のWorkディレクトリに移動する)
####
#### 【Altキー】
#### - Alt + 矢印キー: 単語での移動(Ctrl + B,Fについてはこれで代用)
#### - Alt + U: 単語をすべて大文字にする
#### - Alt + L: 単語をすべて小文字にする
#### - Alt + Q: カーソルから行末までをシングルクオーテーションで囲む(トグル)
#### - Alt + D: カーソルから行末までをダブルクオーテーションで囲む(トグル)
#### - Alt + C: カーソルから行末までをコマンド置換方式にする(トグル)
#### - Alt + . : 前のコマンドの最後の引数を入力する

# VSCode対策用(`bindkey -e`を入れないと`^A`などが動作しなくなるため)
bindkey -e

# Alt + 矢印キーでの単語間移動を有効にする
bindkey "\e\e[D" backward-word
bindkey "\e\e[C" forward-word
bindkey "\e[1;3D" backward-word # Alt + Left(Linux)
bindkey "\e[1;3C" forward-word  ##Alt + Right(Linux)

# Ctrl + B / Ctrl + F で一単語分を切り取り
bindkey '^B' backward-kill-word
bindkey '^F' kill-word

# Ctrl + Z でundo, Ctrl + Y でredo
bindkey '^Z' undo
bindkey '^Y' redo

# Ctrl + X, Ctrl + P でpetから記録されている内容をペーストする
zle -N __pet_set
bindkey '^X^P' __pet_set

# Ctrl + G でカーソルから左を削除
zle -N __unix-line-discard
bindkey '^G' __unix-line-discard

# Alt + . で前のコマンドの最後の引数を取得する
bindkey '^[.' insert-last-word

# Ctrl + U で上のディレクトリに移動
zle -N __zsh_up_cd
bindkey '^U' __zsh_up_cd

# Ctrl + L でclearコマンドを実行させる
# (デフォルトだと2行プロンプトの場合に問題があるため)
#bindkey -s '^L' "kill-line" "clear\n"
zle -N __zsh_clear
bindkey '^L' __zsh_clear

# Ctrl + X, Ctrl + L でls -laを実行する
zle -N __zsh_lsla
bindkey '^X^L' __zsh_lsla

# Ctrl + X, Ctrl + S で入力中のコマンドを置換する
zle -N __substitute_line
bindkey '^X^S' __substitute_line

# Ctrl + X, Ctrl + T で今日の日付をYYYYMMDD形式で入力する
zle -N __zsh_input_yyyymmdd
bindkey '^X^T' __zsh_input_yyyymmdd

# Ctrl + X, Ctrl + M でpecoなどで選択したディレクトリに移動する処理
## cdの履歴を自動記録
zle -N __cd_record
typeset -U chpwd_functions
chpwd_functions=($chpwd_functions __cd_record)
## キーバインドでの処理
zle -N __cd_selection
bindkey '^X^M' __cd_selection

# Ctrl + X, Ctrl + G で、pecoなどでGitリポジトリ配下の選択ディレクトリに移動する処理
zle -N gscd
bindkey '^X^G' gscd

# Alt + C で、現在入力中の内容をコマンド置換にする
zle -N __toggle_substitution_format
bindkey '^[c' __toggle_substitution_format

# Alt + Q で、現在入力中の内容をシングルクオーテーションで囲む
zle -N __toggle_singlequote_format
bindkey '^[q' __toggle_singlequote_format

# Alt + D で、現在入力中の内容をダブルクオーテーションで囲む
zle -N __toggle_doublequote_format
bindkey '^[d' __toggle_doublequote_format

# Ctrl + X, Ctrl + R で履歴検索して現在のカーソル位置に差し込みをする
zle -N __history_selection_insert
bindkey '^X^R' __history_selection_insert

# Ctrl + X, Ctrl + Y で、現在入力中の内容をクリップボードにコピーする
zle -N __copy_current_command
bindkey '^X^Y' __copy_current_command

# Ctrl + X, Ctrl + X, Ctrl + P で、現在入力中の内容をプロセス置換にする
# (カーソル位置から計算させてもいいかもしれない)

# Ctrl + X, Ctrl + F で、現在入力中の内容を整形する(複数行表示)

# Ctrl + X, Ctrl + X, Ctrl + F で、現在入力中の内容を整形する(短縮化)

# Ctrl + X, Ctrl + E で、現在入力中のコマンドをエディタで編集するモードに切り替える

# Ctrl + X, Ctrl + H で、現在のカーソル位置があるパイプラインで実行しようとしているコマンドのmanを表示させる

# Ctrl + X, Ctrl + X, Ctrl + L でlsshを実行する
zle -N __zsh_lssh
bindkey '^X^X^L' __zsh_lssh

# Ctrl + X, Ctrl + R で、インクリメンタルからの検索
zle -N __history_selection
bindkey '^R' __history_selection

# Ctrl + D, Ctrl + D で、当日のWorkDirectoryに移動
zle -N __ww
bindkey '^D^D' __ww

# Ctrl + D, Ctrl + D で、当日のWorkDirectoryに移動
zle -N __yw
bindkey '^D^P' __yw

# Ctrl + D, Ctrl + D で、当日のWorkDirectoryに移動
zle -N __tw
bindkey '^D^N' __tw

### Setup Other
# コマンド候補を選択できるようにする
zstyle ':completion:*:default' menu select=1

# 「.」からはじまるディレクトリも選択できるようにする
zstyle ':completion:*' special-dirs true

# ../ の後は今いるディレクトリを補完しない
zstyle ':completion:*' ignore-parents parent pwd ..

# sudo の後ろでコマンド名を補完する
zstyle ':completion:*:sudo:*' command-path \
    /usr/local/sbin \
    /usr/local/bin \
    /usr/sbin \
    /usr/bin \
    /sbin \
    /bin

# killコマンド時のプロセス補完をカスタマイズ(実行ターミナル以外で起動したプロセスも対象にする)
zstyle ':completion:*:processes' command "ps -u ${USER}"

# history検索でコマンド入力途中から検索できるようにする
autoload history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^P" history-beginning-search-backward-end # Ctrl + p
bindkey "^N" history-beginning-search-forward-end  # Ctrl + n

# PATHの重複を除外する
typeset -U path PATH

# compgenを使えるようにする
autoload -Uz bashcompinit
bashcompinit

# コマンドラインの単語として扱う区切り文字を指定する
autoload -Uz select-word-style
select-word-style default
zstyle ':zle:*' word-chars "\"'= ./%:;@　、。$}{)(][_-"
zstyle ':zle:*' word-style unspecified

# プロンプトカラー等を有効にする
autoload -U promptinit
promptinit
if [ -z "${TMUX}" ]; then
    if [ -f ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
        source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
    fi
fi

# historyからオートサジェストをさせる
if [ -z "${TMUX}" ]; then
    if [ -f ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
        source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
    fi
fi

# historyを遡る際に途中入力の内容も考慮させる
if [ -f ~/.zsh/zsh-history-substring-search/zsh-history-substring-search.zsh ]; then
    source ~/.zsh/zsh-history-substring-search/zsh-history-substring-search.zsh
fi

# zsh-completionsの読み込み(fpath読み込み後にcompinitする必要がある)
fpath=(~/dotfiles/zsh_completion $fpath)
if [ -f ~/.zsh/zsh-completions/zsh-completions.plugin.zsh ]; then
    fpath=(~/.zsh/zsh-completions/zsh-completions.plugin.zsh $fpath)
fi
autoload -Uz compinit
compinit -u


# Azure-CLI用のfunctionを読み込ませる(azコマンドの自動補完用)
source $(dirname $(realpath "${(%):-%N}"))/completion_az.zsh

# aws_completerがある場合、読み込ませる(awsコマンドの自動補完用)
if [ -f /usr/local/bin/aws_completer ]; then
    complete -C '/usr/local/bin/aws_completer' aws
fi

# 履歴ファイルの保存先
if [[ -d "${XDG_STATE_HOME}/zsh/" ]];then
    export HISTFILE="${XDG_STATE_HOME}/zsh/zhistory"
    export CDHISTFILE="${XDG_STATE_HOME}/zsh/cd_zhistory"
else
    export HISTFILE="${HOME}/zsh/zhistory"
    export CDHISTFILE="${HOME}/zsh/cd_zhistory"
fi

# メモリに保存される履歴の件数
export HISTSIZE=1000000000

# 履歴ファイルに保存される履歴の件数
export SAVEHIST=1000000000
