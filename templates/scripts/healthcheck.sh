#!/bin/sh


print_help() {
    echo "Usage: $0"
    echo "Usage: $0 --help"
    echo
    
    echo "Variables:"
    echo "  VAR_NAME1: DESC1"
    echo "  VAR_NAME2: DESC2"
    echo "  ...: ..."
}

print_info() {
    echo "$(date +"[%d/%m/%Y %H:%M:%S %z INF]") $1"
}

print_info_short(){
    echo "$1"
}

print_err() {
    echo "$(date +"[%d/%m/%Y %H:%M:%S %z ERR]") $1" >&2
}

print_err_short(){
    echo "$1" >&2
}

run_test(){
    print_info_short "Checking..."
}


if [[ "$#" -eq 0 ]]; then
    run_test
elif [[ "$#" -eq 1 && "$1" == "--help" ]]; then
    print_help
else
    print_err_short "Command not understood. Use --help."
    exit 1
fi
