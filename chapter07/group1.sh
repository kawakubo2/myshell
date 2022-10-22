#!/bin/bash

date +%Y-%m-%d > result.txt
echo '/usr list' >> result.txt
ls /usr >> result.txt
