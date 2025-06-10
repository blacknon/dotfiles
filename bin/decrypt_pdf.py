#!/usr/bin/env python3
# Copyright(c) 2023 Blacknon. All rights reserved.
# Use of this source code is governed by an MIT license
# that can be found in the LICENSE file.
# -*- coding: utf-8 -*-

import pypdf
import argparse


def main():
    # parserを生成
    parser = argparse.ArgumentParser(
        description='暗号化されたpdfに対し、リストベースでのアタックをするスクリプト.'
    )

    # TARGET_FILE
    parser.add_argument(
        'TARGET_FILE', action='store', type=str,
        help='暗号化されているpdfファイル'
    )

    # PASSWORD_LIST
    parser.add_argument(
        'PASSWORD_LIST', action='store', type=str,
        help='パスワードリスト'
    )

    # 引数を取得
    args = parser.parse_args()

    # パスワード解析処理
    pdf = pypdf.PdfReader(args.TARGET_FILE)
    with open(args.PASSWORD_LIST) as f:
        password_list = f.read().splitlines()

        for password in password_list:
            r = pdf.decrypt(password)
            if r:
                print(password)


if __name__ == '__main__':
    main()
