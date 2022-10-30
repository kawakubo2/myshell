#!/bin/bash

if grep bash /etc/shells >/dev/null; then
    echo Found
fi