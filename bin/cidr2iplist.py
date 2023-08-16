#!/usr/bin/env python3
# -*- encoding: UTF-8 -*-
# Copyright(c) 2023 Blacknon. All rights reserved.
# Use of this source code is governed by an MIT license
# that can be found in the LICENSE file.
#
# Description: 標準入力で受け付けたcidr(`192.168.0.0/24`)を展開してipアドレスのリストとして出力するスクリプト.
# =============================================

import ipaddress
import argparse
import select
import sys


# パイプから値を受け取っているか否かを確認する
def is_pipe():
    if select.select([sys.stdin, ], [], [], 0.0)[0]:
        return True
    return False

# mainの処理
def main():
    # parserを生成
    parser = argparse.ArgumentParser(
        description='cidr形式の文字列をip listとして出力する.'
    )

    # -s file_path
    parser.add_argument(
        '--seprater', '-s', action='store', type=str, default="\n",
        help='セパレータ'
    )

    # 引数を取得
    args = parser.parse_args()

    cidr = ""
    # pipeか否かで処理を切り替え
    if is_pipe():
        cidr = input()
    else:
        print("値はパイプから渡してください")
        sys.exit(1)

    ip_list = ipaddress.IPv4Network(cidr)

    hosts = ip_list.hosts()
    address_list = list()
    for h in hosts:
        address_list.append(str(h))

    # 出力結果を作成
    sep: str = args.seprater
    result = sep.join(address_list)

    print(result)


if __name__ == "__main__":
    main()
