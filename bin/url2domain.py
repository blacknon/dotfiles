#!/usr/bin/env python3
# -*- encoding: UTF-8 -*-
# Copyright(c) 2023 Blacknon. All rights reserved.
# Use of this source code is governed by an MIT license
# that can be found in the LICENSE file.
#
# Description: 標準入力で受け付けたURLからドメインを返すスクリプト.
# =============================================

"""subdomain2domain.py

標準入力で受け付けたURLからドメインを返すスクリプト.

Example:
    ```shell
    $ echo "https://hogehoge.orebibou.com/path/to/page"
    https://hogehoge.orebibou.com/path/to/page

    $ echo "https://hogehoge.orebibou.com/path/to/page" | url2domain.py
    https://hogehoge.orebibou.com/path/to/page => hogehoge.orebibou.com
    ```
"""

import argparse
import sys
import select
import fileinput
from urllib.parse import urlparse


def is_pipe() -> bool:
    """is_pipe
    本スクリプトがパイプから値を受け取っているか否かを確認する
    """
    if select.select([sys.stdin, ], [], [], 0.0)[0]:
        return True
    return False


def main():
    parser = argparse.ArgumentParser(
        description='標準入力で受け付けたURLからドメイン部分を返すスクリプト.'
    )

    # 引数を取得
    _ = parser.parse_args()

    # pipeか否かで処理を切り替え
    if is_pipe():
        for line in fileinput.input():
            line = line.strip()
            try:
                parsed_url = urlparse(line)
                print("{0} => {1}".format(
                    line, parsed_url.netloc), file=sys.stdout)
            except Exception as e:
                print(
                    "parse error: {0}.\nError Message: \"{1}\""
                    .format(line, e),
                    file=sys.stderr
                )

    else:
        print("ドメインを取得するURLを標準入力で渡してください.", file=sys.stderr)
        sys.exit(1)


if __name__ == '__main__':
    main()
