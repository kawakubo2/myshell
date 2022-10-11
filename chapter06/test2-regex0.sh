#!/bin/bash

str1=number17
if [[ $str1 =~ number[0-9]{1,3} ]]; then
    echo YES
else
    echo NO
fi
