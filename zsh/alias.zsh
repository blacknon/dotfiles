#!/usr/bin/env zsh
# Copyright(c) 2021 Blacknon. All rights reserved.
# Use of this source code is governed by an MIT license
# that can be found in the LICENSE file.

# reload
alias reload='exec zsh -l'

# hwatchのalias(shellを利用する方式へ)
# hwatch
which hwatch 2>/dev/null >/dev/null
[ $? -eq 0 ] && alias hwatch='hwatch -s '\''zsh -c "source ~/.zshrc; {COMMAND}"'\''  -l $HOME/Today/log/hwatch/hwatch_$(date +%Y%m%d_%H%M%S)_hwatch.log '
