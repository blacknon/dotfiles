# dotfiles

## About

自分(Blacknon)のクライアント環境用dotfiles。

## 基本方針

ローカルではzshを、リモートではbashを用いる。

リモート先でも[lssh](https://github.com/blacknon/lssh)を使ってローカルの設定(shell function含む)を転送、利用するため、実行コマンドは可能な限りシェル関数として実装する。

## ディレクトリ・ファイル構成

| PATH                                                                              | 概要                                                                               |
| --------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------- |
| [.zshrc](.zshrc)                                                                  | zsh用のrcファイル。小分けにしたファイル郡をsourceするだけ。                        |
| [.bashrc](.bashrc)                                                                | bash用のrcファイル。小分けにしたファイル郡をsourceするだけ。                       |
| [.vimrc](.vimrc)                                                                  | vimrcファイル。ssh先に持っていきやすくするため1ファイルにすべて設定を記述する。    |
| [.tmux.conf](.tmux.conf)                                                          | vimrcファイル。ssh先に持っていきやすくするため1ファイルにすべて設定を記述する。    |
| [sh](sh)                                                                          | bash/zshで共通の設定・関数を格納するディレクトリ。                                 |
| [sh/alias.sh](sh/alias.sh)                                                        | aliasの設定ファイル                                                                |
| [sh/exportsh](sh/export.sh)                                                       | export周りの処理を記述しているファイル                                             |
| [sh/other.sh](sh/other.sh)                                                        | その他                                                                             |
| [sh/functions/command_not_found_hundle](sh/functions/command_not_found_hundle.sh) | aliasの設定ファイル                                                                |
| [sh/functions/common.sh](sh/functions/common.sh)                                  | shell関数内で利用している関数を記述しているファイル                                |
| [sh/functions/exec_1.sh](sh/functions/exec_1.sh)                                  | インタラクティブシェルから実行する関数1(ssh先に持っていくもの)                     |
| [sh/functions/exec_2.sh](sh/functions/exec_2.sh)                                  | インタラクティブシェルから実行する関数2(ssh先に持っていかない・利用頻度の低いもの) |
| [sh/functions/iterm2.sh](sh/functions/iterm2.sh)                                  | iTerm2で利用する関数                                                               |
| [sh/functions/keybind.sh](sh/functions/keybind.sh)                                | Keybindで使用する関数                                                              |
| [sh/functions/replace.sh](sh/functions/replace.sh)                                | 既存のコマンドからaliasで置き換える関数                                            |


## 実行コマンド・関数

### AppleScript

|File|概要|
|---|---|
| [AppleScripts/music_rename.applescript](AppleScripts/music_rename.applescript)            |  iTunesの選択中のタイトル名を、`~/Work/YYYYmm/YYYYmmdd/itunes.txt`のタイトルに変換していくスクリプト(`~/Work/YYYYmm/YYYYmmdd/itunes.txt`はShift-JISで記述する必要があるので注意) |
| [AppleScripts/music_settracknum.applescript](AppleScripts/music_settracknum.applescript)  |  iTunesの選択中の曲にtrack numberを連番でセットしていくapple script.                                                                                            |

### 実行ファイル

| File                                                              | 概要                                                                                                             |
| ---                                                               | ---                                                                                                                |
| [bin/get_proxy](bin/get_proxy)                                    |  pubproxy.comのapiからランダムにSocks5 proxyを取得するスクリプト                                 |
| [bin/get_proxylist](bin/get_proxylist)                            |  `www.proxy-list.download`からフリーのプロキシリストを取得してURI形式でリスト取得するスクリプト |
| [bin/get_shellfunction_table.sh](bin/get_shellfunction_table.sh)  |  シェル関数とその説明を`sh_function*`ファイルから取得してtableにするスクリプト        |
| [bin/hwatch_logviewer.py](bin/hwatch_logviewer.py)                |  [hwatch](https://github.com/blacknon/hwatch)のlogをパースして出力するスクリプト                   |
| [bin/json2urlparam.py](bin/json2urlparam.py)                      |  json文字列をPOSTできるURL EncodeしたQuery stringに変換するスクリプト                           |
| [bin/mkworkbackup.sh](bin/mkworkbackup.sh)                        |  ~/Today/backupに、雑にバックアップを作成するスクリプト. mkworkln.shから該当箇所だけ抜き出して動くようにしたもの. |
| [bin/mkworkln.sh](bin/mkworkln.sh)                                |  ~/Work整備のcron用スクリプト                                                                             |
| [bin/my-pj](bin/my-pj)                                            |  期間の決まっているプロジェクト用のディレクトリ生成スクリプト(~/Workとセット)    |
| [bin/myconky.sh](bin/myconky.sh)                                  |  dotfiles配下のconkyrcを利用したconkyの管理用スクリプト(Desktop Linux用)                         |
| [bin/mydocker-setup](bin/mydocker-setup)                          |  ローカルで使うDockerの取得用スクリプト                                                            |
| [bin/rot.py](bin/rot.py)                                          |  文字列のROT対応用スクリプト(未作成)                                                                |
| [bin/update_ltmux](bin/update_ltmux)                              |  ssh先に持っていくtmux設定付きfunctionの作成スクリプト                                          |
| [bin/update_lvim](bin/update_lvim)                                |  ssh先に持っていくvim設定付きfunctionの作成スクリプト                                           |

### シェル関数

| File | 関数名 | 概要 |
| ---- | ----- | --- |
| [./sh/functions/common.sh](./sh/functions/common.sh) | [____get_envdata()](./sh/functions/common.sh#L118-L150) | 現在使っているfunctionや環境変数、aliasをbase64にして返す関数<br/>setでfunction/envを、aliasでエイリアスを取得させる |
| [./sh/functions/common.sh](./sh/functions/common.sh) | [____get_rcdata()](./sh/functions/common.sh#L101-L114) | ローカルマシンで使用しているbashrcやvimrcのfunctionを読み込んで<br/>base64にして返す関数 |
| [./sh/functions/common.sh](./sh/functions/common.sh) | [____toggle_surround_format()](./sh/functions/common.sh#L57-L97) | 入力中の内容を引数で指定された文字列で囲む(カーソル位置〜行末) |
| [./sh/functions/common.sh](./sh/functions/common.sh) | [____get_escape()](./sh/functions/common.sh#L48-L54) | エスケープした文字を返す |
| [./sh/functions/common.sh](./sh/functions/common.sh) | [____1char2dotchar()](./sh/functions/common.sh#L33-L45) | 各文字を1文字だけドット(.)にした文字列の一覧を出力する(agrepで使用) |
| [./sh/functions/common.sh](./sh/functions/common.sh) | [____shift1chars()](./sh/functions/common.sh#L14-L30) | 各文字を1文字ずつずらした文字列を出力する(agrepで使用) |
| [./sh/functions/exec_1.sh](./sh/functions/exec_1.sh) | [ttmux()](./sh/functions/exec_1.sh#L666-L671) | tmux内で実行すると、ウィンドウを分割してスタートさせる |
| [./sh/functions/exec_1.sh](./sh/functions/exec_1.sh) | [check_cert()](./sh/functions/exec_1.sh#L634-L638) | OpenSSLでの、リモートの証明書の期限をチェックするための関数 |
| [./sh/functions/exec_1.sh](./sh/functions/exec_1.sh) | [get_globalip()](./sh/functions/exec_1.sh#L629-L631) | Get Global ip address |
| [./sh/functions/exec_1.sh](./sh/functions/exec_1.sh) | [get_ip()](./sh/functions/exec_1.sh#L595-L626) | ipアドレスとinterfaceの組み合わせをシンプルなリストにして出力する |
| [./sh/functions/exec_1.sh](./sh/functions/exec_1.sh) | [pping()](./sh/functions/exec_1.sh#L518-L592) | ex.)<br/>    pping target1 target2...<br/>parallel port ping |
| [./sh/functions/exec_1.sh](./sh/functions/exec_1.sh) | [ddig()](./sh/functions/exec_1.sh#L486-L512) | スペース区切りでリストを引数として与えると、その名前解決の結果をカンマ区切りで出力する関数<br/>ex.)<br/>    ddig abc{1..10}.com @{8.8.8.8,1.1.1.1} |
| [./sh/functions/exec_1.sh](./sh/functions/exec_1.sh) | [rarls()](./sh/functions/exec_1.sh#L453-L468) | rarファイル内のデータをlist表示するfunction。 |
| [./sh/functions/exec_1.sh](./sh/functions/exec_1.sh) | [zipcat()](./sh/functions/exec_1.sh#L429-L447) | zipファイル内のファイルを指定して標準出力に書き出すfunction。 |
| [./sh/functions/exec_1.sh](./sh/functions/exec_1.sh) | [zipls()](./sh/functions/exec_1.sh#L406-L426) | zipファイル内のデータをlist表示するfunction。 |
| [./sh/functions/exec_1.sh](./sh/functions/exec_1.sh) | [targrep()](./sh/functions/exec_1.sh#L346-L403) | tarファイル内のファイルに対してgrep(相当の処理)を行うfunction。<br/>awkを利用する。 ※ GNU tarでないと動作しないので注意 |
| [./sh/functions/exec_1.sh](./sh/functions/exec_1.sh) | [tarcat()](./sh/functions/exec_1.sh#L318-L340) | tarファイル内のファイルを指定して標準出lflg_l力に書き出すfunction。 |
| [./sh/functions/exec_1.sh](./sh/functions/exec_1.sh) | [tarls()](./sh/functions/exec_1.sh#L287-L313) | tarファイル内のデータをlist表示するfunction。 |
| [./sh/functions/exec_1.sh](./sh/functions/exec_1.sh) | [todaydir()](./sh/functions/exec_1.sh#L280-L284) | make today dir |
| [./sh/functions/exec_1.sh](./sh/functions/exec_1.sh) | [find_bigfile()](./sh/functions/exec_1.sh#L257-L277) | サイズの大きいファイルをサーチする |
| [./sh/functions/exec_1.sh](./sh/functions/exec_1.sh) | [sw()](./sh/functions/exec_1.sh#L249-L254) | ファイルの入れ替え(スイッチ) |
| [./sh/functions/exec_1.sh](./sh/functions/exec_1.sh) | [dec_jwt()](./sh/functions/exec_1.sh#L234-L242) | 標準入力から受け付けたjwtトークンをDecodeする |
| [./sh/functions/exec_1.sh](./sh/functions/exec_1.sh) | [enc_unicode()](./sh/functions/exec_1.sh#L218-L231) | 標準入力から取得した値をUnicode Escape Sequence形式に変換する<br/>※ nkfが必要 |
| [./sh/functions/exec_1.sh](./sh/functions/exec_1.sh) | [enc_hex()](./sh/functions/exec_1.sh#L212-L214) | 標準入力から取得した値をHex形式(\xXX)にして返す |
| [./sh/functions/exec_1.sh](./sh/functions/exec_1.sh) | [dec_html()](./sh/functions/exec_1.sh#L207-L209) | 標準入力から受付たhtmlエンティティ形式のデータをもとに戻す |
| [./sh/functions/exec_1.sh](./sh/functions/exec_1.sh) | [enc_html()](./sh/functions/exec_1.sh#L165-L204) | 標準入力から取得した値をhtmlエンティティ形式に変換する |
| [./sh/functions/exec_1.sh](./sh/functions/exec_1.sh) | [dec_url()](./sh/functions/exec_1.sh#L160-L162) | 標準入力から取得したパーセントエンコーディングを戻す |
| [./sh/functions/exec_1.sh](./sh/functions/exec_1.sh) | [enc_url()](./sh/functions/exec_1.sh#L115-L157) | 標準入力から取得した値をパーセントエンコーディングする<br/>    -n ... nkfを使用してパーセントエンコーディングする(-a,-zは無効化)<br/>    -a ... ascii文字含め全部をパーセントエンコーディングする(-nのときは無効)<br/>    -z ... Null区切りにして改行もパーセントエンコーディング対象とする |
| [./sh/functions/exec_1.sh](./sh/functions/exec_1.sh) | [aigrep()](./sh/functions/exec_1.sh#L57-L97) | あいまいgrepをするfunction<br/>(1文字違う文字列(abc=>{.bc,a.c,ab.})と、1文字ずつずらした文字列(abc=>{abc,bac,acb})でgrepをする(typoも発見できる)) |
| [./sh/functions/exec_1.sh](./sh/functions/exec_1.sh) | [joinby()](./sh/functions/exec_1.sh#L49-L53) | Join array |
| [./sh/functions/exec_1.sh](./sh/functions/exec_1.sh) | [ts()](./sh/functions/exec_1.sh#L28-L43) | 標準入力で受け付けた行頭にタイムスタンプ(YYYY-MM-DD HH:MM:SS: )を付与する |
| [./sh/functions/exec_2.sh](./sh/functions/exec_2.sh) | [mkinst()](./sh/functions/exec_2.sh#L469-L471) | make install を一気に行うためのfunction |
| [./sh/functions/exec_2.sh](./sh/functions/exec_2.sh) | [scx()](./sh/functions/exec_2.sh#L460-L462) | 完全にlocalで実行する用のscのラッパーfunction。<br/>bashrcをsourceした状態で引数のコマンドを実行させるので、functionも実行できるようにする。 |
| [./sh/functions/exec_2.sh](./sh/functions/exec_2.sh) | [sc()](./sh/functions/exec_2.sh#L399-L462) | scriptコマンドで/Work配下にターミナルログを記録する |
| [./sh/functions/exec_2.sh](./sh/functions/exec_2.sh) | [battery()](./sh/functions/exec_2.sh#L380-L389) | バッテリー残量を取得 |
| [./sh/functions/exec_2.sh](./sh/functions/exec_2.sh) | [pe()](./sh/functions/exec_2.sh#L369-L373) | petからsnippetを実行する(実行後はhistoryに登録) |
| [./sh/functions/exec_2.sh](./sh/functions/exec_2.sh) | [prev()](./sh/functions/exec_2.sh#L363-L366) | 直前に実行したコマンドをpetに登録する |
| [./sh/functions/exec_2.sh](./sh/functions/exec_2.sh) | [docker_login()](./sh/functions/exec_2.sh#L297-L356) | 起動中のdockerコンテナにログインするためのfunction。<br/>usage:<br/>    docker_login コンテナ名<br/>    docker_login -e コンテナ名 # 現在のfunctionを利用してログイン<br/>    docker_login -r コンテナ名 # rcファイルを利用してログイン |
| [./sh/functions/exec_2.sh](./sh/functions/exec_2.sh) | [docker_runin()](./sh/functions/exec_2.sh#L219-L288) | dockerコンテナを起動してログインするためのfunction。<br/>usage:<br/>    docker_runin コンテナ名<br/>    docker_runin -e コンテナ名 # 現在のfunctionを利用して起動・ログイン<br/>    docker_runin -r コンテナ名 # rcファイルを利用して起動・ログイン<br/>    docker_runin -v ローカルPATH:コンテナPATH コンテナ名 # マウント指定(-r/-eオプション併用可)<br/>NOTE: docker-machine環境下でvolume mountがうまくいかなくなった場合、とりあえずアップグレードすることで直る場合がある。まずはそれをやってみること。 |
| [./sh/functions/exec_2.sh](./sh/functions/exec_2.sh) | [sortsave()](./sh/functions/exec_2.sh#L202-L205) | sortしてその内容をそのまま保存する<br/>※ moreutils必須 |
| [./sh/functions/exec_2.sh](./sh/functions/exec_2.sh) | [gscd()](./sh/functions/exec_2.sh#L168-L195) | gitリポジトリ内のディレクトリを選択して移動する |
| [./sh/functions/exec_2.sh](./sh/functions/exec_2.sh) | [gcd()](./sh/functions/exec_2.sh#L155-L165) | gitリポジトリのルートディレクトリに移動する |
| [./sh/functions/exec_2.sh](./sh/functions/exec_2.sh) | [ud()](./sh/functions/exec_2.sh#L143-L152) | 上のディレクトリに移動するfunction.<br/>cd(Change Directory) → ud(Up Directory)<br/>...という命名方式 |
| [./sh/functions/exec_2.sh](./sh/functions/exec_2.sh) | [tw()](./sh/functions/exec_2.sh#L120-L138) | 現在いるWorkディレクトリを識別し、その翌日のディレクトリへ移動する |
| [./sh/functions/exec_2.sh](./sh/functions/exec_2.sh) | [yw()](./sh/functions/exec_2.sh#L117-L99) | 現在いるWorkディレクトリを識別し、その前日のディレクトリへ移動する |
| [./sh/functions/exec_2.sh](./sh/functions/exec_2.sh) | [wd()](./sh/functions/exec_2.sh#L93-L96) | 本日のDownloadディレクトリへの遷移用function |
| [./sh/functions/exec_2.sh](./sh/functions/exec_2.sh) | [ww()](./sh/functions/exec_2.sh#L62-L90) | Workディレクトリの作成・移動 |
| [./sh/functions/exec_2.sh](./sh/functions/exec_2.sh) | [url2json()](./sh/functions/exec_2.sh#L41-L55) | パイプから受け付けたurl encodeされたパラメータをjsonにして出力するfunction(要php) |
| [./sh/functions/exec_2.sh](./sh/functions/exec_2.sh) | [json2url()](./sh/functions/exec_2.sh#L20-L38) | パイプから受け付けたjsonをurlencodeして出力するfunction(要php) |
| [./sh/functions/iterm2.sh](./sh/functions/iterm2.sh) | [imgls()](./sh/functions/iterm2.sh#L208-L223) | imgls():<br/>  about:<br/>    iTerm2上で画像ファイルをls状に表示するfunction<br/>  origin:<br/>    https://www.iterm2.com/utilities/imgls<br/>  require:<br/>    - php |
| [./sh/functions/iterm2.sh](./sh/functions/iterm2.sh) | [imgview()](./sh/functions/iterm2.sh#L129-L197) | imgview():<br/>  about:<br/>    iTerm2上で画像ファイルを表示するfunction<br/>  origin:<br/>     https://www.iterm2.com/utilities/imgcat |
| [./sh/functions/iterm2.sh](./sh/functions/iterm2.sh) | [____show_imgls_list_file()](./sh/functions/iterm2.sh#L121-L92) | ____show_imgls_list_file():<br/>  about:<br/>    imglsの結果を出力するfunction |
| [./sh/functions/iterm2.sh](./sh/functions/iterm2.sh) | [____show_imgview_help()](./sh/functions/iterm2.sh#L83-L87) | ____show_imgview_help():<br/>  about:<br/>    imgview用のhelpを出力するためのfunction |
| [./sh/functions/iterm2.sh](./sh/functions/iterm2.sh) | [____show_error()](./sh/functions/iterm2.sh#L76-L78) | ____show_error():<br/>  about:<br/>    エラーメッセージを出力するfunction |
| [./sh/functions/iterm2.sh](./sh/functions/iterm2.sh) | [____print_image()](./sh/functions/iterm2.sh#L43-L71) | ____print_image():<br/>  about:<br/>    iTerm2にイメージを出力するimgview用のfunction |
| [./sh/functions/iterm2.sh](./sh/functions/iterm2.sh) | [____check_dependency()](./sh/functions/iterm2.sh#L33-L38) | ____check_dependency():<br/>  about:<br/>    コマンドの有無を確認するfunction。 |
| [./sh/functions/iterm2.sh](./sh/functions/iterm2.sh) | [____print_st()](./sh/functions/iterm2.sh#L20-L28) | ____print_st():<br/>  about:<br/>    More of the tmux workaround described above. |
| [./sh/functions/iterm2.sh](./sh/functions/iterm2.sh) | [____print_osc()](./sh/functions/iterm2.sh#L15-L9) | ____print_osc():<br/>  about:<br/>    tmuxなどの場合にOSCエスケープシーケンスを出力するためのfunction。 |
| [./sh/functions/keybind.sh](./sh/functions/keybind.sh) | [__tw()](./sh/functions/keybind.sh#L226-L231) | twをkeybindで実行する |
| [./sh/functions/keybind.sh](./sh/functions/keybind.sh) | [__yw()](./sh/functions/keybind.sh#L218-L223) | ywをkeybindで実行する |
| [./sh/functions/keybind.sh](./sh/functions/keybind.sh) | [__ww()](./sh/functions/keybind.sh#L210-L215) | wwをkeybindで実行する |
| [./sh/functions/keybind.sh](./sh/functions/keybind.sh) | [__toggle_doublequote_format()](./sh/functions/keybind.sh#L204-L206) | 入力中の内容をダブルクオーテーションで囲む |
| [./sh/functions/keybind.sh](./sh/functions/keybind.sh) | [__toggle_singlequote_format()](./sh/functions/keybind.sh#L198-L200) | 入力中の内容をシングルクオーテーションで囲む |
| [./sh/functions/keybind.sh](./sh/functions/keybind.sh) | [__toggle_substitution_format()](./sh/functions/keybind.sh#L192-L194) | コマンド置換形式に変換する |
| [./sh/functions/keybind.sh](./sh/functions/keybind.sh) | [__pet_set()](./sh/functions/keybind.sh#L171-L188) | pet searchをしてコマンドラインを置き換えるkeybind用のfunction |
| [./sh/functions/keybind.sh](./sh/functions/keybind.sh) | [__history_selection_insert()](./sh/functions/keybind.sh#L165-L167) | Ctrl + R でhistory検索をして現在カーソルに差し込みをするfunction |
| [./sh/functions/keybind.sh](./sh/functions/keybind.sh) | [__history_selection()](./sh/functions/keybind.sh#L167-L86) | Ctrl + R でhistory検索をする(peco,bocoを使用) |
| [./sh/functions/keybind.sh](./sh/functions/keybind.sh) | [__copy_current_command()](./sh/functions/keybind.sh#L58-L80) | Ctrl + X, Cで、現在のプロンプトのコマンドをコピーする(ssh先でも使えるように、OSCエスケープシーケンスを使用)<br/>NOTE: 【前提】 Macの場合、iTerm2を使ってることが前提<br/>NOTE: 【前提】 iTerm2の場合、`Perferences`で`Applications in terminal may access clipboard`にチェックが入ってる必要がある |
| [./sh/functions/keybind.sh](./sh/functions/keybind.sh) | [__cd_selection()](./sh/functions/keybind.sh#L21-L51) | Ctrl + X, Ctrl + Dでcdを行うためのfunction(bash/zsh共通) |
| [./sh/functions/keybind.sh](./sh/functions/keybind.sh) | [__cd_record()](./sh/functions/keybind.sh#L15-L17) | cdのhistoryを記録するためのfunction |
| [./sh/functions/replace.sh](./sh/functions/replace.sh) | [__pingfunc()](./sh/functions/replace.sh#L72-L74) | pingでタイムスタンプを頭につけるためのfunction |
| [./sh/functions/replace.sh](./sh/functions/replace.sh) | [__mkdirfunc()](./sh/functions/replace.sh#L63-L69) | mkdirで、単体のディレクトリが指定された場合はそこにそのまま移動させるためのfunction |
| [./sh/functions/replace.sh](./sh/functions/replace.sh) | [__sudofunc()](./sh/functions/replace.sh#L16-L60) | sudoでfunctionで定義した内容が使えるようにするためのfunction |


## Note

### 実行ファイル・関数テーブル作成用コマンド

```bash
# AppleScript
echo "|File|概要|\n|---|---|";grep -H -a '^-- Description' AppleScripts/* | nkf -w | sed -r 's/:-- Description:/\t/;s/(.+)\t/[\1](\1)\t/'| tb -s $'\t' -t

# 実行ファイル
(echo "File\t概要\n---\t---";grep -H -a '^# Description' bin/* | nkf -w | sed -r 's/:# Description:/\t/;s/(.+)\t/[\1](\1)\t/')| tb -s $'\t' -t

# シェル関数
get_shellfunction_table.sh
```
