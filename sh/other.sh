#!/bin/bash
# Copyright(c) 2023 Blacknon. All rights reserved.
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
