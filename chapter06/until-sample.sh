#!/bin/bash

i=0
until [[ $i -gt 10 ]]
do
    echo "$i"
    i=$((i + 3))
done
