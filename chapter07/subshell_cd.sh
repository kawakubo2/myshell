#!/bin/bash

cd /usr
pwd
(
    echo ''
    echo 'sub shell'
    pwd

    echo 'cd in sub shell'
    cd /tmp
    pwd
    echo ''
)

pwd