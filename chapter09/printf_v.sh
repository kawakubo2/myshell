#!/bin/bash

value=255
printf -v message 'value = 0x%x' "$value"
echo "message = [$message]"