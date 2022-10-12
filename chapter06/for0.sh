#!/bin/bash

for i in {1..9}
do
    if [[ $i -eq 3 ]]; then
        continue
    elif [[ $i -eq 5 ]]; then
        break
    fi
    echo $i
done