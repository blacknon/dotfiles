#!/usr/bin/env python3
# -*- encoding: UTF-8 -*-
# Copyright(c) 2021 Blacknon. All rights reserved.
# Use of this source code is governed by an MIT license
# that can be found in the LICENSE file.
#
# User:
#   blacknon
# Description: json文字列をPOSTできるURL EncodeしたQuery stringに変換するスクリプト
# Note:
#   phpのワンライナーでも同等の処理が可能。
#        ```php
#        echo '{"data":[{"id":1,"answer":"aaa"},{"id":2,"answer":"bbb"}]}' | php -r 'echo http_build_query(json_decode(trim(fgets(STDIN)),true));'
#        ```
# =============================================

import argparse
import urllib.parse
import json
import os
import sys
import select


# パイプから値を受け取っているか否かを確認する
def is_pipe():
    if select.select([sys.stdin, ], [], [], 0.0)[0]:
        return True
    return False


# dictを渡すと、配列を考慮したquery stringを返す関数(メインの関数)
# https://stackoverflow.com/questions/4013838/urlencode-a-multidimensional-dictionary-in-python
def recursive_urlencode(data):
    """
    # URL-encode a multidimensional dictionary.
    >>> data = {'a': 'b&c', 'd': {'e': {'f&g': 'h*i'}}, 'j': 'k'}
    >>> recursive_urlencode(data)
    'a=b%26c&j=k&d[e][f%26g]=h%2Ai'
    """
    def recursion(data, base=[]):
        pairs = []

        for key, value in data.items():
            new_base = base + [key]
            if hasattr(value, 'values'):
                pairs += recursion(value, new_base)
            else:
                new_pair = None
                if len(new_base) > 1:
                    first = urllib.parse.quote(new_base.pop(0))
                    rest = map(lambda x: urllib.parse.quote(x), new_base)
                    new_pair = "%s[%s]=%s" % (first, ']['.join(
                        rest), urllib.parse.quote(str(value)))
                else:
                    new_pair = "%s=%s" % (urllib.parse.quote(
                        str(key)), urllib.parse.quote(str(value)))
                pairs.append(new_pair)
        return pairs

    return '&'.join(recursion(data))


# mainの処理
def main():
    # parserを生成
    parser = argparse.ArgumentParser(
        description='json形式のデータを、POST可能なx-www-form-urlencodedに変換するスクリプト.'
    )

    # -f file_path
    parser.add_argument(
        '--file', '-f', action='store', type=str,
        help='jsonデータを指定したファイルから読み込む'
    )

    # 引数を取得
    args = parser.parse_args()

    # fileオプションが指定されている場合、指定されたファイルを読み込む
    if args.file is not None:
        # ファイルが存在していることを確認
        if not os.path.isfile(args.file):
            print("%sは存在しません." % args.file)
            sys.exit(1)

        # ファイルを開く
        with open(args.file) as f:
            data = json.load(f)

    else:
        # pipeか否かで処理を切り替え
        if is_pipe():
            stdin = input()
            data = json.loads(stdin)
        else:
            print("値はパイプから渡してください")
            sys.exit(1)

    # url paramに変換したデータを出力する
    print(recursive_urlencode(data))


if __name__ == "__main__":
    main()
