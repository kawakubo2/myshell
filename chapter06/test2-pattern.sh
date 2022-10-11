#!/bin/bash

str1=xyz
pattern='x*'
if [[ $str1 == $pattern ]]; then
    echo YES
else
    echo NO
fi
