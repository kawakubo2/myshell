#!/bin/bash

str1=abc
str2=xyz

if [ "$str1" '<' "$str2" ]; then
    echo 'str1 < str2'
else
    echo 'str1 >= str2'
fi