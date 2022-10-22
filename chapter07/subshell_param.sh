#!/bin/bash

name=miyake
echo "$name"

(
    echo '  sub shell'
    echo "  $name"
    name=okita
    echo "  $name"
)

echo "$name"