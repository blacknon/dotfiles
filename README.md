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

| File | 概要 |
| ---- | --- |
|____get_envdata() | 現在使っているfunctionや環境変数、aliasをbase64にして返す関数 # setでfunction/envを、aliasでエイリアスを取得させる|
|____get_rcdata() | ローカルマシンで使用しているbashrcやvimrcのfunctionを読み込んで # base64にして返す関数|
|____toggle_surround_format() | 入力中の内容を引数で指定された文字列で囲む(カーソル位置〜行末)|
|____get_escape() | エスケープした文字を返す|
|ttmux() | tmux内で実行すると、ウィンドウを分割してスタートさせる|
|check_cert() | OpenSSLでの、リモートの証明書の期限をチェックするための関数|
|get_globalip() | Get Global ip address|
|get_ip() | ipアドレスとinterfaceの組み合わせをシンプルなリストにして出力する|
|pping() | ex.) # pping target1 target2... # parallel port ping|
|ddig() | => ddigで名前解決後、そのデータを元にmarkdownのテーブルとか作ったりするので…。functionこさえるまでもなくて、普通にpetにsnippet突っ込むのでいいかも… # スペース区切りでリストを引数として与えると、その名前解決の結果をカンマ区切りで出力する # ex.) # ddig abc{1..10}.com @{8.8.8.8,1.1.1.1}|
|targrep() | tarファイル内のファイルに対してgrep(相当の処理)を行うfunction。 # awkを利用する。 ※ GNU tarでないと動作しないので注意|
|tarcat() | tar内のファイルをcatする|
|tarls() | tar内のファイルをlsする|
|todaydir() | make today dir|
|find_bigfile() | サイズの大きいファイルをサーチする|
|sw() | ファイルの入れ替え(スイッチ)|
|Work() | Workディレクトリの作成・移動|
|enc_unicode() | 標準入力から取得した値をUnicode Escape Sequence形式に変換する # ※ nkfが必要|
|enc_hex() | 標準入力から取得した値をHex形式(\xXX)にして返す|
|dec_html() | 標準入力から受付たhtmlエンティティ形式のデータをもとに戻す|
|enc_html() | 標準入力から取得した値をhtmlエンティティ形式に変換する|
|dec_url() | 標準入力から取得したパーセントエンコーディングを戻す|
|enc_url_nkf() | nkfを利用してurlエンコードする|
|enc_url() | 標準入力から取得した値をパーセントエンコーディングする # -a ... ascii文字含め全部をパーセントエンコーディングする # -z ... Null区切りにして改行もパーセントエンコーディング対象とする|
|agrep() | あいまいgrepをするfunction # (1文字違う文字列(abc=>{.bc,a.c,ab.})と、1文字ずつずらした文字列(abc=>{abc,bac,acb})でgrepをする(typoも発見できる))|
|joinby() | Join array|
|ts() | 標準入力で受け付けた行頭にタイムスタンプ(YYYY-MM-DD HH:MM:SS: )を付与する|
|mkinst() | make install を一気に行うためのfunction|
|scx() | 完全にlocalで実行する用のscのラッパーfunction。 # bashrcをsourceした状態で引数のコマンドを実行させるので、functionも実行できるようにする。|
|sc() | scriptコマンドで/Work配下にターミナルログを記録する|
|battery() | バッテリー残量を取得|
|pe() | petからsnippetを実行する(実行後はhistoryに登録)|
|prev() | 直前に実行したコマンドをpetに登録する|
|docker_login() | dockerコンテナを起動してログインするためのfunction。 # usage: # docker_login コンテナ名 # docker_login -e コンテナ名 # 現在のfunctionを利用してログイン # docker_login -r コンテナ名 # rcファイルを利用してログイン|
|docker_runin() | dockerコンテナを起動してログインするためのfunction。 # usage: # docker_runin コンテナ名 # docker_runin -e コンテナ名 # 現在のfunctionを利用して起動・ログイン # docker_runin -r コンテナ名 # rcファイルを利用して起動・ログイン # docker_runin -v ローカルPATH:コンテナPATH コンテナ名 # マウント指定(-r/-eオプション併用可)|
|ud() | 上のディレクトリに移動するfunction. # cd(Change Directory) → ud(Up Directory) # ...という命名方式|
|sortsave() | sortしてその内容をそのまま保存する # ※ moreutils必須|
|imgls() | imgls(): # about: # iTerm2上で画像ファイルをls状に表示するfunction # origin: # https://www.iterm2.com/utilities/imgls # require: # - php|
|imgview() | imgview(): # about: # iTerm2上で画像ファイルを表示するfunction # origin: # https://www.iterm2.com/utilities/imgcat|
|____show_imgls_list_file() | ____show_imgls_list_file(): # about: # imglsの結果を出力するfunction|
|____show_imgview_help() | ____show_imgview_help(): # about: # imgview用のhelpを出力するためのfunction|
|____show_error() | ____show_error(): # about: # エラーメッセージを出力するfunction|
|____print_image() | ____print_image(): # about: # iTerm2にイメージを出力するimgview用のfunction|
|____check_dependency() | ____check_dependency(): # about: # コマンドの有無を確認するfunction。|
|____print_st() | ____print_st(): # about: # More of the tmux workaround described above.|
|____print_osc() | ____print_osc(): # about: # tmuxなどの場合にOSCエスケープシーケンスを出力するためのfunction。|
|__toggle_doublequote_format() | 入力中の内容をダブルクオーテーションで囲む|
|__toggle_singlequote_format() | 入力中の内容をシングルクオーテーションで囲む|
|__toggle_substitution_format() | コマンド置換形式に変換する|
|__pet_set() | pet searchをしてコマンドラインを置き換えるkeybind用のfunction|
|__history_selection() | Ctrl + R でhistory検索をする(peco,bocoを使用)|
|__copy_current_command() | Ctrl + X, Cで、現在のプロンプトのコマンドをコピーする(ssh先でも使えるように、OSCエスケープシーケンスを使用) # NOTE: 【前提】 Macの場合、iTerm2を使ってることが前提 # NOTE: 【前提】 iTerm2の場合、`Perferences`で`Applications in terminal may access clipboard`にチェックが入ってる必要がある|
|__cd_selection() | Ctrl + X, Ctrl + Dでcdを行うためのfunction(bash/zsh共通)|
|__cd_record() | cdのhistoryを記録するためのfunction|
|__pingfunc() | pingでタイムスタンプを頭につけるためのfunction|
|__mkdirfunc() | mkdirで、単体のディレクトリが指定された場合はそこにそのまま移動させるためのfunction|
|__sudofunc() | sudoでfunctionで定義した内容が使えるようにするためのfunction|


## Note

### 実行ファイル・関数テーブル作成用コマンド

```bash
# AppleScript
(echo "File\t概要\n---\t---";grep -H -a '^-- Description' AppleScripts/* | nkf -w | sed 's/:-- Description:/\t/')| tb -s$'\t'

# 実行ファイル
(echo "File\t概要\n---\t---";grep -H -a '^# Description' bin/* | nkf -w | sed 's/:# Description:/\t/')| tb -s$'\t'

# シェル関数
get_shellfunction_table.sh
```
