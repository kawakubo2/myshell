#!/bin/bash

declare -A capitals
capitals=([Japan]=Tokyo [France]=Paris [Germany]=Berlin [Finland]=Helsinki)

echo "${capitals[@]}"
echo "${!capitals[@]}"