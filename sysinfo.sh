#!/usr/bin/env bash

print_info(){
    printf "\033[0;30;45m---- 系统信息 (%s) ----\033[0m\n" "$(date +"%Y-%m-%d %H:%M:%S")"
    print_host_info
    print_cpu_info
    print_mem_info
    print_disk_info
    print_process_info
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
    # 输出格式为 n
    grep "^processor" /proc/cpuinfo |wc -l
}

get_cpu_freq(){
    # 输出格式为 n.nnn GHz
    awk '{printf("%.3f GHz",$0/1000/1000)}' /sys/devices/system/cpu/cpufreq/policy0/cpuinfo_max_freq
}

print_mem_info(){
    echo
    p "内存余量" "$(get_mem_free)"
    for swap in $(awk 'NR>1{print $1}' /proc/swaps)
    do
        p "SWAP(${swap})余量" "$(get_swap_free)"
    done
}

get_mem_free(){
    # 输出格式为 n MiB / n MiB (n.n%)
    # 这里的 free 实际上是 available
#    awk '/^MemAvailable:/ {printf("%.0f MiB",$2/1024)}' /proc/meminfo
#    awk '/^MemTotal:/{total=$2} /^MemAvailable:/{free=$2} END{printf("%.0f MiB (%.1f%%)",free/1024,free/total*100)}' /proc/meminfo
    awk '/^MemTotal:/{total=$2} /^MemAvailable:/{free=$2} END{printf("%.3f GiB / %.3f GiB (%.1f%%)",free/1024/1024,total/1024/1024,free/total*100)}' /proc/meminfo
}

get_swap_free(){
    # 输出格式为 n MiB / n MiB (n.n%)
    grep "${swap}" /proc/swaps |awk '{total=$3 ;used=$4 ;free=total-used ;printf("%.3f GiB / %.3f GiB (%.1f%%)",free/1024/1024,total/1024/1024,free/total*100)}'
}

print_disk_info(){
    # 只显示挂载的节点
    echo
    for disk in $(lsblk -n -o MOUNTPOINT |xargs)
    do
        p "磁盘(${disk})余量" "$(get_disk_free)"
    done
}

get_disk_free(){
    # 输出格式为 n MiB / n MiB (n.n%)
    lsblk -b -n -o "MOUNTPOINT,FSSIZE,FSAVAIL" |grep "^${disk} \+" |awk '{total=$2 ;free=$3 ;printf("%.3f GiB / %.3f GiB (%.1f%%)",free/1024/1024/1024,total/1024/1024/1024,free/total*100)}'
}

print_process_info(){
    echo
    p "资源占用前十的进程" " "
    # 输出格式为 n.n% n.n% (用户) 进程命令行
    ps --no-headers -A -o %mem,%cpu,user,comm --sort -%mem |head -n10 |awk '{printf("\033[0;32m%7.1f%% %6.1f%%\033[0m (%-8s) %s\n",$1,$2,$3,$4)}'
    printf "\033[0;32m%s %s\033[0m (%s) %s\n" "内存占用" "CPU占用" "用户    " "进程命令行"
}

p(){
    # 第二个参数不为空时打印信息
    [[ "$2" ]]&&printf "\033[0;32m%s:\033[0m %s\n" "$1" "$2"
}

print_info 2>./err.log
