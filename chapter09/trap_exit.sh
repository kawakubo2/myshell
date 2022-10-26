#!/bin/bash

trap 'echo receive INT signal; exit' INT

echo start
sleep 10
echo end