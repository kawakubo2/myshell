#!/bin/bash

readonly SCRIPT_NAME="${0##*/}"

result=0

for number in "$@"
do
    if [[ ! $number =~ ^-?[0-9]+$ ]]; then
        printf '%s\n' "${SCRIPT_NAME}: '$number': non-integer number" 1>&2
        exit
    fi
    ((result+=number))
done

printf '%s\n' "$result"