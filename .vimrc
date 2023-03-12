" Copyright(c) 2023 Blacknon. All rights reserved.
" Use of this source code is governed by an MIT license
" that can be found in the LICENSE file.
" -------------------------------------------------------------
" .vimrcが配置されているディレクトリを変数に格納する
let s:local_vimrc = resolve(expand('<sfile>'))
let s:local_vimrc_dir = fnamemodify(s:local_vimrc, ':p:h')

" いらないのでlocal_vimrcの変数は削除
unlet s:local_vimrc

"  読み込むvimrcファイル群を指定
let s:local_vimrc_files = [
  \   s:local_vimrc_dir . '/vimrc/functions.vim'
  \ , s:local_vimrc_dir . '/vimrc/settings.vim'
  \ , s:local_vimrc_dir . '/vimrc/syntax.vim'
  \ , s:local_vimrc_dir . '/vimrc/remaps.vim'
\]

" for loopで読み込んでいく
for s:local_vimrc_file in s:local_vimrc_files
    exe 'source' s:local_vimrc_file
endfor
