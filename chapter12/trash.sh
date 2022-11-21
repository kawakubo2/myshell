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
trash_directory_is_exsits()
{
  local trash_base_directory=$1
  local trash_file_directory=${trash_base_directory}/${TRASH_FILE_DIRECTORY_NAME}
  local trash_info_directory=${trash_base_directory}/${TRASH_INFO_DIRECTORY_NAME}

  if [[ ! -d $trash_base_directory ]]; then
    print_error "'$trash_base_directory': Trash directory not found"
    return 1
  fi

  if [[ ! -d $trash_file_directory ]]; then
    print_error "'$trash_file_directory': Trash directory not found"
    return 1
  fi

  if [[ ! -d $trash_info_directory ]]; then
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

# ゴミ箱に入っているファイルを一覧表示する
# 引数
#   $1 : ゴミ箱ディレクトリ
trash_list()
{
  local trash_base_directory=$1
  local trash_info_directory=${trash_base_directory}/${TRASH_INFO_DIRECTORY_NAME}

  trash_directory_is_exsits "$trash_base_directory" || return 1

  local path=
  find -- "$trash_info_directory" -mindepth 1 -maxdepth 1 -type f -name '*.trashinfo' -print \
    | sort \
    | while IFS= read -r path
      do
        print_trashinfo "$path"
      done
}

# ゴミ箱に入っているファイルを元の場所に戻す
# 引数
#   $1 : ゴミ箱ディレクトリ
#   $2 : 復元もとファイル名
#   $3 : ファイル番号(省略可能)
trash_restore()
{
  local trash_base_directory=$1
  local file_name=$2
  local fine_number=$3
  local trash_file_directory=${trash_base_directory}/${TRASH_FILE_DIRECTORY_NAME}
  local trash_info_directory=${trash_base_directory}/${TRASH_INFO_DIRECTORY_NAME}

  trash_directory_is_exsits "$trash_base_directory" || return 1

  if [[ -z $file_name ]]; then
    print_error 'missing file operand'
    return 1
  fi

  # ファイル名が指定されている場合、ファイル名そのもの
  # ファイル番号が指定されている場合、ファイル名_ファイル番号というファイルを探して復元する
  local restore_target_name=
  if [[ -z $file_number ]]; then
    restore_file_name=$file_name
  else
    restore_file_name=${file_name}_${file_number}
  fi

  local restoer_trashinfo_path=${trash_info_directory}/${restore_target_name}.trashinfo
  local restore_from_path=${trash_file_directory}/${restore_target_name}
  if [[ ! -f restore_trashinfo_path || ! -e $restore_from_path ]]; then
    print_error "'$restore_target_name': File not found"
    return 2
  fi

  local restore_trashinfo_path
  restore_to_path=$(grep '^Path=' -- "$restore_trashinfo_path" | sed 's/^Path=//')
  if [[ -z $restore_to_path ]]; then
    print_error "'$restore_trashinfo_path': Restore path not found"
    return 2
  fi

  # trashinfoファイルに書かれている復元もとファイル名と引数で指定されたファイル名が異なる場合はエラーとする
  local restore_to_file=${restore_to_path##*/}
  if [[ $file_name != "${restore_to_file}" ]]; then
    print_error "'$restore_target_name': File not found"
    return 2
  fi

  # 復元もとファイルがすでに存在している場合、上書きせずにエラーとする
  if [[ -e "$restore_to_path" ]]; then
    print_error "can not restore '$restore_to_path': File already exists"
    return 3
  fi

  # 必要であれば復元先ファイルの親ディレクトリを作成する
  local restore_base_path=${restore_to_path%/*}
  if [[ -n $restore_base_path && -d $restore_base_path ]]; then
    mkdir -p -- "$restore_base_path" || return 4
  fi

  mv -- "$restore_from_path" "$restore_to_path" || return 5
  rm -- "$restore_trashinfo_path"
}

sub_command=

case "$1" in
  put | list | restore)
    sub_command=$1
    shift;
    ;;
  --help | help)
    print_help
    exit 0
    ;;
  --version | version)
    print_version
    exit 0
    ;;
  '')
    print_error 'missing command'
    exit 1
    ;;
  *)
    print_error "'$1': Unknown command"
    exit 1
    ;;
esac

parameters=$(getopt -n "$SCRIPT_NAME" \
  -o d: \
  -l directory: \
  -l help -l version \
  -- "$@")

if [[ $? -ne 0 ]]; then
  echo 'Try --help option for more information' 1>&2
  exit 1
fi
eval set -- "$parameters"

# TRASHED_DIRECTORYは呼び出し側で環境変数として指定してもよい
trash_base_directory=${TRASH_DIRECTORY:-$DEFAULT_TRASH_BASE_DIRECTORY}

while [[ $# -gt 0 ]]
do
  case "$1" in
    -d | --directory)
      trash_base_directory=$2
      shift 2
      ;;
    --help)
      print_help
      exit 0
      ;;
    --version)
      print_version
      exit 0
      ;;
    --)
      shift
      break;
      ;;
  esac
done

if [[ -z $trash_base_directory ]]; then
  print_error 'missing directory operand'
  exit 1
fi

result=0

if [[ $sub_command == put ]]; then
  if [[ $# -le 0 ]]; then
    print_error 'missing file operand'
    exit 1
  fi

  for i in "$@"
  do
    trash_put "$trash_base_directory" "$1" || result=$?
  done

elif [[ $sub_command == list ]]; then
  trash_list "$trash_base_directory"
  result=$?

elif [[ $sub_command == restore ]]; then
  if [[ $# -le 0 ]]; then
    print_error 'missing file operand'
    exit 1
  fi

  trash_restore "$trash_base_directory" "$1" "$2"
  result=$?

fi

exit "$result"
