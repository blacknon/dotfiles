" ----------
" setting
" ----------
"文字コードをUFT-8に設定
set encoding=utf-8
scriptencoding utf-8
set fenc=utf-8

" 編集中のファイルが変更されたら自動で読み直す
set autoread

" バッファが編集中でもその他のファイルを開けるように
set hidden

" 入力中のコマンドをステータスに表示する
set showcmd

" vi互換の動作無効化
set nocompatible

" 挿入モードでbackspaceが動作するように定義する
set backspace=indent,eol,start

" ステータスバーにコマンドのステータスメッセージを出力させる
set shortmess+=O
set cmdheight=2

" 行番号を表示
set number
"set relativenumber
"F3キーで行番号を現在のカーソルから何行目かの表示に切り替える
nnoremap <F3> :<C-u>setlocal relativenumber!<CR>

" カーソルの現在位置をステータスバーに表示
set ruler

" 現在の行を強調表示
set cursorline

" 現在の行を強調表示（縦）
set cursorcolumn

" 行末の1文字先までカーソルを移動できるように
set virtualedit=onemore

" インデントはスマートインデント
set smartindent

" ビープ音を可視化
set visualbell

" 括弧入力時の対応する括弧を表示
set showmatch
set matchtime=1

" ステータスラインを常に表示
set laststatus=2

" コマンドラインの補完
set wildmode=list:longest

" 長い行でも最後まで出力させる
set display=lastline

" 補完メニューの高さ
set pumheight=10

" 不可視文字を可視化(タブが「▸-」と表示される)
set list listchars=tab:\▸\-

" Tab文字を半角スペースにする
set expandtab

" 行頭以外のTab文字の表示幅（スペースいくつ分）
set tabstop=4

" 行頭でのTab文字の表示幅
set shiftwidth=4

" Tabキー押下時に入力するスペースの幅
set softtabstop=4

" 改行時に前の行のインデントを継続する
set autoindent

" 改行時に前の行の構文をチェックし次の行のインデントを増減する
set smartindent


" ----------
" 検索
" ----------
" 検索文字列が小文字の場合は大文字小文字を区別なく検索する
set ignorecase

" 検索文字列に大文字が含まれている場合は区別して検索する
set smartcase

" コメントで始まる行のインデントを保持する
inoremap # X<C-H>#

" 検索文字列入力時に順次対象文字列にヒットさせる
set incsearch

" 検索時に最後まで行ったら最初に戻る
set wrapscan

" 検索語をハイライト表示
set hlsearch

" ESC連打でハイライト解除
nmap <Esc><Esc> :nohlsearch<CR><Esc>


" ----------
" Syntax
" ----------
" syntaxの有効化
syntax on

" ファイルタイプから識別させる
filetype on
filetype plugin indent on

" 補完時の動作について定義
set completeopt=menu,preview

" GolangのSyntaxHighlight設定
set runtimepath+=$GOROOT/misc/vim
autocmd FileType go autocmd BufWritePre Fmt
set rtp+=$GOPATH/src/github.com/nsf/gocode/vim
set rtp+=$GOPATH/src/github.com/golang/lint/misc/vim
set completeopt=menu,preview

" SyntaxHighlightの色を変更する
highlight Comment term=bold ctermfg=Cyan guifg=#80a0ff gui=bold

" 自動補完
set completeopt=menuone
for k in split("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_",'\zs')
    exec "imap " . k . " " . k . "<C-N><C-P>"
endfor
imap <expr> <TAB> pumvisible() ? "\<Down>" : "\<Tab>"

" phpの補完について有効化
let g:php_baselib       = 1
let g:php_htmlInStrings = 1
let g:php_noShortTags   = 1
let g:php_sql_query     = 1
set omnifunc=phpcomplete#CompletePHP

" 全角スペースの強調表示
" デフォルトのZenkakuSpaceを定義
function! ZenkakuSpace()
  highlight ZenkakuSpace cterm=underline ctermfg=darkgrey gui=underline guifg=darkgrey
endfunction

if has('syntax')
  augroup ZenkakuSpace
    autocmd!
    " ZenkakuSpaceをカラーファイルで設定するなら次の行は削除
    autocmd ColorScheme       * call ZenkakuSpace()
    " 全角スペースのハイライト指定
    autocmd VimEnter,WinEnter * match ZenkakuSpace /　/
    autocmd VimEnter,WinEnter * match ZenkakuSpace '\%u3000'
  augroup END
  call ZenkakuSpace()
endif

" カッコの自動補完
inoremap { {}<Left>
inoremap {<Enter> {}<Left><CR><ESC><S-o>
inoremap ( ()<ESC>i
inoremap (<Enter> ()<Left><CR><ESC><S-o>


" ----------
" 操作系
" ----------
" 折り返し時に表示行単位での移動できるようにする
nnoremap j gj
nnoremap k gk

" ペースト時にpasteモードへ自動変更
if &term =~ "xterm"
    let &t_ti .= "\e[?2004h"
    let &t_te .= "\e[?2004l"
    let &pastetoggle = "\e[201~"

    function XTermPasteBegin(ret)
        set paste
        return a:ret
    endfunction

    noremap <special> <expr> <Esc>[200~ XTermPasteBegin("0i")
    inoremap <special> <expr> <Esc>[200~ XTermPasteBegin("")
    cnoremap <special> <Esc>[200~ <nop>
    cnoremap <special> <Esc>[201~ <nop>
endif

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

" コマンドモードの補完
set wildmenu
set wildmode=longest:full,full

" 保存するコマンド履歴の数
set history=5000

" ファイル保存時にretabを実行
function! s:remove_dust()
    let cursor = getpos(".")
    " 保存時に行末の空白を除去する
    %s/\s\+$//ge
    " 保存時にretabをする
    :retab
    call setpos(".", cursor)
    unlet cursor
endfunction
autocmd BufWritePre * call <SID>remove_dust()

" swapファイルが見つかった場合は読み取り専用で開く
augroup swapchoice-readonly
    autocmd!
    autocmd SwapExists * let v:swapchoice = 'o'
augroup END

" 選択した箇所をクリップボードにコピー
set clipboard=unnamed,autoselect,unnamedplus

" undo履歴を~/.vim/undoに外出しする
" @TODO ディレクトリがない場合は自動生成させる
" https://qiita.com/tamanobi/items/8f013cce36881af8cee3

" ----------
" キーバインド
" ----------
" 数字のインクリメント・デクリメントのショートカット割当
nnoremap + <C-a>
nnoremap - <C-x>

" Backspace で削除をする(X相当の処理)
noremap <BS> hx

" ctrl + s で保存
noremap  <C-S>      :update<CR>
vnoremap <C-S> <C-C>:update<CR>
inoremap <C-S> <C-O>:update<CR>

" ctrl + q で終了
noremap  <silent> <C-Q>      :q<CR>
vnoremap <silent> <C-Q> <C-C>:q<CR>
inoremap <silent> <C-Q> <C-O>:q<CR>

" ctrl + f で検索モードに


" ctrl + a で行頭へ移動
noremap  <silent> <C-A> 0
vnoremap <silent> <C-A> <C-C>0
inoremap <silent> <C-A> <C-O>0

" ctrl + e で行末へ移動
noremap  <silent> <C-E> $
vnoremap <silent> <C-E> <C-C>$
inoremap <silent> <C-E> <C-O>$

" alt + left で単語を一つ戻る
noremap  <ESC><ESC>[D  <S-Left>
noremap  <A-Left>      <S-Left>
cnoremap <ESC><ESC>[D  <S-Left>
cnoremap <A-Left>      <S-Left>
vnoremap <ESC><ESC>[D  <S-Left>
vnoremap <A-Left>      <S-Left>
inoremap <ESC><ESC>[D  <S-Left>
inoremap <A-Left>      <S-Left>

" alt + right で単語を一つ進む
noremap  <ESC><ESC>[C  <S-Right>
noremap  <A-Right>     <S-Right>
cnoremap <ESC><ESC>[C  <S-Right>
cnoremap <A-Right>     <S-Right>
vnoremap <ESC><ESC>[C  <S-Right>
vnoremap <A-Right>     <S-Right>
inoremap <ESC><ESC>[C  <S-Right>
inoremap <A-Right>     <S-Right>

" alt + up で空行区切りの段落を一つ上がる
noremap  <ESC>[A       {k
noremap  <A-Up>        {k
vnoremap <ESC>[A       <C-C>{<C-C>k
vnoremap <A-Up>        <C-C>{<C-C>k
inoremap <ESC>[A       <C-O>{<C-O>k
inoremap <A-Up>        <C-O>{<C-O>k

" alt + down で空行区切りの段落を一つ下がる
noremap  <ESC>[B       }j
noremap  <A-Down>      }j
vnoremap <ESC>[B       <C-C>}<C-C>j
vnoremap <A-Down>      <C-C>}<C-C>j
inoremap <ESC>[B       <C-O>}<C-O>j
inoremap <A-Down>      <C-O>}<C-O>j

" alt + Backspaceで単語を削除する
" TODO(blacknon): 区切り文字？だと右側も削除されることがあるので、修正する
noremap  <ESC><BS>     <S-Left>dw
noremap  <A-BS>        <S-Left>dw
vnoremap <ESC><BS>     <S-Left><C-C>dw
vnoremap <A-BS>        <S-Left><C-C>dw
inoremap <ESC><BS>     <S-Left><C-O>dw
inoremap <A-BS>        <S-Left><C-O>dw

" shift + x,alt + x でカーソルから右の単語を削除する
" (カーソル以降の行をザクッと削除はShift + Dで。Insert modeでは非対応
noremap X       dw
noremap <ESC>x  dw
noremap <A-X>   dw

" ctrl + z でundo (Insert modeでは非対応)
noremap <C-Z> u

" ctrl + y でredo (Insert modeでは非対応)
noremap <C-Y> <C-R>

" 「w!!」でsudoで保存する
cnoremap w!! w !sudo tee > /dev/null %<CR>


" ----------
" その他
" ----------
" 挿入モード時、ステータスラインの色を変更する
let g:hi_insert = 'highlight StatusLine guifg=darkblue guibg=darkgreen gui=none ctermfg=blue ctermbg=green cterm=none'

if has('syntax')
  augroup InsertHook
    autocmd!
    autocmd InsertEnter * call s:StatusLine('Enter')
    autocmd InsertLeave * call s:StatusLine('Leave')
  augroup END
endif

let s:slhlcmd = ''
function! s:StatusLine(mode)
  if a:mode == 'Enter'
    silent! let s:slhlcmd = 'highlight ' . s:GetHighlight('StatusLine')
    silent exec g:hi_insert
  else
    highlight clear StatusLine
    silent exec s:slhlcmd
  endif
endfunction

" ファイルを開いた際、前回開いてたカーソルの位置に移動する
augroup vimrcEx
  au BufRead * if line("'\"") > 0 && line("'\"") <= line("$") |
  \ exe "normal g`\"" | endif
augroup END

function! s:GetHighlight(hi)
  redir => hl
  exec 'highlight '.a:hi
  redir END
  let hl = substitute(hl, '[\r\n]', '', 'g')
  let hl = substitute(hl, 'xxx', '', '')
  return hl
endfunction

" 行頭にShebangを入力した状態で保存した場合、自動的に実行権限を付与する
let b:executable = 0
function! s:FilePermSetExec()
  if b:executable == 0 && getline(1)[0:1] ==# "#!"
    :!chmod +x %
    let b:executable = 1
  endif
endfunction
augroup FilePermSetExec
  autocmd!
  autocmd BufWritePost * call <SID>FilePermSetExec()
augroup END

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

" キーワードから記号等を削除
set iskeyword-=-_()

" swapfileのエラーがうるさいため、swapfileやbackupfileを作成しないことにする(Manjaro対応)
set noswapfile
if !empty($XDG_CACHE_HOME)
  set backupdir=$XDG_CACHE_HOME/vim
else
  set backupdir=$HOME/.vimbackup
endif
set nobackup

" viminfoのpathを指定する
if !empty($XDG_STATE_HOME)
  set viminfo+=n$XDG_STATE_HOME/vim/viminfo
else
  set viminfo+=$HOME/.viminfo
endif
