#!/bin/bash

declare -i num
num=$1
if [ $num -gt 50 ]; then
    echo "$num is greater than 50."
else
    echo "$num is not greater than 50."
fi