#!/bin/bash

x=6
if [[ $x -gt 3 && $x -lt 7 ]]; then
    echo 'x > 3 AND x < 7'
else
    echo 'x <= 3 OR x >= 7'
fi