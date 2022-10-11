#!/bin/bash

file="$1"
if [ -n "$file" -a ! -e "$file" ]; then
    touch "$file"
fi