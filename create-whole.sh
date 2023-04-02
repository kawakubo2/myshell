#!/bin/bash

readonly BASE_DIR="$HOME/myyaml"
readonly DEST_DIR="$HOME/myyaml_dest"
readonly DEFAULT_TARGET="$DEST_DIR/wordpress-mysql.yaml"



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


for file_path in ${yaml_array[@]}; do
  echo --- >> $DEFAULT_TARGET
  while IFS= read line; do
    echo "$line" >> $DEFAULT_TARGET
  done < $file_path
done

cat $DEFAULT_TARGET | sed -i '1d' $DEFAULT_TARGET