#!/usr/bin/env bash

print_info(){
    printf "\033[0;30;45m---- 系统信息 (%s) ----\033[0m\n" "$(date +"%Y-%m-%d %H:%M:%S")"
    print_host_info
}

print_host_info(){
    local model
    model="$(get_host_model)"
    if [[ "${model}" ]]
    then
        p "主机型号" "${model}"
    fi
    p "内核名称" "$(uname -s)"
    p "内核版本" "$(uname -r)"
    p "操作系统" "$(uname -o)"
    p "系统架构" "$(uname -m)"
}

get_host_model(){
    grep "^Model" /proc/cpuinfo |cut -d: -f2 |sed 's/^ //g'
}

p(){
    # 打印信息
    printf "\033[0;32m%s:\033[0m %s\n" "$1" "$2"
}

print_info
