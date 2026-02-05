#!/bin/bash
# Copyright(c) 2023 Blacknon. All rights reserved.
# Use of this source code is governed by an MIT license
# that can be found in the LICENSE file.
#
# User: Blacknon
#
# Description: ~/Work整備のcron用スクリプト
#
# Note:
#     Workディレクトリを作成して、そのディレクトリへのシンボリックリンクとして~/Downloadを指定する。
#     MacOSの場合はDockのDownloadディレクトリのPATHを書き換えてDockを再起動する処理を行う。
#
# Note:
#     MacOSのDock更新ではテンプレートファイルを利用した方法を取っている。テンプレートファイルは引数で渡す。
#     テンプレートファイル用のデータを既存のplistから取得するコマンドは以下。
#
#     ```bash
#     plutil -extract "persistent-others" xml1 \
#         -o - \
#         $HOME/Library/Preferences/com.apple.dock.plist | \
#       xmlstarlet ed --delete 'plist/array/dict/dict/data' | \
#       xmlstarlet sel -B -t -c 'plist/array' 2>/dev/null
#     ```
# =============================================

# TODO(blacknon): 以下の機能を追加する
#   - 所定のディレクトリに配置しているスクリプトを実行する処理
#   - 実行は一番最後
#   - ファイルで、かつ実行権限があるもののみが対象
#   - 実行に失敗してもそのまま流していく
#   - ディレクトリに複数ファイルがある場合、すべて実行する
#   - ディレクトリはデフォルトで"~/Work/scripts"だが、-p DIRでオプション指定できるようにする


# TODO(blacknon): 1時間単位で実行しても問題ないように作る(~/Work/YYYYMM/YYYYMMDDが存在しない場合にキックするようにすればいいかも？)
case "${OSTYPE}" in
darwin*)
  date="gdate"
  find="gfind"
  stat="gstat"
  ;;
linux*)
  date="date"
  find="find"
  stat="stat"
  ;;
esac

# 引数の取得(テンプレートファイルPATH)
PLIST_TEMPLETE=("$@")

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

# DIRの指定
case "${OSTYPE}" in
darwin*)
  # Macの場合、PLIST_TEMPLETEがない場合はエラーにする
  if [ "$#" = 0 ]; then
    echo "ERROR: MacOSの場合はDockの更新用TempleteのPATHを指定すること"
    exit 1
  fi

  DOWNLOAD="Downloads"
  ;;
linux*)
  DOWNLOAD="Download"
  ;;
esac
WORKDIR=$(${date} "+${HOME}/Work/%Y%m/%Y%m%d")
DOWNLOAD_DIR="${WORKDIR}/${DOWNLOAD}/"

# `~/Work/YYYYMM/YYYYMMDD/$DOWNLOAD_DIR`を作成する
mkdir -p "${DOWNLOAD_DIR}"

# `~/Work/YYYYMM/YYYYMMDD/log`を作成する
mkdir -p "${WORKDIR}/log/"
mkdir -p "${WORKDIR}/log/hwatch/"

# today_memo.txtを生成する
# TODO: 未作成の場合のみ、前日のtoday_memo.txtからコピーさせてくる or どっかにsymlink作っとく？？
touch "${WORKDIR}/today_memo.txt"

today_memo_size=$($stat --printf="%s" "${WORKDIR}/today_memo.txt")

if [[ "0" -eq "${today_memo_size}" ]]; then
  echo -e "today memo\n===" >> "${WORKDIR}/today_memo.txt"
fi

# MacOSの場合、以下の処理も行う
#   - `${DOWNLOAD_DIR}/.localized`を作成
#   - DockのDownloadディレクトリを$DIRに向ける
#   - Dockを再起動する
case "${OSTYPE}" in
darwin*)
  # ${DOWNLOAD_DIR}/.localizedの作成
  touch "${DOWNLOAD_DIR}/.localized"

  # Dockのpersistent-othersの配列を初期化
  defaults write com.apple.dock persistent-others -array

  # テンプレートファイルを読み込んでpersistent-othersの配列を追加
  i=0
  for e in "${PLIST_TEMPLETE[@]}"; do
    # テンプレートファイルを読んで変数相当の箇所を置換
    #   - ${DOWNLOAD_DIR} ... ダウンロードディレクトリf
    DATA=$(sed "s,\${DOWNLOAD_DIR},${DOWNLOAD_DIR},g" "${e}")

    echo "${DATA}"

    #　取得したDATAを書き込み
    defaults write com.apple.dock persistent-others -array-add "${DATA}"

    let i++
  done

  # Dockの再起動を実施
  killall Dock
  ;;
esac

# Symbolic linkを作成する(強制)
# TODO(blacknon): Linuxでも動作するかどうかを検証し、後ほど書き換える
# Desktopディレクトリ
case "${OSTYPE}" in
darwin*)
  # .localizedの作成
  touch "${WORKDIR}/.localized"

  # Symbolic linkを置き換え
  TARGET_DESKTOP_DIR="${HOME}/Desktop"

  # check symlink
  if [ ! -L "${TARGET_DESKTOP_DIR}" ]; then
    rm -rf "${TARGET_DESKTOP_DIR}"
    ln -sF ~/Today "${TARGET_DESKTOP_DIR}"
  fi

  # Finderを再起動して表示を更新する
  killall Finder
  ;;
esac

# Downloadディレクトリ
TARGET_DOWNLOAD_DIR="${HOME}/${DOWNLOAD}"
if [[ -L $TARGET_DOWNLOAD_DIR ]]; then
  rm -rf "${TARGET_DOWNLOAD_DIR}"
  ln -sF "${DOWNLOAD_DIR}" "${TARGET_DOWNLOAD_DIR}"
fi

# Todayディレクトリ
TARGET_TODAY_DIR="${HOME}/Today"
if [ -L "${TARGET_TODAY_DIR}" ]; then
  rm -rf "${TARGET_TODAY_DIR}"
  ln -sF "${WORKDIR}" "${TARGET_TODAY_DIR}"
fi

# もし前日のディレクトリを利用していなかった場合、削除する
YESTERDAY_DIR=$("${date}" "+${HOME}/Work/%Y%m/%Y%m%d" -d "-1 day")
if [ -d "${YESTERDAY_DIR}" ]; then
  YESTERDAY_SIZE=$("${find}" "${YESTERDAY_DIR}" -type f -not -name ".DS_Store" -printf "%s\n" | awk '{sum=sum+$0}END{print sum}')
  if [ "${YESTERDAY_SIZE}" -eq 0 ]; then
    rm -rf "${YESTERDAY_DIR}"
  fi
fi

# Projectディレクトリ配下から、当日の範囲内のプロジェクトへのsymlinkを作成する
$HOME/dotfiles/bin/my-pj symlink "${WORKDIR}"
