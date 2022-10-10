#!/bin/bash

if [ "$1 = yes -a -w result.txt" ]; then
    echo "hello world!" >> result.txt
fi