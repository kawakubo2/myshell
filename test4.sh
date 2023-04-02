#!/bin/bash

println()
{
  for item in "$@"
  do
    echo "$item"
  done

}

println abc 123 優太
