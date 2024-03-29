#!/bin/bash
# Copyright(c) 2023 Blacknon. All rights reserved.
# Use of this source code is governed by an MIT license
# that can be found in the LICENSE file.

# ABOUT:
#     通常のコマンドから置き換えて利用するfunctionを記述しているファイル。
#     prefixは`__`を、postfixとしてfuncを使用している。
### -------------------------------------------------------------

# TODO(blacknon): ローカル向けにhwatchの各種オプションを付与したfunctionの生成？
#     - `~/Today/log`へ、実行ログの記録をするオプション
#     - functionを利用できるよう、受け付けた引数を`bash -c 'source ~/.bashrc;command...'`として整形して実行する

# sudoでfunctionで定義した内容が使えるようにするためのfunction
__sudofunc() {
  local cmd=${1} # 実行コマンドを取得する

  # 実行コマンドのタイプを取得する
  case $(basename ${SHELL}) in
  zsh*) local type=$(whence -w ${cmd} | cut -d" " -f 2) ;;
  bash*) local type=$(type -t ${cmd}) ;;
  esac

  # 実行するコマンドがaliasだった場合、aliasの第一引数を取得する
  if [ "${type}" = "alias" ]; then
    local org_cmd=$(alias ${cmd} | sed -r "s/^alias .*='//;s/'$//g" | cut -d " " -f 1)

    # ${type}を上書き
    case $(basename ${SHELL}) in
    zsh*) local type=$(whence -w ${org_cmd} | cut -d" " -f 2) ;;
    bash*) local type=$(type -t ${org_cmd}) ;;
    esac
  else
    local org_cmd=${cmd}
  fi

  # typeをチェックし、functionだった場合はsudoで実行する
  # ※ sudoはエイリアスを読まないようにする
  if [ "${type}" = "function" ]; then
    case ${OSTYPE} in
    darwin*)
      local data=$(base64 <(
        echo "$(declare -f ${org_cmd})"
        echo ${org_cmd} ${@:2}
      ))
      \sudo -E ${SHELL} -c "$(echo ${data} | base64 -D)"
      ;;
    linux*)
      local data=$(base64 -w 0 <(
        echo "$(declare -f ${org_cmd})"
        echo ${org_cmd} ${@:2}
      ))
      \sudo -E ${SHELL} -c "$(echo ${data} | base64 -d)"
      ;;
    esac
  else
    \sudo -E "$@"
  fi
}

# mkdirで、単体のディレクトリが指定された場合はそこにそのまま移動させるためのfunction
__mkdirfunc() {
  if [ ${#} -gt 1 ]; then
    \mkdir -p ${*}
  else
    \mkdir -p ${*} && cd $_
  fi
}

# pingでタイムスタンプを頭につけるためのfunction
__pingfunc() {
  \ping ${*} | ts
}
