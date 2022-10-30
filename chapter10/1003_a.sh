#!/bin/bash

if ( grep -q bash /etc/shells ); then
    echo Found
fi