#!/usr/bin/env bash
# Copyright(c) 2024 Blacknon. All rights reserved.
#
# Description: [lssh](https://github.com/blacknon/lssh)のpshell(parallel shell)で実装されている"%outexec"コマンドで使用するためのスクリプト。 "${LSSH_PSHELL_OUT_{SERVER_NAME}}"に過去の実行結果が保存されているため、それらをvimdiffに食わせて差分を確認する。
# =============================================

# usage
function usage() {
    cat <<_EOT_
Usage:
  $0

Description:
  [lssh](https://github.com/blacknon/lssh)のpshell(parallel shell)で実装されている"%outexec"コマンドで使用するためのスクリプト。
  "\${LSSH_PSHELL_OUT_{SERVER_NAME}}"に過去の実行結果が保存されているため、それらをvimdiffに食わせて差分を確認する。
_EOT_
    exit 0
}

# vimdiffがPATHに存在するかチェック
which vimdiff > /dev/null
if [ $? -ne 0 ]; then
    echo "vimdiffが見つかりませんでした"
    exit 1
fi

# 環境変数が存在するかチェック
pshell_out_env_array=($(env | grep -oE '^LSSH_PSHELL_OUT_[a-f0-9]+_NAME=[^ ]+' | sort -V -t'=' -k2 | awk -F= '{print $1}' | sed 's/_NAME/_VALUE/'))
if [[ ${#pshell_out_env_array[@]} -eq 0 ]]; then
    echo "環境変数がセットされていません"
    exit 1
fi

# # vimdiffの引数を生成
vimdiff_args="$(printf "<(echo \"\${%s}\") " "${pshell_out_env_array[@]}")"
eval vimdiff "${vimdiff_args}"
