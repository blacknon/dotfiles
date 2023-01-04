#!/usr/bin/env python3
# -*- encoding: UTF-8 -*-
# Copyright(c) 2023 Blacknon. All rights reserved.
# Use of this source code is governed by an MIT license
# that can be found in the LICENSE file.
#
# Description: 文字列のROT対応用スクリプト(未作成)
# =============================================

# TODO(blacknon): オプションとかも含みで、あとでちゃんと作る。

import sys


def rot_n(c, n):
    if 'a' <= c and c <= 'z':
        return chr((ord(c) - ord('a') + int(n)) % 26 + ord('a'))

    if 'A' <= c and c <= 'Z':
        return chr((ord(c) - ord('A') + int(n)) % 26 + ord('A'))

    return c


def rot(s, n):
    c = (rot_n(c, n) for c in s)
    print(''.join(c))


if __name__ == '__main__':
    param = sys.argv
    s = param[1]
    r = param[2]
    rot(s, r)
