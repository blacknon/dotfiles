" Copyright(c) 2023 Blacknon. All rights reserved.
" Use of this source code is governed by an MIT license
" that can be found in the LICENSE file.

" ABOUT:
"     ローカルマシンでのみ使用する設定を記載しているファイル.
" -------------------------------------------------------------

" バックアップ関係
" ====================
" vimのbackupファイルの生成先を指定
let b:backupdir=''
if !empty($XDG_CACHE_HOME)
  if expand("$XDG_CACHE_HOME") == expand("$HOME")
    let b:backupdir="$HOME/.vimbackup"
  else
    let b:backupdir="$XDG_CACHE_HOME/vim"
  endif
else
  let b:backupdir="$HOME/.vimbackup"
endif
call mkdir(expand(b:backupdir),"p")
execute "set backupdir=" . b:backupdir
execute "set undodir=" . b:backupdir

" viminfoの設定
" NOTE: [参考](https://github.com/nevans/dotfiles/blob/4df2b9c8bf75dfdd6dd445b21da32e8ae31a7819/xdg_data_home/vim/init_options.vim#L87-L95)
set viminfo=            " 設定の初期化
set viminfo+='100       " 保存する最大ファイル数
set viminfo+=<250       " 保存する最大行数
set viminfo+=s50        " 最大キロバイト数
set viminfo+=h          " viminfo ファイルをロードするときに「hlsearch」を無効にする
set viminfo+=%          " %: saves and restores the buffer list
set viminfo+=r/tmp      " Removable media; no marks will be stored.
set viminfo+=r/run      " ...can be given several times for multiple paths.
set viminfo+=r/mount

" viminfoのpathを指定する
let b:viminfo=''
if !empty($XDG_STATE_HOME)
  if expand("$XDG_STATE_HOME") == expand("$HOME")
    let b:viminfo="$HOME/.viminfo"
  else
    let b:viminfo="$XDG_STATE_HOME/vim/viminfo"
  endif
else
  let b:viminfo="$HOME/.viminfo"
endif
let b:viminfo_dir = fnamemodify(expand(b:viminfo), ':p:h')
call mkdir(b:viminfo_dir,"p")
execute "set viminfo+=n" . b:viminfo

set noswapfile
set nobackup


" Plugin関係
" ====================
