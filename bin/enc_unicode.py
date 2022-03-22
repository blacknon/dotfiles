#!/usr/bin/env python3
# Copyright(c) 2022 Blacknon. All rights reserved.
# Use of this source code is governed by an MIT license
# that can be found in the LICENSE file.
# -*- coding: utf-8 -*-

import sys
import argparse


def main():
    parser = argparse.ArgumentParser(
        description='標準入力から受け付けた内容をUnicode(`\\u0000`)に変換して標準出力に出すスクリプト'
    )

    parser.add_argument(
        '-a', '--all', action='store_true',
        help='改行も変換対象にする.'
    )

    args = parser.parse_args()

    if args.all:
        text = sys.stdin.read()
        for _c in text:
            print('\\u%04x' % ord(_c), end="")
    else:
        for line in sys.stdin:
            line = line.strip()
            for _c in line:
                print('\\u%04x' % ord(_c), end="")
            print()


if __name__ == '__main__':
    main()
