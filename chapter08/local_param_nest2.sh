#!/bin/bash

update_prefecture1()
{
    echo "[update_prefecture1] $prefecture"
    local prefecture=Aomori
    echo "[update_prefecture1] $prefecture"
}

update_prefecture2()
{
    local prefecture=Iwate
    echo "[update_prefecture2] $prefecture"
    update_prefecture1
    echo "[update_prefecture2] $prefecture"
}

prefecture=Hokkaido
echo $prefecture
update_prefecture2
echo $prefecture