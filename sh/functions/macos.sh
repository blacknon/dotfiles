#!/bin/bash
# Copyright(c) 2025 Blacknon. All rights reserved.
# Use of this source code is governed by an MIT license
# that can be found in the LICENSE file.

# MacOSでのみ使用するfunction群のため、OSのチェックをして読み込ませる(Mac以外の場合はreturnする)
case ${OSTYPE} in
darwin*) : ;;
*) return ;;
esac

# MacOSでの、強制的な自動ロックを迂回するためのfunction. 実行中はロックされない.
autolock_pass() {
    yes 'caffeinate -d -u -t 300' | bash
}
