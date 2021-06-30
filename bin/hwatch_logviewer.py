#!/usr/bin/env python3
# -*- encoding: UTF-8 -*-
# Copyright(c) 2021 Blacknon. All rights reserved.
# Use of this source code is governed by an MIT license
# that can be found in the LICENSE file.
#
# User:
#   blacknon
# Description: [hwatch](https://github.com/blacknon/hwatch)のlogをパースして出力するスクリプト
# =============================================

import argparse
import difflib
import json
from json.decoder import WHITESPACE
from colorama import Fore


# jsonのパーサー
def load_iter(f):
    s = f.read()
    size = len(s)
    decoder = json.JSONDecoder()

    end = 0
    while True:
        idx = WHITESPACE.match(s[end:]).end()
        i = end + idx
        if i >= size:
            break
        ob, end = decoder.raw_decode(s, i)
        yield ob


# listサブコマンドの処理
def command_list(args):
    # ファイルの有無を確認
    if not os.path.isfile(os.path.expanduser(args.log_path)):
        print('error: %s not found' % args.log_path)
        return

    # ファイルをjsonとして読み込み
    f = open(os.path.expanduser(args.log_path))
    json_dict = load_iter(f)
    for d in list(json_dict):
        print(d['timestamp'] + ":", d['command'])

    None


# viewサブコマンドの処理
def command_view(args):
    # ファイルの有無を確認
    if not os.path.isfile(os.path.expanduser(args.log_path)):
        print('error: %s not found' % args.log_path)
        return

    # ファイルをjsonとして読み込み
    f = open(os.path.expanduser(args.log_path))
    json_dict = load_iter(f)
    json_list = list(json_dict)

    # listの長さを取得
    # json_len = len(json_list)
    # print(json_len)

    # 1個前のoutputを指定
    before_output = str("")

    for d in json_list:
        timestamp = d['timestamp']
        output = d['output']

        # diffフラグの有無で分岐
        if args.d:  # diffフラグが有効な場合
            diff_data = difflib.ndiff(
                before_output.splitlines(), output.splitlines())
            for diff_line in diff_data:
                if diff_line.startswith('+'):
                    print(timestamp + ":", Fore.GREEN +
                          diff_line[2:] + Fore.RESET)
                elif diff_line.startswith('-'):
                    print(timestamp + ":", Fore.RED +
                          diff_line[2:] + Fore.RESET)
                elif diff_line.startswith('?'):
                    continue
                else:
                    print(timestamp + ":", diff_line[2:])

        else:  # diffフラグが無効な場合
            for output_line in output.splitlines():
                print(timestamp + ":", output_line)

            # before_outputに代入
        before_output = output

        # 改行を出力
        print()

    None


# mainの処理
def main():
    # parserを生成
    cmd_parser = argparse.ArgumentParser(
        description='hwatch logの内容を確認するスクリプト.'
    )
    subparsers = cmd_parser.add_subparsers()

    # listサブコマンド
    parser_list = subparsers.add_parser(
        'list', help='list mode. see `list -h`'
    )
    parser_list.add_argument(
        'log_path', action='store', type=str,
        help='hwatch log file path',
    )
    parser_list.set_defaults(handler=command_list)

    # viewサブコマンド
    parser_view = subparsers.add_parser(
        'view', help='view mode. see `view -h`'
    )
    parser_view.add_argument(
        'log_path', action='store', type=str,
        help='hwatch log file path',
    )
    parser_view.add_argument(
        '-d', action='store_true',
        help='diff view mode',
    )
    parser_view.add_argument(
        '-y', action='store_true',
        help='side by side(only work at diff view mode)',
    )

    parser_view.set_defaults(handler=command_view)

    # サブコマンドの実行
    args = cmd_parser.parse_args()
    if hasattr(args, 'handler'):
        args.handler(args)
    else:
        # 未知のサブコマンドの場合はヘルプを表示
        cmd_parser.print_help()


if __name__ == '__main__':
    main()
