#!/usr/bin/env bash

print_info(){
    printf "\033[0;30;45m---- 系统信息 (%s) ----\033[0m\n" "$(date +"%Y-%m-%d %H:%M:%S")"
    print_host_info
    print_cpu_info
    print_mem_info
    echo
}

print_host_info(){
    echo
    p "主机型号" "$(get_host_model)"
    p "内核名称" "$(uname -s)"
    p "内核版本" "$(uname -r)"
    p "操作系统" "$(uname -o)"
    p "系统架构" "$(uname -m)"
}

get_host_model(){
    grep "^Model" /proc/cpuinfo |cut -d: -f2 |sed 's/^ //g'
}

print_cpu_info(){
    echo
    p "CPU型号" "$(get_cpu_model)"
    p "CPU核心数" "$(get_cpu_count)"
    p "CPU频率" "$(get_cpu_freq)"
}

get_cpu_model(){
    grep "^Hardware" /proc/cpuinfo |cut -d: -f2 |sed 's/^ //g'
}

get_cpu_count(){
    # 输出为 n
    grep "^processor" /proc/cpuinfo |wc -l
}

get_cpu_freq(){
    # 输出为 n.nnn
    awk '{printf("%.3f GHz",$0/1000/1000)}' /sys/devices/system/cpu/cpufreq/policy0/cpuinfo_max_freq
}

print_mem_info(){
    echo
    p "内存余量" "$(get_mem_free)"
}

get_mem_free(){
    # 输出为 n MiB / n MiB (n.n%)
    # 这里的 free 实际上是 available
#    awk '/^MemAvailable:/ {printf("%.0f MiB",$2/1024)}' /proc/meminfo
#    awk '/^MemTotal:/{total=$2} /^MemAvailable:/{free=$2} END{printf("%.0f MiB (%.1f%%)",free/1024,free/total*100)}' /proc/meminfo
    awk '/^MemTotal:/{total=$2} /^MemAvailable:/{free=$2} END{printf("%.0f MiB / %.0f MiB (%.1f%%)",free/1024,total/1024,free/total*100)}' /proc/meminfo
}

p(){
    # 第二个参数不为空时打印信息
    [[ "$2" ]]&&printf "\033[0;32m%s:\033[0m %s\n" "$1" "$2"
}

print_info 2>./err.log
