#!/bin/bash
# Copyright(c) 2021 Blacknon. All rights reserved.
# Use of this source code is governed by an MIT license
# that can be found in the LICENSE file.

# shift + Tabで補完から選択
bind '"\e[Z": menu-complete'

# Ctrl + F /Ctrl + B で一単語分の切り取り
bind '"\C-f": kill-word'
bind '"\C-b": backward-kill-word'

# Alt + Arrow で左右へのスキップ
bind '"\e[1;3D": backward-word' # Alt + left
bind '"\e[1;3C": forward-word'  # Alt + right
bind '"\e\e[D": backward-word'  # Alt + left
bind '"\e\e[C": forward-word'   # Alt + right

# Ctrl + G でカーソルから左側を削除する
bind '"\C-g": unix-line-discard'

# Alt + C でカーソル位置から行末までをコマンド置換形式にする
bind -x '"\ec": __toggle_substitution_format'

# Alt + Q でカーソル位置から行末までをシングルクオーテーションで囲む
bind -x '"\eq": __toggle_singlequote_format'

# Alt + D でカーソル位置から行末までをダブルクオーテーションで囲む
bind -x '"\ed": __toggle_doublequote_format'

# Ctrl + J で現在実行中のプロセスをバックグラウンドジョブとする

# Ctrl + R でのhistoryの検索を__history_selection での処理に変更する
bind -x '"\C-r": __history_selection'

# Ctrl + S でコマンドの置換処理をする
bind -x '"\C-s": __substitute_line'

# Ctrl + L でclearを実行する
# "Ctrl + A(行頭に移動)"
# "Ctrl + K(カーソル位置から後ろをすべて削除)"
# "\10201(定義したclearの実行)"
bind '"\1201": "clear\n"'
bind '"\C-l": "\C-a\C-k\1201"'

# Ctrl + U で上のディレクトリに移動
# "Ctrl + A(行頭に移動)"
# "Ctrl + K(カーソル位置から後ろをすべて削除)"
# "\10202(定義したcd ../の実行)"
bind '"\1202": "cd ../\n"'
bind '"\C-u": "\C-a\C-k\1202"'

# Ctrl + X, Ctrl + Y で現在のプロンプトに入力されている内容をクリップボードにコピー
bind -x '"\C-X\C-Y": __copy_current_command'

# Ctrl + X, Ctrl + L でls -laを実行
# "Ctrl + A(行頭に移動)"
# "Ctrl + K(カーソル位置から後ろをすべて削除)"
# "\10203(定義したls -laの実行)"
bind '"\1203": "ls -la\n"'
bind '"\C-x\C-l": "\C-a\C-k\1203"'

# Ctrl + X, Ctrl + T で今日の日付をYYYYMMDD形式で入力する
bind '"\C-x\C-t": "$(date +%Y%m%d)"'

# Ctrl + X, Ctrl + M で過去の履歴や頻出先からインクリメンタルサーチしてcdする(@TODO)
## cdでカレントディレクトリを記録させる
function __cd() {
    \cd $1 && __cd_record $1
}
alias cd='__cd'
bind -x '"\1204": __cd_selection'
bind '"\C-x\C-m": "\1204\C-m"'

# Ctrl + X, Ctrl + P で、Petから選択したsnippetを貼り付ける
bind -x '"\1205": __pet_set'
bind '"\C-x\C-p": "\1205"'

# Ctrl + X, Ctrl + H で、現在のカーソル位置があるパイプラインで実行しようとしているコマンドのmanを表示させる

# Ctrl + X, Ctrl + M でtmuxを起動して移行する(@TODO)
