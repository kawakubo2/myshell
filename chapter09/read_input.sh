#!/bin/bash

echo 'delete file?'
read input
if [[ $input == yes ]]; then
    echo 'DELETE'
else
    echo 'CANCEL'
fi