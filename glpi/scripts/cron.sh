#!/bin/sh

: ${GLPI_DIR:="/var/www/html"}
: ${GLPI_CRON_LOG_OUTPUT:=""}


print_help() {
    echo "Usage: $0"
    echo "Usage: $0 --help"
    echo
    
    echo "Variables:"
    echo "  GLPI_DIR: GLPI application directory (default: /var/www/html)."
    echo "  GLPI_CRON_LOG_OUTPUT: Log output. Values: console, <filePath>, or empty for disabled."
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

run_task(){
    local cmd_run="php $GLPI_DIR/front/cron.php"
    
    if [[ -z "$GLPI_CRON_LOG_OUTPUT" ]];then
        cmd_run="$cmd_run &> /dev/null"
    elif [[ "$GLPI_CRON_LOG_OUTPUT" != "console" ]]; then
        cmd_run="$cmd_run \&>> $GLPI_CRON_LOG_OUTPUT"
    fi
    
    eval $cmd_run
}


if [[ "$#" -eq 0 ]]; then
    run_task
elif [[ "$#" -eq 1 && "$1" == "--help" ]]; then
    print_help
else
    print_err_short "Command not understood. Use --help."
    exit 1
fi