#!/usr/bin/env bash

print_info(){
    printf "\033[0;30;45m---- 系统信息 (%s) ----\033[0m\n" "$(date +"%Y-%m-%d %H:%M:%S")"

}

p(){
    # 打印信息
    printf "\033[0;32m%s:\033[0m%s" "$1" "$2"
}

print_info
