" Copyright(c) 2023 Blacknon. All rights reserved.
" Use of this source code is governed by an MIT license
" that can be found in the LICENSE file.

" ABOUT:
"     vimrc内で使用しているfunctionを記載しているファイル.
" -------------------------------------------------------------

" 内部で呼び出すためのfunction
" ====================
"  retab(tabを空白に変換)+行末の空白除去を実施するfunction
function! __retab()
  " cursorを指定
  let l:cursor = getpos(".")

  " 行末の空白を除去
  %s/\s\+$//ge

  " retab
  :retab

  call setpos(".", l:cursor)
  unlet cursor
endfunction


" StatusLineのハイライト切り替えを行うfunction
let b:____slhlcmd = '' " __statusLine() でのみ使用する変数
function! __statusLine(mode)
  let l:hi_insert = 'highlight StatusLine guifg=darkblue guibg=darkgreen gui=none ctermfg=blue ctermbg=green cterm=none'
  if a:mode == 'Enter'
    silent! let b:____slhlcmd = 'highlight ' . __getHighlight('StatusLine')
    silent exec l:hi_insert
  else
    highlight clear StatusLine
    silent exec b:____slhlcmd
  endif
endfunction


" 指定した要素のハイライト表示情報を取得するfunction
function! __getHighlight(hi)
  redir => l:hl
  exec 'highlight '.a:hi
  redir END
  let l:hl = substitute(l:hl, '[\r\n]', '', 'g')
  let l:hl = substitute(l:hl, 'xxx', '', '')
  return l:hl
endfunction


" 前回ファイルを開いた際のカーソル位置に移動するfunction
function! __restoreCursorPosition()
  if line("'\"") > 0 && line("'\"") <= line("$")
    exe "normal g`\""
  endif
endfunction


" 行頭にShebangを入力した状態で保存した場合、自動的に実行権限を付与するためのfunction
let b:____executableflag = 0
function! __setExecPerm()
  if b:____executableflag == 0 && getline(1)[0:1] ==# "#!"
    :!chmod +x %
    let b:____executableflag = 1
  endif
endfunction

function! s:IsNetworkMount(path)
    if has('mac')
      " MacOSの場合、`df -T nonfs -P path`で行数チェックで識別
      let l:cmd = 'df -T nonfs -P ' . a:path . ' | wc -l'
      let l:lines = substitute(system(l:cmd), '\n', '', '')
      if l:lines == '0'
        return 1
      else
        return 0
      endif

    elseif has('unix')
      " Linuxの場合、普通にPATHベースで識別
      let l:cmd = 'df -P ' . a:path . " | awk -F'[ :] 'NR==2{print $1}'"
      let l:line = substitute(system(l:cmd), '\n', '', '')
      if l:line == "127.0.0.1"
        return 1
      else
        return 0
      endif

    else
        " その他のOSの場合は、ネットワークマウントとして扱わない
        return 0
    endif
endfunction

augroup NetworkBackup
    autocmd!
    autocmd BufWritePre * if s:IsNetworkMount(expand('%:p')) | set nobackup nowritebackup noswapfile | endif
augroup END
