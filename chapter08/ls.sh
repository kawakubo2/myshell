#!/bin/bash

lsal()
{
    if [[ -z "$1" ]]; then
        echo 'lasl: missing file operand' 1>&2
        return 1
    fi
    ls -al "$1"
}

file="$1"
lsal "$file"
echo "return status = $?"