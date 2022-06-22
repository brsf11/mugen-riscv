#!/usr/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.
####################################
#@Author    	:   zhangjujie2
#@Contact   	:   zhangjujie43@gmail.com
#@Date      	:   2022/08/04
#@License   	:   Mulan PSL v2
#@Desc      	:   Take the test for nmon
#####################################

source "./common/common.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL "nmon gcc ncurses-devel nfs-utils rpmdevtools rpmlint openeuler-lsb"
    env_pre
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start to run test."
    expect<<EOF
    spawn nmon -b
    send "q"
    expect eof
EOF
    CHECK_RESULT $? 0 0 "Failed option: -b"
    expect <<EOF
    spawn nmon -c5
    send "q"
    expect eof
EOF
    CHECK_RESULT $? 0 0 "Failed option: -c"
    expect <<EOF
    spawn nmon -s3
    expect "3secs" {
        exec touch ./template/interactive_-s
}
    send "q"
    expect eof
EOF
    test -f ./template/interactive_-s
    CHECK_RESULT $? 0 0 "Failed option: -s"
    expect <<EOF
    spawn ./nmon_openEuler
    send "a\r"
    expect "NVIDIA GPU Accelerator" {
        exec touch ./template/interactive_a
    }
    send "q"
    expect eof
EOF
    test -f ./template/interactive_a
    CHECK_RESULT $? 0 0 "Failed option: a"
    expect <<EOF
    spawn nmon
    send "b\r"
    send "q"
    expect eof
EOF
    CHECK_RESULT $? 0 0 "Failed option: -b"
    expect <<EOF
    spawn nmon
    send "c\r"
    expect "CPU Utilisation" {
        exec touch ./template/interactive_c
}
    send "q"
    expect eof
EOF
    test -f ./template/interactive_c
    CHECK_RESULT $? 0 0 "Failed option: c"
    expect <<EOF
    spawn nmon
    send "C\r"
    expect "CPU Utilisation Wide View" {
        exec touch ./template/interactive_C
}
    send "q"
    expect eof
EOF
    test -f ./template/interactive_C
    CHECK_RESULT $? 0 0 "Failed option: C"
    expect <<EOF
    spawn nmon
    send "d\r"
    expect "Disk I/O" {
        exec touch ./template/interactive_d
}
    send "q"
    expect eof
EOF
    test -f ./template/interactive_d
    CHECK_RESULT $? 0 0 "Failed option: d"
    expect <<EOF
    spawn nmon
    send "D\r"
    expect "Disk I/O" {
        exec touch ./template/interactive_D_1
    }
    expect "Xfers" {
        exec touch ./template/interactive_D_2
    }
    expect "Size" {
        exec touch ./template/interactive_D_3
    }
    expect "Peak%" {
        exec touch ./template/interactive_D_4
    }
    expect "Peak=R+W" {
        exec touch ./template/interactive_D_5
    }
    expect "InFlight" {
        exec touch ./template/interactive_D_6
    }
    send "q"
    expect eof
EOF
    test -f ./template/interactive_D_1 && test -f ./template/interactive_D_2 && \
    test -f ./template/interactive_D_3 && test -f ./template/interactive_D_4 && \
    test -f ./template/interactive_D_5 && test -f ./template/interactive_D_6
    CHECK_RESULT $? 0 0 "Failed option: D"
    echo "userDefinedDiskGroups $(lsblk -l | grep disk | awk '{print $1}')" >./template/uddg
    expect <<EOF
    spawn nmon -g ./template/uddg
    send "g\r"
    expect "Disk Group I/O" {
        exec touch ./template/interactive_g_1
    }
    expect "userDefinedDiskGroups" {
        exec touch ./template/interactive_g_2
    }
    send "q"
    expect eof
EOF
    test -f ./template/interactive_g_1 && test -f ./template/interactive_g_2
    CHECK_RESULT $? 0 0 "Failed option: g"
    disk=$(lsblk -l | grep 'disk' | awk '{print $1}' | sed ':t;N;s/\n/\|/;b t')
    notdisk=$(iostat -d | grep -vE "$disk" | grep -vE 'Linux|Device|^$' | awk '{print $1}' | sed ':t;N;s/\n/\|/;b t')
    expect <<EOF
    spawn nmon -g auto
    send "dG\r"
    expect -re "$disk" {
        exec touch ./template/interactive_G_1
    }
    if {"$notdisk"==""} {
        exit
    }
    expect -re "$notdisk" {
        exec touch ./template/interactive_G_2
    }
    send "q"
    expect eof
EOF
    test -f ./template/interactive_G_1
    CHECK_RESULT $? 0 0 "Failed option: G"
    test -f ./template/interactive_G_2
    CHECK_RESULT $? 0 1 "Failed option: G"
    expect <<EOF
    spawn nmon
    send "h\r"
    expect "HELP" {
        exec touch ./template/interactive_h
    }
    send "q"
    expect eof
EOF
    test -f ./template/interactive_h
    CHECK_RESULT $? 0 0 "Failed option: h"
    expect <<EOF
    spawn nmon
    send "j\r"
    expect "File Systems" {
        exec touch ./template/interactive_j_1
    }
    expect "not a real filesystem" {
        exec touch ./template/interactive_j_2
    }
    send "q"
    expect eof
EOF
    test -f ./template/interactive_j_1 && test -f ./template/interactive_j_2
    CHECK_RESULT $? 0 0 "Failed option: j"
    expect <<EOF
    spawn nmon
    send "jJ\r"
    expect "File Systems" {
        exec touch ./template/interactive_J_1
    }
    expect "not a real filesystem" {
        exec touch ./template/interactive_J_2
    }
    send "q"
    expect eof
EOF
    test -f ./template/interactive_J_1
    CHECK_RESULT $? 0 0 "Failed option: J"
    test -f ./template/interactive_J_2
    CHECK_RESULT $? 0 1 "Failed option: J"
    expect <<EOF
    spawn nmon
    send "k\r"
    expect "Kernel and Load Average" {
        exec touch ./template/interactive_k_1
    }
    expect "RunQueue" {
        exec touch ./template/interactive_k_2
    }
    expect "Context" {
        exec touch ./template/interactive_k_3
    }
    expect "Switch" {
        exec touch ./template/interactive_k_4
    }
    expect "Forks" {
        exec touch ./template/interactive_k_5
    }
    send "q"
    expect eof
EOF
    test -f ./template/interactive_k_1 && test -f ./template/interactive_k_2 && \
    test -f ./template/interactive_k_3 && test -f ./template/interactive_k_4 && \
    test -f ./template/interactive_k_5
    CHECK_RESULT $? 0 0 "Failed option: k"
    expect <<EOF
    spawn nmon
    send "l\r"
    expect "CPU" {
        exec touch ./template/interactive_l_1
    }
    expect "Long-Term" {
        exec touch ./template/interactive_l_2
    }
    send "q"
    expect eof
EOF
    test -f ./template/interactive_l_1 && test -f ./template/interactive_l_2
    CHECK_RESULT $? 0 0 "Failed option: l"
    expect <<EOF
    spawn nmon
    send "L\r"
    expect "Large (Huge) Page" {
        exec touch ./template/interactive_L
    }
    send "q"
    expect eof
EOF
    test -f ./template/interactive_L
    CHECK_RESULT $? 0 0 "Failed option: L"
    expect <<EOF
    spawn nmon
    send "m\r"
    expect "Memory and Swap" {
        exec touch ./template/interactive_m
    }
    send "q"
    expect eof
EOF
    test -f ./template/interactive_m
    CHECK_RESULT $? 0 0 "Failed option: m"
    expect <<EOF
    spawn nmon
    send "M\r"
    expect "CPU MHz per Core and Thread" {
        exec touch ./template/interactive_M
    }
    send "q"
    expect eof
EOF
    test -f ./template/interactive_M
    CHECK_RESULT $? 0 0 "Failed option: M"
    expect <<EOF
    spawn nmon
    send "n\r"
    expect "Network I/O" {
        exec touch ./template/interactive_n_1
    }
    expect "Network Error Counters" {
        exec touch ./template/interactive_n_2
    }
    send "q"
    expect eof
EOF
    test -f ./template/interactive_n_1 && test -f ./template/interactive_n_2
    CHECK_RESULT $? 0 0 "Failed option: n"
    expect <<EOF
    spawn nmon
    send "N\r"
    expect "Network Filesystem (NFS) I/O Operations per second" {
        exec touch ./template/interactive_N
    }
    send "q"
    expect eof
EOF
    test -f ./template/interactive_N
    CHECK_RESULT $? 0 0 "Failed option: N"
    expect <<EOF
    spawn nmon
    send "o\r"
    expect "Disk %Busy Map" {
        exec touch ./template/interactive_o
    }
    send "q"
    expect eof
EOF
    test -f ./template/interactive_o
    CHECK_RESULT $? 0 0 "Failed option: o"
    expect <<EOF
    spawn nmon
    send "q\r"
    [exec sh -c {if ["$(ps -e | grep nmon)" = ""]; then
    touch ./template/interactive_q
    fi}]
    expect eof
EOF
    test -f ./template/interactive_q
    CHECK_RESULT $? 0 0 "Failed option: q"
    expect <<EOF
    spawn nmon
    send "r\r"
    expect "Release  : $(uname -r)" {
        exec touch ./template/interactive_r_1
    }
    expect "Version  : $(uname -v)" {
        exec touch ./template/interactive_r_2
    }
    expect "Machine  : $(uname -m)" {
        exec touch ./template/interactive_r_3
    }
    expect "Nodename : $(uname -n)" {
        exec touch ./template/interactive_r_4
    }
    set ease1 [exec sh -c {cat /etc/*ease | awk 'NR==1'}]
    expect "$ease1" {
        exec touch ./template/interactive_r_5
    }
    set ease2 [exec sh -c {cat /etc/*ease | awk 'NR==2'}]
    expect "$ease2" {
        exec touch ./template/interactive_r_6
    }
    set ease3 [exec sh -c {cat /etc/*ease | awk 'NR==3'}]
    expect "$ease3" {
        exec touch ./template/interactive_r_7
    }
    set ease4 [exec sh -c {cat /etc/*ease | awk 'NR==4'}]
    expect "$ease4" {
        exec touch ./template/interactive_r_8
    }
    set lsb_1 [exec sh -c {lsb_release -i}]
    expect "$lsb_1" {
        exec touch ./template/interactive_r_9
    }
    set lsb_2 [exec sh -c {lsb_release -d}]
    expect "$lsb_2" {
        exec touch ./template/interactive_r_10
    }
    set lsb_3 [exec sh -c {lsb_release -r}]
    expect "$lsb_3" {
        exec touch ./template/interactive_r_11
    }
    set lsb_4 [exec sh -c {lsb_release -c}]
    expect "$lsb_4" {
        exec touch ./template/interactive_r_12
    }
    send "q"
    expect eof
EOF
    test -f ./template/interactive_r_1 && test -f ./template/interactive_r_2 && \
    test -f ./template/interactive_r_3 && test -f ./template/interactive_r_4 && \
    test -f ./template/interactive_r_5 && test -f ./template/interactive_r_6 && \
    test -f ./template/interactive_r_7 && test -f ./template/interactive_r_8 && \
    test -f ./template/interactive_r_9 && test -f ./template/interactive_r_10 && \
    test -f ./template/interactive_r_11 && test -f ./template/interactive_r_12
    CHECK_RESULT $? 0 0 "Failed option: r"
    expect <<EOF
    spawn nmon
    send "t\r"
    expect "Top Processes" {
        exec touch ./template/interactive_t
    }
    send "q"
    expect eof
EOF
    test -f ./template/interactive_t
    CHECK_RESULT $? 0 0 "Failed option: t"
    expect <<EOF
    spawn nmon
    send "T\r"
    expect "Top Processes" {
        exec touch ./template/interactive_T_1
    }
    expect "Pgrp" {
        exec touch ./template/interactive_T_2
    }
    expect "Nice" {
        exec touch ./template/interactive_T_3
    }
    expect "Prior" {
        exec touch ./template/interactive_T_4
    }
    expect "Status" {
        exec touch ./template/interactive_T_5
    }
    expect "Proc-Flag" {
        exec touch ./template/interactive_T_6
    }
    send "q"
    expect eof
EOF
    test -f ./template/interactive_T_1 && test -f ./template/interactive_T_2 && \
    test -f ./template/interactive_T_3 && test -f ./template/interactive_T_4 && \
    test -f ./template/interactive_T_5 && test -f ./template/interactive_T_6
    CHECK_RESULT $? 0 0 "Failed option: T"
    expect <<EOF
    spawn nmon
    send "u\r"
    expect "Top Processes" {
        exec touch ./template/interactive_u_1
    }
    expect "ResSize" {
        exec touch ./template/interactive_u_2
    }
    send "q"
    expect eof
EOF
    test -f ./template/interactive_u_1 && test -f ./template/interactive_u_2
    CHECK_RESULT $? 0 0 "Failed option: u"
    expect <<EOF
    spawn nmon
    send "U\r"
    expect "CPU Utilisation Stats" {
        exec touch ./template/interactive_U
    }
    send "q"
    expect eof
EOF
    test -f ./template/interactive_U
    CHECK_RESULT $? 0 0 "Failed option: U"
    expect <<EOF
    spawn nmon
    send "v\r"
    expect "Verbose Mode" {
        exec touch ./template/interactive_v
    }
    send "q"
    expect eof
EOF
    test -f ./template/interactive_v
    CHECK_RESULT $? 0 0 "Failed option: v"
    expect <<EOF
    spawn nmon
    send "V\r"
    expect "Virtual Memory" {
        exec touch ./template/interactive_V
    }
    send "q"
    expect eof
EOF
    test -f ./template/interactive_V
    CHECK_RESULT $? 0 0 "Failed option: V"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start restore the test environment."
    env_post
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}

main "$@"

