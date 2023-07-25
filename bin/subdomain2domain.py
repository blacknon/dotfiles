#!/usr/bin/env python3
# -*- encoding: UTF-8 -*-
# Copyright(c) 2023 Blacknon. All rights reserved.
# Use of this source code is governed by an MIT license
# that can be found in the LICENSE file.
#
# Description: 標準入力で受け付けたサブドメインからドメインを返すスクリプト.
# =============================================

"""subdomain2domain.py

標準入力で受け付けたサブドメインからドメインを返すスクリプト.

Example:
    ```shell
    $ echo "hoge.com\nfuga.hoge.com\nunko.sitai.co.jp"
    hoge.com
    fuga.hoge.com
    unko.sitai.co.jp

    $ echo "hoge.com\nfuga.hoge.com\nunko.sitai.co.jp" | subdomain2domain.py
    hoge.com
    hoge.com
    sitai.co.jp
    ```
"""

import argparse
import sys
import select
import fileinput
from tld import get_fld
from tld.utils import update_tld_names


def is_pipe() -> bool:
    """is_pipe
    本スクリプトがパイプから値を受け取っているか否かを確認する
    """
    if select.select([sys.stdin, ], [], [], 0.0)[0]:
        return True
    return False


def main():
    parser = argparse.ArgumentParser(
        description='標準入力で受け付けたサブドメインからドメインを返すスクリプト.'
    )

    # 引数を取得
    _ = parser.parse_args()

    # pipeか否かで処理を切り替え
    if is_pipe():
        update_tld_names()
        for line in fileinput.input():
            line = line.strip()
            domain = get_fld(line, fix_protocol=True)
            print(domain)

    else:
        print("ドメインを取得するサブドメインを標準入力で渡してください.", file=sys.stderr)
        sys.exit(1)


if __name__ == '__main__':
    main()
