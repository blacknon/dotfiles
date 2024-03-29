#!/bin/bash
# Copyright(c) 2023 Blacknon. All rights reserved.
# Use of this source code is governed by an MIT license
# that can be found in the LICENSE file.

# About: ローカルマシンでのみ読み込ませるファイル

# 実行コマンドを、`~/Work/YYYYMM/YYYYMMDD/log/history`にも出力するためのfunction。
# keybindのaccept-lineを置き換えるために利用している。
# TODO(blacknon): 終了ステータスについても記録する
function __accept-line() {
  if [ ! ${#READLINE_LINE} -eq 0 ]; then
    # local関数の宣言
    local log_dir
    local log_file

    # logを出力するPATH(~/Work/YYYYMM/YYYYMMDD/log)を指定する
    log_dir=$(date "+${HOME}/Work/%Y%m/%Y%m%d/log")
    log_file="bash_history_$$.log"

    # mkdir
    mkdir -p ${log_dir}

    # logファイルへコマンドの出力
    date "+TimeStamp: %Y-%m-%d %H:%M:%S" >>${log_dir}/${log_file}
    echo "CurrentDir: ${PWD}" >>${log_dir}/${log_file}
    echo "Command: $READLINE_LINE" >>${log_dir}/${log_file}
    echo "==========" >>${log_dir}/${log_file}
  fi
}

# \C-mのキーバインドを変更する
bind -x '"\1299": __accept-line'
bind '"\1298": accept-line'
bind '"\C-m": "\1299\1298"'
