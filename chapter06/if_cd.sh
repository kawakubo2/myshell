#!/bin/bash

if cd "$1"; then
    echo success
else
    echo fail
fi