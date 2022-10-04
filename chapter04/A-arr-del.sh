#!/bin/bash

declare -A user=([id]=5 [name]=miyake [country]=Japan)

unset user[name]

echo ${user[id]}
echo ${user[name]}
echo ${user[country]}