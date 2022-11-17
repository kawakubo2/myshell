#!/bin/bash

# 名前
#   trash.sh - コマンドラインでゴミ箱を扱う
#
# 書式
#   trash.sh put [OPTION]... FILE...
#   trash.sh list [OPTION]..
#   trash.sh restore [OPTION]... FILE [NUMBER]
#
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

# 正規表現のメタ文字を\でエスケープした結果を標準出力に出力する。
# 正規表現は基本正規表現とみなす
# 引数
#   $1 : 正規表現文字列
escape_basic_regex()
{
  printf '%s\n' "$1" | sed 's/[.*\^$[]/\\&/g'
}

# ゴミ箱ディレクトリを初期化する
# 引数
#   $1 : ゴミ箱ディレクトリ
trash_init()
{
  local trash_base_directory=$1
  local trash_file_directory=${trash_base_directory}/${TRASH_FILE_DIRECTORY_NAME}
  local trash_info_directory=${trash_base_directory}/${TRASH_INFO_DIRECTORY_NAME}

  if [[ ! -d $trash_base_directory ]]; then
    mkdir -p -- "$trash_base_directory" || return 1
  fi

  if [[ ! -d $trash_file_directory ]]; then
    mkdir -p -- "$trash_file_directory" || return 1
  fi

  if [[ ! -d $trash_info_directory ]]; then
    mkdir -p -- "$trash_info_directory" || return 1
  fi
}

# ゴミ箱ディレクトリが存在するかをチェックする関数
# 存在する場合は0、そうでない場合は1を返す
# 引数
#   $1 : ゴミ箱ディレクトリ
trash_init()
{
  local trash_base_directory=$1
  local trash_file_directory=${trash_base_directory}/${TRASH_FILE_DIRECTORY_NAME}
  local trash_info_directory=${trash_base_directory}/${TRASH_INFO_DIRECTORY_NAME}

  if [[ ! -d $trash_base_directory ]];
    print_error "'$trash_base_directory': Trash directory not found"
    return 1
  fi

  if [[ ! -d $trash_file_directory ]];
    print_error "'$trash_file_directory': Trash directory not found"
    return 1
  fi

  if [[ ! -d $trash_info_directory ]];
    print_error "'$trash_info_directory': Trash directory not found"
    return 1
  fi

  return 0
}

# ゴミ箱にファイルを捨てる関数
# 引数
#   $1 : ゴミ箱ディレクトリ
#   $2 : 対象ファイルパス
trash_put()
{
  local trash_base_directory=$1
  local file_path=$2

  if [[ ! -e $file_path ]]; then
    print_error "'$file_path': File not found"
    return 1
  fi

  # 相対パスであればそれを絶対パスに置き換える
  # ディレクトリであっても末尾に/は付かない
  file_path=$(realpath -- "$file_path")
  local file=${file_path##*/}

  if [[ -z $file ]]; then
    print_error "'$file_path': Can not trash file or directory"
    return 1
  fi

  local trash_file_directory=${trash_base_directory}/${TRASH_FILE_DIRECTORY_NAME}
  local trash_info_directory=${trash_base_directory}/${TRASH_INFO_DIRECTORY_NAME}

  # ゴミ箱に移動させた後のファイル名
  local trashed_file_name=$file
  if [[ -e ${trash_file_directory}/${trashed_file_name} ]]; then
    # ゴミ箱ディレクトリの中でファイル名が重複しないようにするために、
    # 同じ名前のファイルがすでにあった場合はファイル名の末尾に1から始まる番号を付ける
    # 例 file1.txt, file1.txt_1, file1.txt_2

    local rescape_file_name
    rescape_file_name=$(escape_basic_regex "$file")
    local current_max_number
    current_max_number=$(
      find -- "$trash_file_directory" -mindepth 1 -maxdepth 1 -printf '%f\n' \
        | grep -e "^${rescape_file_name}\$" -e "^${rescape_file_name}_[0-9][0-9]*\$" \
        | sed "s/^${rescape_file_name}_\\{0,1\\}//" \
        | sed 's/^$/0/' \
        | sort -n -r \
        | head -n 1
    )
    trashed_file_name+="_$((current_max_number + 1))"
  fi

  trash_init "$trash_base_directory" || return 2

  mv -- "$file_path" "${trash_file_directory}/${trashed_file_name}" \
    || return 3

  # DeletionDateはYYYY-MM-DDThh:mm:ss形式で出力する。タイムゾーンはローカル時刻とする。
  # 例 : 2018-09-12T19:11:27
  cat << END > "${trash_info_directory}/${trashed_file_name}.trashinfo"
[Trash Info]
Path=$file_path
DeletionDate=$(date '+%Y-%m-%dT%H:%M:%S')
END

}

# trashinfoファイルに書かれている情報を出力する
# 引数
#   $1 : trashinfoファイルパス
# trashinfoファイルの形式
#   [Trash Info]
#   Path=/home/xxx/tmp/2015-07-16/file1.txt
#   DeletionDate=2018-09-20T21:37:16
# 出力形式
#   2018-09-20T21:37:16 /home/xxx/tmp/2015-07-16/file1.txt
#   2018-09-20T21:37:16 /home/xxx/tmp/2015-07-16/file1.txt 1
print_trashinfo()
{
  local trashinfo_file_path=$1
  local line=
  local -A info

  # 入力ファイルの内容を = で区切って連想配列に代入する
  while IFS= read -r line
  do
    if [[ $line =~ ^([^=]+)=(.*)$ ]]; then
      info["${BASH_REMATCH[1]}"]=${BASH_REMATCH[2]}
    fi
  done < "$trashinfo_file_path"

  local trashinfo_file_name=${trashinfo_file_path##*/}
  local restore_file_name=${info[Path]##*/}
  local rescape_restore_file_name
  rescape_restore_file_name=$(escape_basic_regex "$restore_file_name")

  # 復元もとファイル名の末尾に含まれているファイル番号の部分を出力する
  local file_number
  file_number=$(
    printf '%s' "$trashinfo_file_name" \
      | sed -e 's/\.trashinfo$//' -e "s/\${rescape_restore_file_name_\\{0,1\\}//"
  )

  printf '%s %s %s\n' "${info[DeletionDate]}" "${info[Path]}" "$file_number"
}