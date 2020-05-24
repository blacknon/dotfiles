#!/usr/bin/env python3
# -*- encoding: UTF-8 -*-
c = get_config()

from IPython.terminal.prompts import Prompts
from pygments.token import Token

class MyInPrompt(Prompts):
    def in_prompt_tokens(self, cli=None):
        return [(Token.Prompt, '>>> ')]

c.TerminalInteractiveShell.prompts_class = MyInPrompt
c.TerminalInteractiveShell.confirm_exit = False
c.Completer.use_jedi = False
c.InteractiveShell.colors = 'Linux'
c.TerminalInteractiveShell.pdb = True
c.InteractiveShellApp.extensions = [
  'autoreload'
]

c.InteractiveShellApp.exec_lines = [
  '%autoreload 2',
]

