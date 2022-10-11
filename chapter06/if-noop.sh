#!/bin/bash

file=$1
if [ -e "$file" ]; then
    echo "Hello, Bash!" >> "$file"
else
    touch "$file"
    echo "Hello, World!" > "$file"
fi