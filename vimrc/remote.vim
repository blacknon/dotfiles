" Copyright(c) 2023 Blacknon. All rights reserved.
" Use of this source code is governed by an MIT license
" that can be found in the LICENSE file.

" ABOUT:
"     リモートマシンでのみ使用する設定を記載しているファイル.
"     `bin/update_lvim`でしか使わないので注意.
" -------------------------------------------------------------

" バックアップ関係
" ====================
set viminfo=
set backupdir=
set noswapfile
set nobackup
set nowritebackup


" 自動補完
" ====================
" 文字入力時に、自動的に補完処理を行わせる
for k in split("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_",'\zs')
    " omni補完だとvim側にfunctionちゃんと入ってないといけないので、一旦コメントアウト
    " exec "imap " . k . " " . k . "<C-X><C-O>"
    exec "imap " . k . " " . k . "<C-P>"
endfor
imap <expr> <TAB> pumvisible() ? "\<Down>" : "\<Tab>"
