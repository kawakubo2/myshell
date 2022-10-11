#!/bin/bash

file="$1"
if [ -n "$file" ] && [ ! -e "$file" ]; then
    touch "$file"
fi
