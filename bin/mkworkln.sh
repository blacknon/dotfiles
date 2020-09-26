#!/bin/bash
# Copyright(c) 2019 Blacknon. All rights reserved.
# Use of this source code is governed by an MIT license
# that can be found in the LICENSE file.
#
# User: Blacknon
#
# Description: ~/Work整備のcron用スクリプト
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

# TODO(blacknon): 1時間単位で実行しても問題ないように作る(~/Work/YYYYMM/YYYYMMDDが存在しない場合にキックするようにすればいいかも？)

# 引数の取得(テンプレートファイルPATH)
PLIST_TEMPLETE=("$@")

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
WORKDIR=$(date "+${HOME}/Work/%Y%m/%Y%m%d")
DOWNLOAD_DIR="${WORKDIR}/${DOWNLOAD}/"

# `~/Work/YYYYMM/YYYYMMDD/$DOWNLOAD_DIR`を作成する
mkdir -p "${DOWNLOAD_DIR}"

# `~/Work/YYYYMM/YYYYMMDD/log`を作成する
mkdir -p "${WORKDIR}/log/"
mkdir -p "${WORKDIR}/log/hwatch/"

# today_memo.txtを生成する
touch "${WORKDIR}/today_memo.txt"

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
  for e in ${PLIST_TEMPLETE[@]}; do
    # テンプレートファイルを読んで変数相当の箇所を置換
    #   - ${DOWNLOAD_DIR} ... ダウンロードディレクトリ
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
  sudo rm -rf "${TARGET_DESKTOP_DIR}"
  ln -sF "${WORKDIR}" "${TARGET_DESKTOP_DIR}"

  # Finderを再起動して表示を更新する
  killall Finder
  ;;
esac

# Downloadディレクトリ
TARGET_DOWNLOAD_DIR="${HOME}/${DOWNLOAD}"
test -L "${TARGET_DOWNLOAD_DIR}" && rm -rf "${TARGET_DOWNLOAD_DIR}"
ln -sF "${DOWNLOAD_DIR}" "${TARGET_DOWNLOAD_DIR}"

# Todayディレクトリ
TARGET_TODAY_DIR="${HOME}/Today"
test -L "${TARGET_TODAY_DIR}" && rm -rf "${TARGET_TODAY_DIR}"
ln -sF "${WORKDIR}" "${TARGET_TODAY_DIR}"

# もし前日のディレクトリを利用していなかった場合、削除する
case "${OSTYPE}" in
darwin*)
  date="gdate"
  find="gfind"
  ;;
linux*)
  date="date"
  find="find"
  ;;
esac

YESTERDAY_DIR=$("${date}" "+${HOME}/Work/%Y%m/%Y%m%d" -d "-1 day")
if [ -d "${YESTERDAY_DIR}" ]; then
  YESTERDAY_SIZE=$("${find}" "${YESTERDAY_DIR}" -type f -not -name ".DS_Store" -printf "%s\n" | awk '{sum=sum+$0}END{print sum}')
  if [ "${YESTERDAY_SIZE}" -eq 0 ]; then
    rm -rf "${YESTERDAY_DIR}"
  fi
fi

# Projectディレクトリ配下から、当日の範囲内のプロジェクトへのsymlinkを作成する
$HOME/dotfiles/bin/my-pj symlink "${WORKDIR}"
