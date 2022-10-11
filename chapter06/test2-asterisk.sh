#!/bin/bash

str1=xyz
# == または != の右辺はパス名展開ができる
if [[ $str1 == x* ]]; then
    echo YES
else
    echo NO
fi