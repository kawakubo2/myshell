#!/bin/bash

while :
do
  s1=$(date)
  s2=12

  echo $s1
  if [[ "$s1" =~ "$s2" ]]; then
    echo yes
    break
  else
    echo -n #
  fi
  sleep 3
done
