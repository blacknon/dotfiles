" Copyright(c) 2023 Blacknon. All rights reserved.
" Use of this source code is governed by an MIT license
" that can be found in the LICENSE file.

" ABOUT:
"     基本的な設定(`set xxx` etc...)を記載しているファイル.
" -------------------------------------------------------------
" 文字コード
" ====================
set encoding=utf-8
set fenc=utf-8
scriptencoding utf-8

" 画面表示
" ====================
set number                  " 行番号を表示
set cursorline              " 現在の行を強調表示
set cursorcolumn            " 現在の行を強調表示（縦）
set showcmd                 " 入力中のコマンドをステータスに表示する
set showmatch               " 括弧入力時の対応する括弧を表示
set matchtime=1             " カーソルが飛ぶ時間を0.1秒 * numで指定(showmatchとセットで使用)
set display=lastline        " 長い行でも最後まで出力させる
set ruler                   " ステータスバーにカーソルの現在位置を表示
set shortmess+=O            " ステータスバーにコマンドのステータスメッセージを出力させる
set cmdheight=2             " コマンドライン領域の高さを指定
set pumheight=10            " 補完メニューの高さ指定
set laststatus=2            " ステータスラインを常に表示
set list                    " 不可視文字を可視化
set listchars=tab:▸-        " タブを「▸-」と表示させる


" ファイル処理関連
" ====================
set autoread                                    " 編集中のファイルが変更されたら自動で読み直す
set hidden                                      " バッファが編集中でもその他のファイルを開けるようにする
autocmd BufWritePre * call __retab()            " ファイル保存時(バッファ全体をファイルに書き込むとき)にretabを実行する
autocmd BufWritePost * call __setExecPerm()     " ファイル保存時、条件に合致する場合実行権限を付与する
autocmd SwapExists * let v:swapchoice = 'o'     " swapファイルが見つかった場合は読み取り専用で開く
autocmd BufRead * call __restoreCursorPosition()   " ファイルを開いた際、前回開いてたカーソルの位置に移動する


" カーソル処理関連
" ====================
set smartindent                  " インデントはスマートインデント
set virtualedit=onemore          " 行末の1文字先までカーソルを移動できるように
set backspace=indent,eol,start   " 挿入モードでbackspaceが動作するように定義する


" 補完関連
" ====================
set wildmenu                     " コマンドラインモードで<Tab>キーによるファイル名補完を有効にする
set wildmode=longest:full,full   " コマンドラインモードでのファイル名補完の挙動を指定
set history=5000                 " コマンドラインモードで保存するコマンド履歴の数
set iskeyword-=-_(){}            " キーワードから記号等を削除


" タブ・インデント関連
" ====================
set autoindent      " 改行時に前の行のインデントを継続する
set smartindent     " 改行時に前の行の構文をチェックし次の行のインデントを増減する
set expandtab       " Tab文字を半角スペースにする
set tabstop=4       " 行頭以外のTab文字の表示幅（スペースいくつ分）
set shiftwidth=4    " 行頭でのTab文字の表示幅
set softtabstop=4   " Tabキー押下時に入力するスペースの幅


" 検索関連
" ====================
set ignorecase   " 検索文字列が小文字の場合は大文字小文字を区別なく検索する
set smartcase    " 検索文字列に大文字が含まれている場合は区別して検索する
set incsearch    " 検索文字列入力時に順次対象文字列にヒットさせる
set wrapscan     " 検索時に最後まで行ったら最初に戻る
set hlsearch     " 検索語をハイライト表示


" マウス関連
" ====================
" マウス使用時にスクロールを有効化
if has('mouse')
    set mouse=a
    if has('mouse_sgr')
        set ttymouse=sgr
    elseif v:version > 703 || v:version is 703 && has('patch632')
        set ttymouse=sgr
    else
        set ttymouse=xterm2
    endif
endif


" Shebang
" ====================
" 拡張子に応じて自動でShebangを追加する
augroup Shebang
  " perl
  autocmd BufNewFile *.pl 0put =\"#!/usr/bin/perl\"|$
  autocmd BufReadPre *.pl if getfsize(@%) <= 1 | 0put \"#!/usr/bin/perl\" |  endif

  " python
  autocmd BufNewFile *.py 0put =\"#!/usr/bin/env python3\<nl># -*- encoding: UTF-8 -*-\<nl>\"|$
  autocmd BufReadPre *.py if getfsize(@%) <= 1 | 0put =\"#!/usr/bin/env python3\<nl># -*- encoding: UTF-8 -*-\<nl>\" |  endif

  " ruby
  autocmd BufNewFile *.rb 0put =\"#!/usr/bin/env ruby\<nl># -*- encoding: UTF-8 -*-\<nl>\"|$
  autocmd BufReadPre *.rb if getfsize(@%) <= 1 | 0put =\"#!/usr/bin/env ruby\<nl># -*- encoding: UTF-8 -*-\<nl>\" |  endif

  " shell script (bash)
  autocmd BufNewFile *.sh 0put =\"#!/bin/bash\<nl>\"|$
  autocmd BufReadPre *.sh if getfsize(@%) <= 1 | 0put =\"#!/bin/bash\<nl>\" |  endif
augroup END


" その他
" ====================
set visualbell                                 " ビープ音を可視化s
set nocompatible                               " vi互換の動作無効化
set clipboard=unnamed,autoselect,unnamedplus   " 選択した箇所をクリップボードにコピー
