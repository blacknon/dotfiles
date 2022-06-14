#!/bin/bash
# Copyright(c) 2021 Blacknon. All rights reserved.
# Use of this source code is governed by an MIT license
# that can be found in the LICENSE file.
#
# User: Blacknon
#
# Description: ~/Today/backupに、雑にバックアップを作成するスクリプト. mkworkln.shから該当箇所だけ抜き出して動くようにしたもの.
#
# =============================================

case "${OSTYPE}" in
darwin*)
    date="gdate"
    ;;
linux*)
    date="date"
    ;;
esac

# 現時点の`~/Today`ディレクトリ配下へ、バックアップファイルの配置
backup_dir="$HOME/Today/backup"
if [[ ! -d $backup_dir ]]; then
    # バックアップ用ディレクトリを作成
    mkdir -p $HOME/Today/backup

    # export
    source "$(realpath $(dirname $0)/../sh/export.sh)" || echo "note exit $$"

    # history系のファイルをバックアップ用ディレクトリへ配置
    tar czvf $HOME/Today/backup/histories.$(${date} +%Y%m%d -d '-1day').tar.gz \
        "${HOME}/.zhistory" \
        "${HOME}/.bash_history" \
        "${XDG_STATE_HOME}/zsh/zhistory" \
        "${XDG_STATE_HOME}/zsh/cd_zhistory" \
        "${XDG_STATE_HOME}/bash/bash_history" \
        "${XDG_STATE_HOME}/bash/bash_cd_history"
fi
