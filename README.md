# dotfiles

## About

自分(Blacknon)のクライアント環境用dotfiles。

## 基本方針

ローカルではzshを、リモートではbashを用いる。

リモート先でも[lssh](https://github.com/blacknon/lssh)を使ってローカルの設定(shell function含む)を転送、利用するため、実行コマンドは可能な限りシェル関数として実装する。

## 実行コマンド・関数

### AppleScript

| File                                  | 概要                                                                                                                                                                            |
| ---                                   | ---                                                                                                                                                                             |
| AppleScripts/music_rename.applescript | iTunesの選択中のタイトル名を、`~/Work/YYYYmm/YYYYmmdd/itunes.txt`のタイトルに変換していくスクリプト(`~/Work/YYYYmm/YYYYmmdd/itunes.txt`はShift-JISで記述する必要があるので注意) |


### 実行ファイル

| File                    | 概要                                                                                           |
| ---                     | ---                                                                                            |
| bin/get_proxy           | pubproxy.comのapiからランダムにSocks5 proxyを取得するスクリプト                                |
| bin/get_proxylist       | `www.proxy-list.download`からフリーのプロキシリストを取得してURI形式でリスト取得するスクリプト |
| bin/hwatch_logviewer.py | hwatch logの内容を確認するスクリプト                                                           |
| bin/json2urlparam.py    | json文字列をPOSTできるURL EncodeしたQuery stringに変換するスクリプト                           |
| bin/mkworkln.sh         | ~/Work整備のcron用スクリプト                                                                   |
| bin/my-pj               | 期間の決まっているプロジェクト用のディレクトリ生成スクリプト(~/Workとセット)                   |
| bin/myconky.sh          | dotfiles配下のconkyrcを利用したconkyの管理用スクリプト(Desktop Linux用)                        |
| bin/mydocker-setup      | ローカルで使うDockerの取得用スクリプト                                                         |
| bin/rot.py              | 文字列のROT対応用スクリプト(未作成)                                                            |
| bin/update_ltmux        | ssh先に持っていくtmux設定付きfunctionの作成スクリプト                                          |
| bin/update_lvim         | ssh先に持っていくvim設定付きfunctionの作成スクリプト                                           |


### シェル関数





## Note

### 実行ファイル・関数テーブル作成用コマンド

```bash
# AppleScript
(echo "File\t概要\n---\t---";grep -H -a '^-- Description' AppleScripts/* | nkf -w | sed 's/:-- Description:/\t/')| tb -s$'\t'

# 実行ファイル
(echo "File\t概要\n---\t---";grep -H -a '^# Description' bin/* | nkf -w | sed 's/:# Description:/\t/')| tb -s$'\t'

# シェル関数

```








