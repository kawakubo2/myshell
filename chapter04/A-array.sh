#!/bin/bash

declare -A user=([id]=5 [name]=miyake)

user[name]=MiyakeHideki
user[country]=japan

echo ${user[id]}
echo ${user[name]}
echo ${user[country]}