#!/bin/bash
# Copyright(c) 2019 Blacknon. All rights reserved.
# Use of this source code is governed by an MIT license
# that can be found in the LICENSE file.
# Description: dotfiles配下のconkyrcを利用したconkyの管理用スクリプト(Desktop Linux用)

# usage
function usage() {
  cat <<_EOT_
Usage:
  $0 [start|stop|restart]

Description:
  dotfiles配下のconkyrcを利用したconkyの管理用スクリプト

_EOT_
  exit 1
}

# option check
while getopts abf:h OPT; do
  case $OPT in
  h)
    echo "h option. display help"
    usage
    exit 0
    ;;
  esac
done

# $1に応じて処理を切り替える
case $1 in
start)
  conky -d -c ~/dotfiles/conky/conkyrc_simple_main.lua >/dev/null &
  conky -d -c ~/dotfiles/conky/conkyrc_simple_sub.lua >/dev/null &
  ;;
stop)
  pkill -KILL '^conky'
  ;;
restart)
  pkill -KILL '^conky'
  conky -d -c ~/dotfiles/conky/conkyrc_simple_main.lua >/dev/null &
  conky -d -c ~/dotfiles/conky/conkyrc_simple_sub.lua >/dev/null &
  ;;
esac
