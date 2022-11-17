#!/bin/bash

# 名前
#   trash.sh - コマンドラインでゴミ箱を扱う
#
# 書式
#   trash.sh put [OPTION]... FILE...
#   trash.sh list [OPTION]..
#   trash.sh restore [OPTION]... FILE [NUMBER]
# 説明
#   ゴミ箱を扱うためのシェルスクリプト
#   次の操作ができる
#   - ゴミ箱にファイルを捨てる
#   - ゴミ箱に含まれているファイルを一覧表示する
#   - ゴミ箱からファイルを元の場所に復元する
# 
#   ゴミ箱と使用するディレクトリをTRASH_DIRECTORY環境変数に指定してもよい。
#   指定しない場合は$HOME/.Trashを使用する

readonly SCRIPT_NAME=${0##*/}
readonly VERSION=1.0.0
readonly DEFAULT_TRASH_BASE_DIRECTORY=$HOME/.Trash
readonly TRASH_FILE_DIRECTORY_NAME=files
readonly TRASH_INFO_DIRECTORY_NAME=info

print_help()
{
  CAT << END
Usage: $SCRIPT_NAME put [OPTION]... FILE...           (1st form)
   or: $SCRIPT_NAME list [OPTION]...                  (2nd form)
   or: $SCRIPT_NAME restore [OPTION]... FILE [NUMBER] (3rd form)

In the 1st form, put FILE to the trashcan.
In the 2nd forms, list items in the trashcan.
In the 3rd form, restore FILE from the trashcan.

OPTIONS
  -d, --directory=DIRECTORY  specify transhcan directory
  --help                     display this help and exit
  --version                  display version information and exit

Default trashcan directory is  '$DEFAULT_TRASH_BASE_DIRECTORY'.
You can specify the directory with TRASH_DIRECTORY environment variable
or -d/--directory option.
END
}

print_version()
{
  cat << END
$SCRIPT_NAME version $VERSION
END
}

print_error()
{
  cat << END 1>&2
$SCRIPT_NAME: $1
Try --help option for more information
END
}
