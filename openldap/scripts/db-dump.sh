#!/bin/sh

none_value="__11NONE22__"
auto_action_value="_77AUTO88_"
default_openldap_conf="/etc/openldap"
default_openldap_pidpath="/run/openldap/openldap.pid"


print_help() {
    echo "Usage: $0 --help"
    echo "Usage: $0 [-c] [-h] [-t] [-w [<wipeDir>]] [-W <wipeIfFile>] -d [<configDir>]"
    echo "  <dbNumber> <pathDest> <outputFileName>"
    echo
    echo "Options:"
    echo "  <dbNumber>: database number."
    echo "  <pathDest>: backup destination folder."
    echo "  <outputFileName>: output file name (output: <outputFileName>.ldif)."
    echo "  -c: you will be asked to confirm the operation."
    echo "  -d [<configDir>]: OpenLDAP configuration directory (default: \"$default_openldap_conf\")."
    echo "  -h: creates checksum (sha256) of file (output: <outputFileName>.ldif.checksum)."
    echo "  -t: a time label will be added to the output name."
    echo "  -w [<wipeDir>]: after dumping, the contents of <wipeDir> will be deleted."
    echo "      If <wipeDir> empty then olcDbDirectory will be used."
    echo "  -W <wipeIfFile>: used in conjunction with \"-w\","
    echo "      cleanup will only be performed if <wipeIfFile> does not exist."
    echo "      default: \"$default_openldap_pidpath\""
}

print_info_short(){
    echo "$1"
}

print_err_short(){
    echo "$1" >&2
}

get_shell_options(){
    local i=1
    local s_args="$1"
    local end_loop="$2"
    
    set -- $s_args
    
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
    
    while getopts ":c:d:h:t:w:W:" opt_read $1; do
        opt="$opt_read"
        opt_arg="$OPTARG"
        
        case "$opt" in
            "c")
                is_confirmable="yes"
            ;;
            "d")
                config_dir=$([[ "$opt_arg" != "$none_value" ]] && echo "$opt_arg" || echo "$default_openldap_conf")
            ;;
            "h")
                has_hash="yes"
            ;;
            "t")
                is_timed="yes"
            ;;
            "w")
                wipe_dir=$([[ "$opt_arg" != "$none_value" ]] && echo "$opt_arg" || echo "$auto_action_value")
            ;;
            "W")
                wipe_if_not_exist=$([[ "$opt_arg" != "$none_value" ]] && echo "$opt_arg" || echo "$default_openldap_pidpath")
            ;;
            *)
                print_err_short "\"-$opt_arg\" option not found."
                exit 1
            ;;
        esac
    done
}

check_dir_is_readable(){
    is_readable=$([[ -d "$1" && -r "$1" ]] && echo "yes" || echo "")
}

check_dir_is_readable_exit(){
    check_dir_is_readable "$1"
    
    if [[ -z "$is_readable" ]]; then
        print_err_short "\"$1\" is not a directory or cannot be read."; exit 1
    fi
}

check_dir_is_writeable(){
    is_writeable=$([[ -d "$1" && -w "$1" ]] && echo "yes" || echo "")
}

check_dir_is_writeable_exit(){
    check_dir_is_writeable "$1"
    
    if [[ -z "$is_writeable" ]]; then
        print_err_short "\"$1\" is not a directory or cannot be written to."; exit 1
    fi
}

find_dir_wipe_exit(){
    local dbs_found=$(echo "$(ls $config_dir/cn=config/olcDatabase={$1}*.ldif 2> /dev/null)")
    local qt_dbs=$(echo "$dbs_found" | wc -w)
    
    if [[ "$qt_dbs" == "0" ]]; then
        print_err_short "Discovery failed [wipe]: database not found."
        exit 1
    fi
    
    if [[ "$qt_dbs" -gt "1" ]]; then
        print_err_short "Discovery failed [wipe]: more than one database ($qt_dbs) was found."
        exit 1
    fi
    
    wipe_dir=$(cat "$dbs_found" | grep -E "^olcDbDirectory:" | sed -E "s/[ ]+//" | cut -f2 -d ':')
}


shell_args="$@"
shell_end_loop=$(($# - 3))
shell_cmd_options=

db_number=
path_dest=
output_name=

config_dir="$default_openldap_conf"
wipe_dir=
wipe_if_not_exist=
is_timed=
is_confirmable=
has_hash=

if [[ "$#" -eq 1 && "$1" == "--help" ]]; then
    print_help
    exit 0
elif [[ "$#" -ge 3 ]]; then
    db_number=$(eval echo "\${$(($# - 2))}")
    path_dest=$(eval echo "\${$(($# - 1))}")
    output_name=$(eval echo "\${$#}")
    
    get_shell_options "$shell_args" "$shell_end_loop"
    get_options_app "$shell_cmd_options"
else
    print_err_short "Command not understood. Use --help."
    exit 1
fi


check_dir_is_readable_exit "$config_dir"
check_dir_is_writeable_exit "$path_dest"
[[ "$wipe_dir" == "$auto_action_value" ]] && find_dir_wipe_exit "$db_number"

output_name=$([[ -n "$is_timed" ]] && echo "$output_name.ldif-$(date +%Y%m%d_%H%M)" || echo "$output_name.ldif")
output_file="$path_dest$output_name"


if [[ -n "$is_confirmable" ]]; then
    print_info_short "[Data]"
    print_info_short "  - Conf: $config_dir"
    print_info_short "  - DBNumber: $db_number"
    print_info_short "  - Output: $output_file"
    print_info_short "  - Hash (sha256): $has_hash"
    print_info_short "  - Wipe (if not exist): $wipe_dir ($wipe_if_not_exist)"
    print_info_short
    
    read -p "Continue? (y/n): " confirm
    
    if [[ "$confirm" != "[yY]" ]]; then
        print_info_short "Canceled..."
        exit 0
    fi
fi

# RUN DUMP
slapcat -F "$config_dir" -n "$db_number" -l "$output_file"

if [[ "$?" == "0" ]]; then
    print_info_short "[Report]"
    print_info_short "  - DUMP: OK"

    if [[ -n "$has_hash" ]];then
        sha256sum "$output_file" | cut -d " " -f1 > "$output_file.checksum" && print_info_short "  - Hash (sha256) - OK" || print_err_short "  - Hash (sha256) - FAIL"
    fi
    
    if [[ -n "$wipe_dir" ]]; then
        check_dir_is_writeable "$wipe_dir"
        
        if [[ -z "$is_writeable" ]]; then
            print_info_short "  - WIPE: FAIL [NO WRITING PERMISSION]"
        else
            if [[ -n "$wipe_if_not_exist" &&  -f "$wipe_if_not_exist" ]]; then
                print_info_short "  - WIPE: FAIL [<wipeIfFile> EXIST]"
            else
                rm -rf $wipe_dir/* &> /dev/null && print_info_short "  - WIPE: OK" || print_info_short "  - WIPE: FAIL"
            fi
        fi
    else
        print_info_short "  - WIPE: [NOT EXECUTED]"
    fi
else
    print_err_short "[Report]"
    print_err_short "  - DUMP: FAIL"
    print_err_short "  - WIPE: [NOT EXECUTED]"
    
    exit 1
fi

exit 0