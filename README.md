# dotfiles

## About

自分(Blacknon)のクライアント環境用dotfiles。

## 基本方針

ローカルではzshを、リモートではbashを用いる。

リモート先でも[lssh](https://github.com/blacknon/lssh)を使ってローカルの設定(shell function含む)を転送、利用するため、実行コマンドは可能な限りシェル関数として実装する。

## ディレクトリ・ファイル構成

| PATH                                                                                     | 概要 |
| -----------------------------------------------------------------------------------------| --- |
| [.zshrc](.zshrc)                                                                         | zsh用のrcファイル。小分けにしたファイル郡をsourceするだけ。 |
| [.bashrc](.bashrc)                                                                       | bash用のrcファイル。小分けにしたファイル郡をsourceするだけ。 |
| [.vimrc](.vimrc)                                                                         | vimrcファイル。ssh先に持っていきやすくするため1ファイルにすべて設定を記述する。 |
| [.tmux.conf](.tmux.conf)                                                                 | vimrcファイル。ssh先に持っていきやすくするため1ファイルにすべて設定を記述する。 |
| [sh](sh)                                                                                 | bash/zshで共通の設定・関数を格納するディレクトリ。                       |
| [sh/sh_alias](sh/sh_alias)                                                               | aliasの設定ファイル |
| [sh/sh_export](sh/sh_export)                                                             | export周りの処理を記述しているファイル |
| [sh/sh/sh_function_command_not_found_hundle](sh/sh/sh_function_command_not_found_hundle) | aliasの設定ファイル |
| [sh/sh_function_common](sh/sh_function_common)                                           | shell関数内で利用している関数を記述しているファイル |
| [sh/sh_function_exec_1](sh/sh_function_exec_1)                                           | インタラクティブシェルから実行する関数1(ssh先に持っていくもの) |
| [sh/sh_function_exec_2](sh/sh_function_exec_2)                                           | インタラクティブシェルから実行する関数2(ssh先に持っていかない・利用頻度の低いもの) |
| [sh/sh_function_iterm2](sh/sh_function_iterm2)                                           | iTerm2で利用する関数 |
| [sh/sh_function_exec_2](sh/sh_function_keybind)                                          | Keybindで使用する関数 |
| [sh/sh_function_exec_2](sh/sh_function_replace)                                          | 既存のコマンドからaliasで置き換える関数 |
| [sh/sh_other](sh/sh_other)                                                               | その他 |

## 実行コマンド・関数

### AppleScript

|File|概要|
|---|---|
| [AppleScripts/music_rename.applescript](AppleScripts/music_rename.applescript)           | iTunesの選択中のタイトル名を、`~/Work/YYYYmm/YYYYmmdd/itunes.txt`のタイトルに変換していくスクリプト(`~/Work/YYYYmm/YYYYmmdd/itunes.txt`はShift-JISで記述する必要があるので注意) |
| [AppleScripts/music_settracknum.applescript](AppleScripts/music_settracknum.applescript) | iTunesの選択中の曲にtrack numberを連番でセットしていくapple script.                                                                                                             |

### 実行ファイル

| File                                                             | 概要                                                                                           |
| ---                                                              | ---                                                                                            |
| [bin/get_proxy](bin/get_proxy)                                   | pubproxy.comのapiからランダムにSocks5 proxyを取得するスクリプト                                |
| [bin/get_proxylist](bin/get_proxylist)                           | `www.proxy-list.download`からフリーのプロキシリストを取得してURI形式でリスト取得するスクリプト |
| [bin/get_shellfunction_table.sh](bin/get_shellfunction_table.sh) | シェル関数とその説明を`sh_function*`ファイルから取得してtableにするスクリプト                  |
| [bin/hwatch_logviewer.py](bin/hwatch_logviewer.py)               | [hwatch](https://github.com/blacknon/hwatch)のlogをパースして出力するスクリプト                |
| [bin/json2urlparam.py](bin/json2urlparam.py)                     | json文字列をPOSTできるURL EncodeしたQuery stringに変換するスクリプト                           |
| [bin/mkworkln.sh](bin/mkworkln.sh)                               | ~/Work整備のcron用スクリプト                                                                   |
| [bin/my-pj](bin/my-pj)                                           | 期間の決まっているプロジェクト用のディレクトリ生成スクリプト(~/Workとセット)                   |
| [bin/myconky.sh](bin/myconky.sh)                                 | dotfiles配下のconkyrcを利用したconkyの管理用スクリプト(Desktop Linux用)                        |
| [bin/mydocker-setup](bin/mydocker-setup)                         | ローカルで使うDockerの取得用スクリプト                                                         |
| [bin/rot.py](bin/rot.py)                                         | 文字列のROT対応用スクリプト(未作成)                                                            |
| [bin/update_ltmux](bin/update_ltmux)                             | ssh先に持っていくtmux設定付きfunctionの作成スクリプト                                          |
| [bin/update_lvim](bin/update_lvim)                               | ssh先に持っていくvim設定付きfunctionの作成スクリプト                                           |



### シェル関数

| File | 関数名 | 概要 |
| ---- | ----- | --- |
| [./sh/sh_function_common](./sh/sh_function_common) | [____get_envdata()](./sh/sh_function_common#L118-L150) | 現在使っているfunctionや環境変数、aliasをbase64にして返す関数<br/>setでfunction/envを、aliasでエイリアスを取得させる |
| [./sh/sh_function_common](./sh/sh_function_common) | [____get_rcdata()](./sh/sh_function_common#L101-L114) | ローカルマシンで使用しているbashrcやvimrcのfunctionを読み込んで<br/>base64にして返す関数 |
| [./sh/sh_function_common](./sh/sh_function_common) | [____toggle_surround_format()](./sh/sh_function_common#L57-L97) | 入力中の内容を引数で指定された文字列で囲む(カーソル位置〜行末) |
| [./sh/sh_function_common](./sh/sh_function_common) | [____get_escape()](./sh/sh_function_common#L48-L97) | エスケープした文字を返す |
| [./sh/sh_function_common](./sh/sh_function_common) | [____1char2dotchar()](./sh/sh_function_common#L33-L45) | 各文字を1文字だけドット(.)にした文字列の一覧を出力する(agrepで使用) |
| [./sh/sh_function_common](./sh/sh_function_common) | [____shift1chars()](./sh/sh_function_common#L14-L30) | 各文字を1文字ずつずらした文字列を出力する(agrepで使用) |
| [./sh/sh_function_exec_1](./sh/sh_function_exec_1) | [ttmux()](./sh/sh_function_exec_1#L606-L611) | tmux内で実行すると、ウィンドウを分割してスタートさせる |
| [./sh/sh_function_exec_1](./sh/sh_function_exec_1) | [check_cert()](./sh/sh_function_exec_1#L574-L578) | OpenSSLでの、リモートの証明書の期限をチェックするための関数 |
| [./sh/sh_function_exec_1](./sh/sh_function_exec_1) | [get_globalip()](./sh/sh_function_exec_1#L569-L571) | Get Global ip address |
| [./sh/sh_function_exec_1](./sh/sh_function_exec_1) | [get_ip()](./sh/sh_function_exec_1#L535-L566) | ipアドレスとinterfaceの組み合わせをシンプルなリストにして出力する |
| [./sh/sh_function_exec_1](./sh/sh_function_exec_1) | [pping()](./sh/sh_function_exec_1#L456-L532) | ex.)<br/>    pping target1 target2...<br/>parallel port ping |
| [./sh/sh_function_exec_1](./sh/sh_function_exec_1) | [ddig()](./sh/sh_function_exec_1#L421-L452) | スペース区切りでリストを引数として与えると、その名前解決の結果をカンマ区切りで出力する関数<br/>ex.)<br/>    ddig abc{1..10}.com @{8.8.8.8,1.1.1.1} |
| [./sh/sh_function_exec_1](./sh/sh_function_exec_1) | [rarls()](./sh/sh_function_exec_1#L393-L408) | rarファイル内のデータをlist表示するfunction。 |
| [./sh/sh_function_exec_1](./sh/sh_function_exec_1) | [zipcat()](./sh/sh_function_exec_1#L385-L387) | zipファイル内のファイルを指定して標準出力に書き出すfunction。 |
| [./sh/sh_function_exec_1](./sh/sh_function_exec_1) | [zipls()](./sh/sh_function_exec_1#L367-L382) | zipファイル内のデータをlist表示するfunction。 |
| [./sh/sh_function_exec_1](./sh/sh_function_exec_1) | [targrep()](./sh/sh_function_exec_1#L307-L364) | tarファイル内のファイルに対してgrep(相当の処理)を行うfunction。<br/>awkを利用する。 ※ GNU tarでないと動作しないので注意 |
| [./sh/sh_function_exec_1](./sh/sh_function_exec_1) | [tarcat()](./sh/sh_function_exec_1#L295-L301) | tarファイル内のファイルを指定して標準出力に書き出すfunction。 |
| [./sh/sh_function_exec_1](./sh/sh_function_exec_1) | [tarls()](./sh/sh_function_exec_1#L275-L290) | tarファイル内のデータをlist表示するfunction。 |
| [./sh/sh_function_exec_1](./sh/sh_function_exec_1) | [todaydir()](./sh/sh_function_exec_1#L268-L272) | make today dir |
| [./sh/sh_function_exec_1](./sh/sh_function_exec_1) | [find_bigfile()](./sh/sh_function_exec_1#L245-L265) | サイズの大きいファイルをサーチする |
| [./sh/sh_function_exec_1](./sh/sh_function_exec_1) | [sw()](./sh/sh_function_exec_1#L237-L242) | ## ==========<br/>ファイル操作関係<br/>## ==========<br/>ファイルの入れ替え(スイッチ) |
| [./sh/sh_function_exec_1](./sh/sh_function_exec_1) | [enc_unicode()](./sh/sh_function_exec_1#L218-L231) | 標準入力から取得した値をUnicode Escape Sequence形式に変換する<br/>※ nkfが必要 |
| [./sh/sh_function_exec_1](./sh/sh_function_exec_1) | [enc_hex()](./sh/sh_function_exec_1#L212-L214) | 標準入力から取得した値をHex形式(\xXX)にして返す |
| [./sh/sh_function_exec_1](./sh/sh_function_exec_1) | [dec_html()](./sh/sh_function_exec_1#L207-L209) | 標準入力から受付たhtmlエンティティ形式のデータをもとに戻す |
| [./sh/sh_function_exec_1](./sh/sh_function_exec_1) | [enc_html()](./sh/sh_function_exec_1#L165-L204) | 標準入力から取得した値をhtmlエンティティ形式に変換する |
| [./sh/sh_function_exec_1](./sh/sh_function_exec_1) | [dec_url()](./sh/sh_function_exec_1#L160-L162) | 標準入力から取得したパーセントエンコーディングを戻す |
| [./sh/sh_function_exec_1](./sh/sh_function_exec_1) | [enc_url()](./sh/sh_function_exec_1#L115-L157) | 標準入力から取得した値をパーセントエンコーディングする<br/>    -n ... nkfを使用してパーセントエンコーディングする(-a,-zは無効化)<br/>    -a ... ascii文字含め全部をパーセントエンコーディングする(-nのときは無効)<br/>    -z ... Null区切りにして改行もパーセントエンコーディング対象とする |
| [./sh/sh_function_exec_1](./sh/sh_function_exec_1) | [agrep()](./sh/sh_function_exec_1#L58-L97) | あいまいgrepをするfunction<br/>(1文字違う文字列(abc=>{.bc,a.c,ab.})と、1文字ずつずらした文字列(abc=>{abc,bac,acb})でgrepをする(typoも発見できる)) |
| [./sh/sh_function_exec_1](./sh/sh_function_exec_1) | [joinby()](./sh/sh_function_exec_1#L50-L54) | Join array |
| [./sh/sh_function_exec_1](./sh/sh_function_exec_1) | [ts()](./sh/sh_function_exec_1#L2-L532) | 標準入力で受け付けた行頭にタイムスタンプ(YYYY-MM-DD HH:MM:SS: )を付与する |
| [./sh/sh_function_exec_2](./sh/sh_function_exec_2) | [mkinst()](./sh/sh_function_exec_2#L382-L384) | make install を一気に行うためのfunction |
| [./sh/sh_function_exec_2](./sh/sh_function_exec_2) | [scx()](./sh/sh_function_exec_2#L373-L375) | 完全にlocalで実行する用のscのラッパーfunction。<br/>bashrcをsourceした状態で引数のコマンドを実行させるので、functionも実行できるようにする。 |
| [./sh/sh_function_exec_2](./sh/sh_function_exec_2) | [sc()](./sh/sh_function_exec_2#L11-L375) | scriptコマンドで/Work配下にターミナルログを記録する |
| [./sh/sh_function_exec_2](./sh/sh_function_exec_2) | [battery()](./sh/sh_function_exec_2#L293-L302) | バッテリー残量を取得 |
| [./sh/sh_function_exec_2](./sh/sh_function_exec_2) | [pe()](./sh/sh_function_exec_2#L118-L396) | petからsnippetを実行する(実行後はhistoryに登録) |
| [./sh/sh_function_exec_2](./sh/sh_function_exec_2) | [prev()](./sh/sh_function_exec_2#L276-L279) | 直前に実行したコマンドをpetに登録する |
| [./sh/sh_function_exec_2](./sh/sh_function_exec_2) | [docker_login()](./sh/sh_function_exec_2#L207-L269) | dockerコンテナを起動してログインするためのfunction。<br/>usage:<br/>    docker_login コンテナ名<br/>    docker_login -e コンテナ名 # 現在のfunctionを利用してログイン<br/>    docker_login -r コンテナ名 # rcファイルを利用してログイン |
| [./sh/sh_function_exec_2](./sh/sh_function_exec_2) | [docker_runin()](./sh/sh_function_exec_2#L128-L201) | dockerコンテナを起動してログインするためのfunction。<br/>usage:<br/>    docker_runin コンテナ名<br/>    docker_runin -e コンテナ名 # 現在のfunctionを利用して起動・ログイン<br/>    docker_runin -r コンテナ名 # rcファイルを利用して起動・ログイン<br/>    docker_runin -v ローカルPATH:コンテナPATH コンテナ名 # マウント指定(-r/-eオプション併用可) |
| [./sh/sh_function_exec_2](./sh/sh_function_exec_2) | [ud()](./sh/sh_function_exec_2#L108-L384) | 上のディレクトリに移動するfunction.<br/>cd(Change Directory) → ud(Up Directory)<br/>...という命名方式 |
| [./sh/sh_function_exec_2](./sh/sh_function_exec_2) | [sortsave()](./sh/sh_function_exec_2#L102-L105) | sortしてその内容をそのまま保存する<br/>※ moreutils必須 |
| [./sh/sh_function_exec_2](./sh/sh_function_exec_2) | [wd()](./sh/sh_function_exec_2#L92-L95) | 本日のDownloadディレクトリへの遷移用function |
| [./sh/sh_function_exec_2](./sh/sh_function_exec_2) | [Work()](./sh/sh_function_exec_2#L369-L60) | ## ==========<br/>ファイル操作関係<br/>## ==========<br/>Workディレクトリの作成・移動 |
| [./sh/sh_function_exec_2](./sh/sh_function_exec_2) | [url2json()](./sh/sh_function_exec_2#L41-L55) | パイプから受け付けたurl encodeされたパラメータをjsonにして出力するfunction(要php) |
| [./sh/sh_function_exec_2](./sh/sh_function_exec_2) | [json2url()](./sh/sh_function_exec_2#L20-L38) | パイプから受け付けたjsonをurlencodeして出力するfunction(要php) |
| [./sh/sh_function_iterm2](./sh/sh_function_iterm2) | [imgls()](./sh/sh_function_iterm2#L223-L89) | imgls():<br/>  about:<br/>    iTerm2上で画像ファイルをls状に表示するfunction<br/>  origin:<br/>    https://www.iterm2.com/utilities/imgls<br/>  require:<br/>    - php |
| [./sh/sh_function_iterm2](./sh/sh_function_iterm2) | [imgview()](./sh/sh_function_iterm2#L197-L42) | imgview():<br/>  about:<br/>    iTerm2上で画像ファイルを表示するfunction<br/>  origin:<br/>     https://www.iterm2.com/utilities/imgcat |
| [./sh/sh_function_iterm2](./sh/sh_function_iterm2) | [____show_imgls_list_file()](./sh/sh_function_iterm2#L223-L89) | ____show_imgls_list_file():<br/>  about:<br/>    imglsの結果を出力するfunction |
| [./sh/sh_function_iterm2](./sh/sh_function_iterm2) | [____show_imgview_help()](./sh/sh_function_iterm2#L197-L80) | ____show_imgview_help():<br/>  about:<br/>    imgview用のhelpを出力するためのfunction |
| [./sh/sh_function_iterm2](./sh/sh_function_iterm2) | [____show_error()](./sh/sh_function_iterm2#L197-L73) | ____show_error():<br/>  about:<br/>    エラーメッセージを出力するfunction |
| [./sh/sh_function_iterm2](./sh/sh_function_iterm2) | [____print_image()](./sh/sh_function_iterm2#L197-L40) | ____print_image():<br/>  about:<br/>    iTerm2にイメージを出力するimgview用のfunction |
| [./sh/sh_function_iterm2](./sh/sh_function_iterm2) | [____check_dependency()](./sh/sh_function_iterm2#L223-L30) | ____check_dependency():<br/>  about:<br/>    コマンドの有無を確認するfunction。 |
| [./sh/sh_function_iterm2](./sh/sh_function_iterm2) | [____print_st()](./sh/sh_function_iterm2#L121-L17) | ____print_st():<br/>  about:<br/>    More of the tmux workaround described above. |
| [./sh/sh_function_iterm2](./sh/sh_function_iterm2) | [____print_osc()](./sh/sh_function_iterm2#L121-L6) | ____print_osc():<br/>  about:<br/>    tmuxなどの場合にOSCエスケープシーケンスを出力するためのfunction。 |
| [./sh/sh_function_keybind](./sh/sh_function_keybind) | [__toggle_doublequote_format()](./sh/sh_function_keybind#L196-L198) | 入力中の内容をダブルクオーテーションで囲む |
| [./sh/sh_function_keybind](./sh/sh_function_keybind) | [__toggle_singlequote_format()](./sh/sh_function_keybind#L190-L192) | 入力中の内容をシングルクオーテーションで囲む |
| [./sh/sh_function_keybind](./sh/sh_function_keybind) | [__toggle_substitution_format()](./sh/sh_function_keybind#L184-L186) | コマンド置換形式に変換する |
| [./sh/sh_function_keybind](./sh/sh_function_keybind) | [__pet_set()](./sh/sh_function_keybind#L163-L180) | pet searchをしてコマンドラインを置き換えるkeybind用のfunction |
| [./sh/sh_function_keybind](./sh/sh_function_keybind) | [__history_selection_insert()](./sh/sh_function_keybind#L157-L159) | Ctrl + R でhistory検索をして現在カーソルに差し込みをするfunction |
| [./sh/sh_function_keybind](./sh/sh_function_keybind) | [__history_selection()](./sh/sh_function_keybind#L159-L86) | Ctrl + R でhistory検索をする(peco,bocoを使用) |
| [./sh/sh_function_keybind](./sh/sh_function_keybind) | [__copy_current_command()](./sh/sh_function_keybind#L58-L80) | Ctrl + X, Cで、現在のプロンプトのコマンドをコピーする(ssh先でも使えるように、OSCエスケープシーケンスを使用)<br/>NOTE: 【前提】 Macの場合、iTerm2を使ってることが前提<br/>NOTE: 【前提】 iTerm2の場合、`Perferences`で`Applications in terminal may access clipboard`にチェックが入ってる必要がある |
| [./sh/sh_function_keybind](./sh/sh_function_keybind) | [__cd_selection()](./sh/sh_function_keybind#L21-L51) | Ctrl + X, Ctrl + Dでcdを行うためのfunction(bash/zsh共通) |
| [./sh/sh_function_keybind](./sh/sh_function_keybind) | [__cd_record()](./sh/sh_function_keybind#L15-L17) | cdのhistoryを記録するためのfunction |
| [./sh/sh_function_replace](./sh/sh_function_replace) | [__pingfunc()](./sh/sh_function_replace#L72-L74) | pingでタイムスタンプを頭につけるためのfunction |
| [./sh/sh_function_replace](./sh/sh_function_replace) | [__mkdirfunc()](./sh/sh_function_replace#L63-L69) | mkdirで、単体のディレクトリが指定された場合はそこにそのまま移動させるためのfunction |
| [./sh/sh_function_replace](./sh/sh_function_replace) | [__sudofunc()](./sh/sh_function_replace#L16-L60) | sudoでfunctionで定義した内容が使えるようにするためのfunction |

## Note

### 実行ファイル・関数テーブル作成用コマンド

```bash
# AppleScript
echo "|File|概要|\n|---|---|";grep -H -a '^-- Description' AppleScripts/* | nkf -w | sed -r 's/:-- Description:/\t/;s/(.+)\t/[\1](\1)\t/'| tb -s$'\t'

# 実行ファイル
(echo "File\t概要\n---\t---";grep -H -a '^# Description' bin/* | nkf -w | sed -r 's/:# Description:/\t/;s/(.+)\t/[\1](\1)\t/')| tb -s$'\t'

# シェル関数
get_shellfunction_table.sh
```
