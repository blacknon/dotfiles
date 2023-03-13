" Copyright(c) 2023 Blacknon. All rights reserved.
" Use of this source code is governed by an MIT license
" that can be found in the LICENSE file.

" ABOUT:
"     syntax/completion関係の設定を指定しているファイル.
"     ローカル・リモート共通の設定を記載している.
" -------------------------------------------------------------
" 基本設定
" ====================
" syntaxを有効化
syntax on

" ファイルタイプからの識別を有効化
filetype on
filetype plugin indent on

" SyntaxHighlightの色を変更する
highlight Comment term=bold ctermfg=Cyan guifg=#80a0ff gui=bold

" 補完時の動作について定義
"   - menuone ... 対象が1件しかなくても常に補完ウィンドウを表示
"   - noinsert ... 補完ウィンドウを表示時に挿入しない
"   - preview ... プレビューウインドウに追加情報を表示(補間関数が対応している場合のみ)
set completeopt=menuone,noinsert,preview

" オムニ補完の設定（insertモードでCtrl+oで候補を出す、Ctrl+n Ctrl+pで選択、Ctrl+yで確定）
set omnifunc=syntaxcomplete#Complete

" syntaxが有効な場合の処理
if has('syntax')
  " 全角スペースの強調表示処理
  augroup ZenkakuSpace
    " functionを指定
    function! __zenkakuSpace()
      highlight __zenkakuSpace cterm=underline ctermfg=darkgrey gui=underline guifg=darkgrey
    endfunction

    autocmd!
    " ZenkakuSpaceをカラーファイルで設定するなら次の行は削除
    autocmd ColorScheme       * call __zenkakuSpace()
    " 全角スペースのハイライト指定
    autocmd VimEnter,WinEnter * match __zenkakuSpace /　/
    autocmd VimEnter,WinEnter * match __zenkakuSpace '\%u3000'
  augroup END
  call __zenkakuSpace()

  " Insertモードでステータスバーの色を変更する
  augroup InsertHook
    autocmd!
    autocmd InsertEnter * call __statusLine('Enter')
    autocmd InsertLeave * call __statusLine('Leave')
  augroup END
endif


" Golang
" ====================
set runtimepath+="$GOROOT/misc/vim"
autocmd FileType go autocmd BufWritePre Fmt
set rtp+="$GOPATH/src/github.com/nsf/gocode/vim"
set rtp+="$GOPATH/src/github.com/golang/lint/misc/vim"


" php
" ====================
" vim標準のphpオプションを有効化(global変数を指定することで有効化される)
let g:php_baselib             = 1 " Baselibメソッドのハイライト
let g:php_sql_query           = 1 " 文字列中のSQLをハイライト
let g:php_htmlInStrings       = 1 " 文字列中のHTMLをハイライト
let g:php_noShortTags         = 1 " <? をハイライト除外にする
let g:php_parent_error_close  = 1 " カッコが閉じていない場合にハイライト
