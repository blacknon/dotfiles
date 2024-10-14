#!/bin/bash
# Copyright(c) 2024 Blacknon. All rights reserved.
# Use of this source code is governed by an MIT license
# that can be found in the LICENSE file.

# ABOUT:
#     コマンド代わりに使用するためのfunctionを記載しているファイル。
#     lsshを使って持って行くremote machineでしか実行しない想定のもののみを記述。
### -------------------------------------------------------------

# lsshのreverse nfs mountを使って、ローカルディレクトリをssh先でマウントさせるためのshell function.
reverse_mount() {
  usage() {
    echo "Usage: reverse_mount [-p port] [-s] mount_path"
    return 1
  }

  # local変数を宣言(デフォルト値の2049も指定)
  local is_sudo
  local port=2049
  local path

  # optionをパース
  local opt
  while getopts "p:s" opt; do
    case $opt in
    p) port="${OPTARG}" ;;
    s) is_sudo="1" ;;
    esac
  done
  shift $((OPTIND - 1))

  # 引数がない場合はエラーにする
  if [ $# -eq 0 ]; then
    echo "Error: Arguments are required."
    usage
  fi

  path="$(readlink -f $1)"

  local mount_cmd="mount -t nfs -o vers=3,proto=tcp,port=${port},mountport=${port} 127.0.0.1:/ ${path}"
  local umount_cmd="umount ${path}"
  if [ "${is_sudo}" -eq "1" ]; then
    mount_cmd="sudo sh -c '${mount_cmd}'"
    umount_cmd="sudo sh -c '${umount_cmd}'"
  fi

  eval ${mount_cmd}

  trap "cd; echo 'umount reverse mount dir';${umount_cmd}" EXIT
}
