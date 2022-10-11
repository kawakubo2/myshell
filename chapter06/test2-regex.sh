#!/bin/bash

str1=/home/tomoharu
if [[ $str1 =~ ^/home/[^/]+$ ]]; then
    echo YES
else
    echo NO
fi
