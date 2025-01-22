#!/bin/sh

: ${PHP_CONF_DIR:="/etc/php"}
: ${PHP_FPM_CONF_DIR:="/etc/php-fpm"}
: ${GLPI_DIR:="/var/www/html"}
: ${GLPI_CONF_DIR:="/etc/glpi"}
: ${GLPI_DATA_DIR:="/var/lib/glpi"}


default_php_conf="/usr/local/etc/php"
default_php_fpm_conf="/usr/local/etc/php-fpm"
default_glpi_conf="/usr/local/etc/glpi"
glpi_srcbin="/usr/share/glpi"


service_name="GLPI"
none_value="__NONE__"


print_help() {
    echo "Usage: $0 {Commands | --help}"
    echo
    
    echo "Commands:"
    echo "  start [-p [<waitTime>]]"
    echo "      Start the application."
    echo "  inspectormode"
    echo "      Runs inspector mode keeping the container running"
    echo "      without loading the application."
    echo "  resume"
    echo "      Print some information."
    echo "  copy <pathDest>"
    echo "      Copy default settings to a specified directory."
    echo
    
    echo "Options:"
    echo "  -p [<waitTime>]: activates persistent mode."
    echo "      In this mode, if the process ends gracefully,"
    echo "      it will start again, respecting a pause of <waitTime> seconds."
    echo "      Default: waitTime=0."
    echo "  <pathDest>: destination folder."
    echo
    
    echo "Variables:"
    echo "  PHP_CONF_DIR: PHP configuration directory (default: /etc/php)."
    echo "  PHP_FPM_CONF_DIR: PHP-FPM configuration directory (default: /etc/php-fpm)."
    echo "  GLPI_DIR: GLPI application directory (default: /var/www/html)."
    echo "  GLPI_CONF_DIR: GLPI configuration directory (default: /etc/glpi)."
    echo "  GLPI_DATA_DIR: GLPI data directory (default: /var/lib/glpi)."
}

print_info() {
    echo "$(date +"[%d/%m/%Y %H:%M:%S %z INF]") $1"
}

print_info_short() {
    echo "$1"
}

print_err() {
    echo "$(date +"[%d/%m/%Y %H:%M:%S %z ERR]") $1" >&2
}

print_err_short() {
    echo "$1" >&2
}

print_resume(){
    echo "[Default Dirs]"
    echo "  - PHP: $default_php_conf"
    echo "  - PHP-FPM: $default_php_fpm_conf"
    echo "  - GLPI (APP): $glpi_srcbin"
    echo "  - GLPI (CONF): $default_glpi_conf"
    echo
    echo "[Recommended Dirs]"
    echo "  - /etc/php"
    echo "  - /etc/php-fpm"
    echo "  - /etc/glpi"
    echo "  - /run/php"
    echo "  - /var/www/html"
    echo "  - /var/lib/glpi"
    echo "  - /var/log/php"
    echo "  - /var/log/glpi"
}

get_shell_options(){
    local i=1
    local s_args="$1"
    local end_loop="$2"
    
    set -- $s_args
    shift
    
    while [[ "$i" -le "$end_loop" ]]; do
        if [[ "$((i + 1))" -gt "$end_loop" || "$2" == "-?" ]]; then
            shell_cmd_options="$shell_cmd_options $1 $none_value"
            i="$(($i + 1))"
            shift
        else
            shell_cmd_options="$shell_cmd_options $1 $2"
            i="$(($i + 2))"
            shift
            shift
        fi
    done
}

get_options_app(){
    local opt=
    local opt_arg=
    
    while getopts ":p:" opt_read $1; do
        opt="$opt_read"
        opt_arg="$OPTARG"
        
        case "$opt" in
            "p")
                app_persistent_mode="yes"
                app_persistent_mode_wait_time=$([[ "$OPTARG" != "$none_value" ]] && echo "$OPTARG" || echo "0")
            ;;
            *)
                print_err_short "\"$opt_arg\" option not found."
                exit 1
            ;;
        esac
    done
}

check_dir_is_empty(){
    local dir_path="$1"
    
    if [[ ! -d "$dir_path" || ! -r "$dir_path" ]]; then
        print_err "\"$dir_path\" is not a directory or cannot be read."
        exit 1
    fi
    
    dir_is_empty=$([[ -z "$(ls -A "$1")" ]] && echo "yes")
}

cp_file(){
    local source_file="$1"
    local dest_dir="$2"
    
    if [[ ! -d "$dest_dir" || ! -w "$dest_dir" ]]; then
        print_err "\"$dest_dir\" is not a directory or is not writable."
        exit 1
    fi
    
    cp $source_file $dest_dir
    chmod -R 750 $dest_dir
}

cp_dir(){
    local source_dir="$1"
    local dest_dir="$2"
    
    if [[ ! -d "$dest_dir" || ! -w "$dest_dir" ]]; then
        print_err "\"$dest_dir\" is not a directory or is not writable."
        exit 1
    fi
    
    [[ "$3" == "folder" ]] && cp -r $source_dir $dest_dir || cp -r $source_dir/* $dest_dir
    chmod -R 750 $dest_dir
}

init_app_data_dir(){
    local dest_dir="$1"
    
    if [[ ! -d "$dest_dir" || ! -w "$dest_dir" ]]; then
        print_err "\"$dest_dir\" is not a directory or is not writable."
        exit 1
    fi
    
    mkdir -p $dest_dir/_cache
    mkdir -p $dest_dir/_cron
    mkdir -p $dest_dir/_docs
    mkdir -p $dest_dir/_dumps
    mkdir -p $dest_dir/_graphs
    mkdir -p $dest_dir/_lock
    mkdir -p $dest_dir/_pictures
    mkdir -p $dest_dir/_plugins
    mkdir -p $dest_dir/_rss
    mkdir -p $dest_dir/_sessions
    mkdir -p $dest_dir/_tmp
    mkdir -p $dest_dir/_uploads
    
    chmod -R 750 $dest_dir
}

init_dirs_if_empty(){
    check_dir_is_empty "$PHP_CONF_DIR"
    [[ -z "$dir_is_empty" ]] \
    && print_info "PHP_CONF_DIR: \"$PHP_CONF_DIR\" [OK]." \
    || (print_info "PHP_CONF_DIR: \"$PHP_CONF_DIR\" empty, creating..."; \
    cp_dir "$default_php_conf" "$PHP_CONF_DIR")
    
    check_dir_is_empty "$PHP_FPM_CONF_DIR"
    [[ -z "$dir_is_empty" ]] \
    && print_info "PHP_FPM_CONF_DIR: \"$PHP_FPM_CONF_DIR\" [OK]." \
    || (print_info "PHP_FPM_CONF_DIR: \"$PHP_FPM_CONF_DIR\" empty, creating..."; \
    cp_dir "$default_php_fpm_conf" "$PHP_FPM_CONF_DIR")
    
    check_dir_is_empty "$GLPI_DIR"
    [[ -z "$dir_is_empty" ]] \
    && print_info "GLPI_DIR: \"$GLPI_DIR\" [OK]." \
    || (print_info "GLPI_DIR: \"$GLPI_DIR\" empty, creating..."; \
        tar -xf $glpi_srcbin/glpi-*.tgz -C $GLPI_DIR --strip-components=1 \
    && cp_file "$glpi_srcbin/downstream.php" "$GLPI_DIR/inc" \
    && chmod -R 750 "$GLPI_DIR")
    
    check_dir_is_empty "$GLPI_CONF_DIR"
    [[ -z "$dir_is_empty" ]] \
    && print_info "GLPI_CONF_DIR: \"$GLPI_CONF_DIR\" [OK]." \
    || (print_info "GLPI_CONF_DIR: \"$GLPI_CONF_DIR\" empty, creating..."; \
    cp_dir "$default_glpi_conf" "$GLPI_CONF_DIR")
    
    check_dir_is_empty "$GLPI_DATA_DIR"
    [[ -z "$dir_is_empty" ]] \
    && print_info "GLPI_DATA_DIR: \"$GLPI_DATA_DIR\" [OK]." \
    || (print_info "GLPI_DATA_DIR: \"$GLPI_DATA_DIR\" empty, creating..."; \
    init_app_data_dir "$GLPI_DATA_DIR")
}

mode_inspector(){
    print_info "INSPECTION MODE."
    
    while true; do
        sleep 120;
    done
}

mode_copy(){
    print_info_short "Copying to \"$1\":"
    
    print_info_short "  - $default_php_conf"
    cp_dir $default_php_conf $1 "folder"
    
    print_info_short "  - $default_php_fpm_conf"
    cp_dir $default_php_fpm_conf $1 "folder"
    
    print_info_short "  - $default_glpi_conf"
    cp_dir $default_glpi_conf $1
    
    print_info_short "  - $glpi_srcbin"
    cp_dir $glpi_srcbin $1
}

mode_app(){
    entrypoint_cmd="php-fpm -F -c $PHP_CONF_DIR -p $PHP_FPM_CONF_DIR -y $PHP_FPM_CONF_DIR/php-fpm.conf"
    
    print_info "Starting $service_name..."
    print_info "Checking directories..."
    
    init_dirs_if_empty
    
    print_info "Command executed: \"$entrypoint_cmd\""
    
    if [[ -z "$app_persistent_mode" ]]; then
        $entrypoint_cmd
    else
        local has_error=
        
        while [[ -z $has_error ]]; do
            $entrypoint_cmd || has_error="yes"
            
            if [[ -z $has_error ]]; then
                print_info "Reloading program..."
                
                if [[ "$app_persistent_mode_wait_time" -gt 0 ]]; then
                    print_info "Waiting $app_persistent_mode_wait_time seconds..."
                    sleep $app_persistent_mode_wait_time
                fi
                
                print_info "Program reloaded..."
            fi
        done
        
        print_err "Program exited with error. Closing..."
        exit 1
    fi
}


shell_cmd_type="$1"
shell_cmd_not_recognized=
shell_args="$@"
shell_end_loop=$(($# - 1))
shell_cmd_options=

app_persistent_mode=
app_persistent_mode_wait_time=0

if [[ "$#" -eq 1 && "$shell_cmd_type" != "start" && "$shell_cmd_type" != "copy" ]]; then
    if [[ "$shell_cmd_type" == "--help" ]]; then
        print_help
    elif [[ "$shell_cmd_type" == "inspectormode" ]]; then
        mode_inspector
    elif [[ "$shell_cmd_type" == "resume" ]]; then
        print_resume
    else
        shell_cmd_not_recognized="yes"
    fi
elif [[ "$shell_cmd_type" == "start" ]]; then
    get_shell_options "$shell_args" "$shell_end_loop"
    get_options_app "$shell_cmd_options"
    mode_app
elif [[ "$#" -eq 2 && "$shell_cmd_type" == "copy" ]]; then
    mode_copy $2
else
    shell_cmd_not_recognized="yes"
fi

if [[ -n "$shell_cmd_not_recognized" ]]; then
    print_err_short "Command not understood. Use --help."
    exit 1
fi
