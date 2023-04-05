#!/bin/bash

readonly BASE_DIR="$HOME/myyaml"
readonly DEST_DIR="$HOME/myyaml_dest"
readonly DEFAULT_TARGET="$DEST_DIR/wordpress-mysql.yaml"

reverse_flag=1

yaml_array=()

if [ ! -d $BASE_DIR ]; then
  mkdir $BASE_DIR
fi

if [ ! -d $DEST_DIR ]; then
  mkdir $DEST_DIR
fi

if [ -z DEFAULT_TARGET ]; then
  touch "$DEFAULT_TARGET"
  chmod +x "$DEFAULT_TARGET"
  chown $USER:$USER "$DEFAULT_TARGET"
else
  echo -n "" > $DEFAULT_TARGET
fi

for path in "$BASE_DIR/*"; do
  yaml_array+=("$path")
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
  sorted_array=($(echo ${yaml_array[@]} | sort -r))
else
  echo ascending
  sorted_array=($(echo ${yaml_array[@]} | sort))
fi
#IFS=$orginal_ifs

for file_path in ${sorted_array[@]}; do
  echo $file_path
  echo --- >> $DEFAULT_TARGET
  while IFS= read line; do
    echo "$line" >> $DEFAULT_TARGET
  done < $file_path
done

sed -i '1d' $DEFAULT_TARGET
# cat $DEFAULT_TARGET | sed -i '1d' $DEFAULT_TARGET