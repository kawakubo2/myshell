#!/bin/bash

readonly SCRIPT_NAME="{0##*/}"
readonly BASE_DIR="$HOME/myyaml"
readonly DEST_DIR="$HOME/myyaml_dest"

parameters=$(getopt -n "SCRIPT_NAME" \
  -o rf: \
  -l reverse -l file: \
  -- "$@")

create_file="$DEST_DIR/create-resource.yaml"
delete_file="$DEST_DIR/delete-resource.yaml"
target_file=""

reverse_flag=0
while [[ $# -gt 0 ]]
do
  case "$1" in
    -r | --reverse)
      reverse_flag=1
      shift
      ;;
    -f | --file)
      target_file="$DEST_DIR/$2"
      shift 2
      ;;
    --)
      shift
      break
      ;;
  esac
done

if [ -z $target_file ]; then
  if [ $reverse_flag -eq 1 ]; then
    target_file=$delete_file
  else
    target_file=$create_file
  fi
fi

yaml_array=()

if [ ! -d $BASE_DIR ]; then
  mkdir $BASE_DIR
fi

if [ ! -d $DEST_DIR ]; then
  mkdir $DEST_DIR
fi

if [ ! -e $target_file ]; then
  touch "$target_file"
  chmod +x "$target_file"
  chown $USER:$USER "$target_file"
else
  echo -n > $target_file
fi

for path in $BASE_DIR/*; do
  yaml_array+=("$path")
  echo $yaml_array
done

echo ${#yaml_array[*]}

echo ソート前
for file_p in ${yaml_array[@]}; do
  echo $file_p
done

#$orginal_ifs=$IFS
#IFS=$'\n'
if [ $reverse_flag -eq 1 ]; then
  echo descending
  sorted_array=($(printf "%s\n" ${yaml_array[@]} | sort -r))
else
  echo ascending
  sorted_array=($(printf "%s\n" ${yaml_array[@]} | sort))
fi
#IFS=$orginal_ifs

for file_path in ${sorted_array[@]}; do
  echo $file_path
  echo --- >> $target_file
  while IFS= read line; do
    echo "$line" >> $target_file
  done < $file_path
done

sed -i '1d' $target_file
