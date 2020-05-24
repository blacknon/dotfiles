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

| File | 関数名 |  概要 |
| ---- | ----- | --- |
| ./sh/sh_function_common | [____get_envdata()](./sh/sh_function_common#L) | 現在使っているfunctionや環境変数、aliasをbase64にして返す関数setでfunction/envを、aliasでエイリアスを取得させる|
| ./sh/sh_function_common | [____get_rcdata()](./sh/sh_function_common#L) | ローカルマシンで使用しているbashrcやvimrcのfunctionを読み込んでbase64にして返す関数|
| ./sh/sh_function_common | [____toggle_surround_format()](./sh/sh_function_common#L) | 入力中の内容を引数で指定された文字列で囲む(カーソル位置〜行末)|
| ./sh/sh_function_common | [____get_escape()](./sh/sh_function_common#L) | エスケープした文字を返す|
| ./sh/sh_function_common | [____1char2dotchar()](./sh/sh_function_common#L) | 各文字を1文字だけドット(.)にした文字列の一覧を出力する(agrepで使用)|
| ./sh/sh_function_common | [____shift1chars()](./sh/sh_function_common#L) | 各文字を1文字ずつずらした文字列を出力する(agrepで使用)|
| ./sh/sh_function_exec_1 | [ttmux()](./sh/sh_function_exec_1#L) | tmux内で実行すると、ウィンドウを分割してスタートさせる|
| ./sh/sh_function_exec_1 | [check_cert()](./sh/sh_function_exec_1#L) | OpenSSLでの、リモートの証明書の期限をチェックするための関数|
| ./sh/sh_function_exec_1 | [get_globalip()](./sh/sh_function_exec_1#L) | Get Global ip address|
| ./sh/sh_function_exec_1 | [get_ip()](./sh/sh_function_exec_1#L) | ipアドレスとinterfaceの組み合わせをシンプルなリストにして出力する|
| ./sh/sh_function_exec_1 | [pping()](./sh/sh_function_exec_1#L) | ex.)pping target1 target2...parallel port ping|
| ./sh/sh_function_exec_1 | [ddig()](./sh/sh_function_exec_1#L) | => ddigで名前解決後、そのデータを元にmarkdownのテーブルとか作ったりするので…。functionこさえるまでもなくて、普通にpetにsnippet突っ込むのでいいかも…スペース区切りでリストを引数として与えると、その名前解決の結果をカンマ区切りで出力するex.)ddig abc{1..10}.com @{8.8.8.8,1.1.1.1}|
| ./sh/sh_function_exec_1 | [targrep()](./sh/sh_function_exec_1#L) | tarファイル内のファイルに対してgrep(相当の処理)を行うfunction。awkを利用する。 ※ GNU tarでないと動作しないので注意|
| ./sh/sh_function_exec_1 | [tarcat()](./sh/sh_function_exec_1#L) | tar内のファイルをcatする|
| ./sh/sh_function_exec_1 | [tarls()](./sh/sh_function_exec_1#L) | tar内のファイルをlsする|
| ./sh/sh_function_exec_1 | [todaydir()](./sh/sh_function_exec_1#L) | make today dir|
| ./sh/sh_function_exec_1 | [find_bigfile()](./sh/sh_function_exec_1#L) | サイズの大きいファイルをサーチする|
| ./sh/sh_function_exec_1 | [sw()](./sh/sh_function_exec_1#L) | ファイルの入れ替え(スイッチ)|
| ./sh/sh_function_exec_1 | [Work()](./sh/sh_function_exec_1#L) | Workディレクトリの作成・移動|
| ./sh/sh_function_exec_1 | [enc_unicode()](./sh/sh_function_exec_1#L) | 標準入力から取得した値をUnicode Escape Sequence形式に変換する※ nkfが必要|
| ./sh/sh_function_exec_1 | [enc_hex()](./sh/sh_function_exec_1#L) | 標準入力から取得した値をHex形式(\xXX)にして返す|
| ./sh/sh_function_exec_1 | [dec_html()](./sh/sh_function_exec_1#L) | 標準入力から受付たhtmlエンティティ形式のデータをもとに戻す|
| ./sh/sh_function_exec_1 | [enc_html()](./sh/sh_function_exec_1#L) | 標準入力から取得した値をhtmlエンティティ形式に変換する|
| ./sh/sh_function_exec_1 | [dec_url()](./sh/sh_function_exec_1#L) | 標準入力から取得したパーセントエンコーディングを戻す|
| ./sh/sh_function_exec_1 | [enc_url_nkf()](./sh/sh_function_exec_1#L) | nkfを利用してurlエンコードする|
| ./sh/sh_function_exec_1 | [enc_url()](./sh/sh_function_exec_1#L) | 標準入力から取得した値をパーセントエンコーディングする-a ... ascii文字含め全部をパーセントエンコーディングする-z ... Null区切りにして改行もパーセントエンコーディング対象とする|
| ./sh/sh_function_exec_1 | [agrep()](./sh/sh_function_exec_1#L) | あいまいgrepをするfunction(1文字違う文字列(abc=>{.bc,a.c,ab.})と、1文字ずつずらした文字列(abc=>{abc,bac,acb})でgrepをする(typoも発見できる))|
| ./sh/sh_function_exec_1 | [joinby()](./sh/sh_function_exec_1#L) | Join array|
| ./sh/sh_function_exec_1 | [ts()](./sh/sh_function_exec_1#L) | 標準入力で受け付けた行頭にタイムスタンプ(YYYY-MM-DD HH:MM:SS: )を付与する|
| ./sh/sh_function_exec_2 | [mkinst()](./sh/sh_function_exec_2#L) | make install を一気に行うためのfunction|
| ./sh/sh_function_exec_2 | [scx()](./sh/sh_function_exec_2#L) | 完全にlocalで実行する用のscのラッパーfunction。bashrcをsourceした状態で引数のコマンドを実行させるので、functionも実行できるようにする。|
| ./sh/sh_function_exec_2 | [sc()](./sh/sh_function_exec_2#L) | scriptコマンドで/Work配下にターミナルログを記録する|
| ./sh/sh_function_exec_2 | [battery()](./sh/sh_function_exec_2#L) | バッテリー残量を取得|
| ./sh/sh_function_exec_2 | [pe()](./sh/sh_function_exec_2#L) | petからsnippetを実行する(実行後はhistoryに登録)|
| ./sh/sh_function_exec_2 | [prev()](./sh/sh_function_exec_2#L) | 直前に実行したコマンドをpetに登録する|
| ./sh/sh_function_exec_2 | [docker_login()](./sh/sh_function_exec_2#L) | dockerコンテナを起動してログインするためのfunction。usage:docker_login コンテナ名docker_login -e コンテナ名 # 現在のfunctionを利用してログインdocker_login -r コンテナ名 # rcファイルを利用してログイン|
| ./sh/sh_function_exec_2 | [docker_runin()](./sh/sh_function_exec_2#L) | dockerコンテナを起動してログインするためのfunction。usage:docker_runin コンテナ名docker_runin -e コンテナ名 # 現在のfunctionを利用して起動・ログインdocker_runin -r コンテナ名 # rcファイルを利用して起動・ログインdocker_runin -v ローカルPATH:コンテナPATH コンテナ名 # マウント指定(-r/-eオプション併用可)|
| ./sh/sh_function_exec_2 | [ud()](./sh/sh_function_exec_2#L) | 上のディレクトリに移動するfunction.cd(Change Directory) → ud(Up Directory)...という命名方式|
| ./sh/sh_function_exec_2 | [sortsave()](./sh/sh_function_exec_2#L) | sortしてその内容をそのまま保存する※ moreutils必須|
| ./sh/sh_function_exec_2 | [url2json()](./sh/sh_function_exec_2#L) | パイプから受け付けたurl encodeされたパラメータをjsonにして出力するfunction(要php)|
| ./sh/sh_function_exec_2 | [json2url()](./sh/sh_function_exec_2#L) | パイプから受け付けたjsonをurlencodeして出力するfunction(要php)|
| ./sh/sh_function_iterm2 | [imgls()](./sh/sh_function_iterm2#L) | imgls():about:iTerm2上で画像ファイルをls状に表示するfunctionorigin:https://www.iterm2.com/utilities/imglsrequire:- php|
| ./sh/sh_function_iterm2 | [imgview()](./sh/sh_function_iterm2#L) | imgview():about:iTerm2上で画像ファイルを表示するfunctionorigin:https://www.iterm2.com/utilities/imgcat|
| ./sh/sh_function_iterm2 | [____show_imgls_list_file()](./sh/sh_function_iterm2#L) | ____show_imgls_list_file():about:imglsの結果を出力するfunction|
| ./sh/sh_function_iterm2 | [____show_imgview_help()](./sh/sh_function_iterm2#L) | ____show_imgview_help():about:imgview用のhelpを出力するためのfunction|
| ./sh/sh_function_iterm2 | [____show_error()](./sh/sh_function_iterm2#L) | ____show_error():about:エラーメッセージを出力するfunction|
| ./sh/sh_function_iterm2 | [____print_image()](./sh/sh_function_iterm2#L) | ____print_image():about:iTerm2にイメージを出力するimgview用のfunction|
| ./sh/sh_function_iterm2 | [____check_dependency()](./sh/sh_function_iterm2#L) | ____check_dependency():about:コマンドの有無を確認するfunction。|
| ./sh/sh_function_iterm2 | [____print_st()](./sh/sh_function_iterm2#L) | ____print_st():about:More of the tmux workaround described above.|
| ./sh/sh_function_iterm2 | [____print_osc()](./sh/sh_function_iterm2#L) | ____print_osc():about:tmuxなどの場合にOSCエスケープシーケンスを出力するためのfunction。|
| ./sh/sh_function_keybind | [__toggle_doublequote_format()](./sh/sh_function_keybind#L) | 入力中の内容をダブルクオーテーションで囲む|
| ./sh/sh_function_keybind | [__toggle_singlequote_format()](./sh/sh_function_keybind#L) | 入力中の内容をシングルクオーテーションで囲む|
| ./sh/sh_function_keybind | [__toggle_substitution_format()](./sh/sh_function_keybind#L) | コマンド置換形式に変換する|
| ./sh/sh_function_keybind | [__pet_set()](./sh/sh_function_keybind#L) | pet searchをしてコマンドラインを置き換えるkeybind用のfunction|
| ./sh/sh_function_keybind | [__history_selection()](./sh/sh_function_keybind#L) | Ctrl + R でhistory検索をする(peco,bocoを使用)|
| ./sh/sh_function_keybind | [__copy_current_command()](./sh/sh_function_keybind#L) | Ctrl + X, Cで、現在のプロンプトのコマンドをコピーする(ssh先でも使えるように、OSCエスケープシーケンスを使用)NOTE: 【前提】 Macの場合、iTerm2を使ってることが前提NOTE: 【前提】 iTerm2の場合、`Perferences`で`Applications in terminal may access clipboard`にチェックが入ってる必要がある|
| ./sh/sh_function_keybind | [__cd_selection()](./sh/sh_function_keybind#L) | Ctrl + X, Ctrl + Dでcdを行うためのfunction(bash/zsh共通)|
| ./sh/sh_function_keybind | [__cd_record()](./sh/sh_function_keybind#L) | cdのhistoryを記録するためのfunction|
| ./sh/sh_function_replace | [__pingfunc()](./sh/sh_function_replace#L) | pingでタイムスタンプを頭につけるためのfunction|
| ./sh/sh_function_replace | [__mkdirfunc()](./sh/sh_function_replace#L) | mkdirで、単体のディレクトリが指定された場合はそこにそのまま移動させるためのfunction|
| ./sh/sh_function_replace | [__sudofunc()](./sh/sh_function_replace#L) | sudoでfunctionで定義した内容が使えるようにするためのfunction|


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
