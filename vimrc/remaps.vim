" Copyright(c) 2023 Blacknon. All rights reserved.
" Use of this source code is governed by an MIT license
" that can be found in the LICENSE file.

" ABOUT:
"     remap関係の処理を記載するファイル.
" -------------------------------------------------------------
" 基本設定
" ====================
" コメントで始まる行のインデントを保持する
inoremap # X<C-H>#

" ESC連打でハイライト解除
nnoremap <Esc><Esc> :nohlsearch<CR><Esc>

" 折り返し時に表示行単位での移動できるようにする
nnoremap j gj
nnoremap k gk

" 数字のインクリメント・デクリメントのショートカット割当
nnoremap + <C-a>
nnoremap - <C-x>

" Backspace で削除をする(X相当の処理)
noremap <BS> hx

"F3キーで行番号を現在のカーソルから何行目かの表示に切り替える
nnoremap <F3> :<C-u>setlocal relativenumber!<CR>

" カッコの自動補完
inoremap { {}<Left>
inoremap {<Enter> {}<Left><CR><ESC><S-o>
inoremap ( ()<ESC>i
inoremap (<Enter> ()<Left><CR><ESC><S-o>


" <Ctrl> + <Key>
" ====================
" ctrl + z でundo (Insert modeでは非対応)
noremap <C-Z> u

" ctrl + y でredo (Insert modeでは非対応)
noremap <C-Y> <C-R>

" ctrl + s で保存
noremap  <C-S>      :update<CR>
vnoremap <C-S> <C-C>:update<CR>
inoremap <C-S> <C-O>:update<CR>

" ctrl + q でvimを終了
noremap  <silent> <C-Q>      :q<CR>
vnoremap <silent> <C-Q> <C-C>:q<CR>
inoremap <silent> <C-Q> <C-O>:q<CR>

" ctrl + a で行頭へ移動
noremap  <silent> <C-A> 0
vnoremap <silent> <C-A> <C-C>0
inoremap <silent> <C-A> <C-O>0

" ctrl + e で行末へ移動
noremap  <silent> <C-E> $
vnoremap <silent> <C-E> <C-C>$
inoremap <silent> <C-E> <C-O>$

" ctrl + f で検索モード


" <Alt> + <Key>
" ====================
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


" その他キーの組み合わせ
" ====================
" shift + x, alt + x でカーソルから右の単語を削除する
" (カーソル以降の行をザクッと削除はShift + Dで。Insert modeでは非対応
noremap X       dw
noremap <ESC>x  dw
noremap <A-X>   dw


" コマンド
" ====================
" 「w!!」でsudoで保存する
cnoremap w!! w !sudo tee > /dev/null %<CR>


" 自動処理
" ====================
" ペースト時にpasteモードへ自動変更する
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
