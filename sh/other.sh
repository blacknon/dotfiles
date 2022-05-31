#!/bin/bash
# Copyright(c) 2021 Blacknon. All rights reserved.
# Use of this source code is governed by an MIT license
# that can be found in the LICENSE file.

# Ctrl + Sでのスクリーンロックの割り当てを解除する
stty stop undef
stty -ixon

# ssh-agentの自動起動
case ${OSTYPE} in
darwin*)
    if [ -z "${SSH_CLIENT}" ]; then
        eval $(ssh-agent -a ${SSH_AUTH_SOCK} -P "/usr/local/Cellar/opensc/*/lib/*,/usr/lib/*,/Library/OpenSC/lib/*" 2>/dev/null 1>/dev/null)
    fi
    ;;
esac

# もしMacOSでParalles Desktopを使っている場合、docker-machine-driver-parallelsを使うため
# Docker実行マシンを切り替える
case ${OSTYPE} in
darwin*)
    # Paralles Desktopを使っていて、かつdocker-machine-driver-parallelsが入ってる場合はdocker実行マシンを切り替える
    if [ -d "/Applications/Parallels Desktop.app" ] && [ -f /usr/local/bin/docker-machine-driver-parallels ]; then
        eval $(docker-machine env prl-dev)
    fi
    ;;
esac
