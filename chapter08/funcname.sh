#!/bin/bash

print_function1()
{
    echo "# print_function1"
    echo "\$0 = $0"
    echo "function name = ${FUNCNAME[0]}"
}

print_function2()
{
    echo "# print_function2"
    echo "\$0 = $0"
    echo "function name = ${FUNCNAME[0]}"
    print_function1
}

print_function2