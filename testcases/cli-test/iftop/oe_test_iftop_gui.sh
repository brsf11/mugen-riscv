#!/usr/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more detaitest -f.

# #############################################
# @Author    :   shangyingjie
# @Contact   :   yingjie@isrc.iscas.ac.cn
# @Date      :   2022/1/21
# @License   :   Mulan PSL v2
# @Desc      :   Test iftop GUI
# #############################################

source "../common/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL iftop
    DNF_INSTALL bind-utils
    DNF_INSTALL ipcalc
    ipv4_target_addr=$(host huawei.com | grep 'has address' | awk '{print $4}')
    ipv4_target_network=$(ipcalc -n $ipv4_target_addr/24 | cut -d '=' -f2)
    ipv6_target_addr=$(host huawei.com | grep 'IPv6' | awk '{print $5}')
    ipv6_target_network=$(ipcalc -n $ipv6_target_addr/64 | cut -d '=' -f2)
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    expect <<EOF
        spawn iftop -b
        expect "Listening on" {
            exec touch ./opt_b
        }
        send "q"
        expect eof
EOF
    ls ./opt_b
    CHECK_RESULT  $? 0 0 "Failed to use option: -b"
    rm -f ./opt_b
    ping $ipv4_target_addr -c 100 > /dev/null 2>&1 &
    expect <<EOF
        spawn iftop -n -F $ipv4_target_network/24
        expect "$ipv4_target_addr" {
            exec touch ./opt_F
        }
        send "q"
        expect eof
EOF
    ls ./opt_F
    CHECK_RESULT $? 0 0 "Failed to use option: -F"
    rm -f ./opt_F
    pkill -f 'ping'
    ping -6 $ipv6_target_addr -c 100 > /dev/null 2>&1 &
    expect <<EOF
        spawn iftop -G $ipv6_target_network
        expect "$ipv6_target_addr" {
            exec touch ./opt_G
        }
        send "q"
        expect eof
EOF
    ls ./opt_G
    CHECK_RESULT $? 0 0 "Failed to use option: -G"
    rm -f ./opt_G
    pkill -f 'ping'
    expect <<EOF
        spawn iftop -l
        expect "Listening on" {
            exec touch ./opt_l
        }
        send "q"
        expect eof
EOF
    ls ./opt_l
    CHECK_RESULT $? 0 0 "Failed to use option: -l"
    rm -f ./opt_l
    expect <<EOF
        spawn iftop
        send "?"
        expect "iftop, version 1.0pre4" {
            exec touch ./gui_question_mark
        }
        send "q"
        expect eof
EOF
    ls ./gui_question_mark
    CHECK_RESULT $? 0 0 "Failed to use GUI key: ?"
    rm -f ./gui_question_mark
    expect <<EOF
        spawn iftop -u packets
        expect "Kp" {
            exec touch ./gui_u
        }
        send "q"
        expect eof
EOF
    ls ./gui_u
    CHECK_RESULT $? 0 0 "Failed to use option: -u"
    rm -f ./gui_u
    expect <<EOF
        spawn iftop
        send "h"
        expect "iftop, version 1.0pre4" {
            exec touch ./gui_h
        }
        send "q"
        expect eof
EOF
    ls ./gui_h
    CHECK_RESULT $? 0 0 "Failed to use GUI key: h"
    rm -f ./gui_h
    expect <<EOF
        spawn iftop
        send "n"
        expect "DNS resolution" {
            exec touch ./gui_n
        }
        send "q"
        expect eof
EOF
    ls ./gui_n
    CHECK_RESULT $? 0 0 "Failed to use GUI key: n"
    rm -f ./gui_n
    expect <<EOF
        spawn iftop
        send "s"
        expect "source host" {
            exec touch ./gui_s
        }
        send "q"
        expect eof
EOF
    ls ./gui_s
    CHECK_RESULT $? 0 0 "Failed to use GUI key: s"
    rm -f ./gui_s
    expect <<EOF
        spawn iftop
        send "d"
        expect "dest host" {
            exec touch ./gui_d
        }
        send "q"
        expect eof
EOF
    ls ./gui_d
    CHECK_RESULT $? 0 0 "Failed to use GUI key: d"
    rm -f ./gui_d
    expect <<EOF
        spawn iftop
        send "t"
        expect "per host" {
            exec touch ./gui_t
        }
        send "q"
        expect eof
EOF
    ls ./gui_t
    CHECK_RESULT $? 0 0 "Failed to use GUI key: t"
    rm -f ./gui_t
    expect <<EOF
        spawn iftop
        send "N"
        expect "Port resolution" {
            exec touch ./gui_N
        }
        send "q"
        expect eof
EOF
    ls ./gui_N
    CHECK_RESULT $? 0 0 "Failed to use GUI key: N"
    rm -f ./gui_N
    expect <<EOF
        spawn iftop
        send "S"
        expect "Port display SOURCE" {
            exec touch ./gui_S
    }
        send "q"
        expect eof
EOF
    ls ./gui_S
    CHECK_RESULT $? 0 0 "Failed to use GUI key: S"
    rm -f ./gui_S
    expect <<EOF
        spawn iftop
        send "D"
        expect "Port display DEST" {
            exec touch ./gui_D
        }
        send "q"
        expect eof
EOF
    ls ./gui_D
    CHECK_RESULT $? 0 0 "Failed to use GUI key: D"
    rm -f ./gui_D
    expect <<EOF
        spawn iftop
        send "p"
        expect "Port display" {
            exec touch ./gui_p
        }
        send "q"
        expect eof
EOF
    ls ./gui_p
    CHECK_RESULT $? 0 0 "Failed to use GUI key: p"
    rm -f ./gui_p
    expect <<EOF
        spawn iftop
        send "P"
        expect "Display paused" {
            exec touch ./gui_P
        }
        send "q"
        expect eof
EOF
    ls ./gui_P
    CHECK_RESULT $? 0 0 "Failed to use GUI key: p"
    rm -f ./gui_P
    expect <<EOF
        spawn iftop
        send "b"
        expect "Bars" {
            exec touch ./gui_b
        }
        send "q"
        expect eof
EOF
    ls ./gui_b
    CHECK_RESULT $? 0 0 "Failed to use GUI key: b"
    rm -f ./gui_b
    expect <<EOF
        spawn iftop
        send "B"
        expect "Bars" {
            exec touch ./gui_B
        }
        send "q"
        expect eof
EOF
    ls ./gui_B
    CHECK_RESULT $? 0 0 "Failed to use GUI key: B"
    rm -f ./gui_B
    expect <<EOF
        spawn iftop
        send "T"
        expect "cumulative" {
            exec touch ./gui_T
        }
        send "q"
        expect eof
EOF
    ls ./gui_T
    CHECK_RESULT $? 0 0 "Failed to use GUI key: T"
    rm -f ./gui_T
    expect <<EOF
        spawn iftop
        send "j"
        send "k"
        expect "TOTAL" {
            exec touch ./gui_j_k
        }
        send "q"
        expect eof
EOF
    ls ./gui_j_k
    CHECK_RESULT $? 0 0 "Failed to use GUI key: j/k"
    rm -f ./gui_j_k
    expect <<EOF
        spawn iftop
        send "f"
        expect "Net filter" {
            send "\033"
            exec touch ./gui_f
        }
        send "q"
        expect eof
EOF
    ls ./gui_f
    CHECK_RESULT $? 0 0 "Failed to use GUI key: f"
    rm -f ./gui_f
    expect <<EOF
        spawn iftop
        send "l"
        expect "Screen filter" {
            send "\033"
            exec touch ./gui_l
        }
        send "q"
        expect eof
EOF
    ls ./gui_l
    CHECK_RESULT $? 0 0 "Failed to use GUI key: l"
    rm -f ./gui_l
    expect <<EOF
        spawn iftop
        send "L"
        expect "Logarithmic" {
            exec touch ./gui_L
        }
        send "L"
        expect "Linear" {
            exec touch ./gui_L
        }
        send "q"
        expect eof
EOF
    ls ./gui_L
    CHECK_RESULT $? 0 0 "Failed to use GUI key: L"
    rm -f ./gui_L
    expect <<EOF
        spawn iftop
        send "!"
        expect "subshells" {
            send "q"
            exec touch ./gui_exclamation_mark
        }
        expect eof
EOF
    ls ./gui_exclamation_mark
    CHECK_RESULT $? 0 0 "Failed to use GUI key: !"
    rm -f ./gui_exclamation_mark
    expect <<EOF
        spawn iftop
        send "q"
        expect eof
EOF
    pgrep 'iftop'
    CHECK_RESULT $? 1 0 "Failed to use GUI key: q"
    expect <<EOF
        spawn iftop
        send "1"
        expect "Sort by col 1" {
            exec touch ./gui_1
        }
        send "q"
        expect eof
EOF
    ls ./gui_1
    CHECK_RESULT $? 0 0 "Failed to use GUI key: 1"
    rm -f ./gui_1
    expect <<EOF
        spawn iftop
        send "2"  
        expect "Sort by col 2" {
            exec touch ./gui_2  
        }
        send "q"
        expect eof
EOF
    ls ./gui_2  
    CHECK_RESULT $? 0 0 "Failed to use GUI key: 2"  
    rm -f ./gui_2  
    expect <<EOF
        spawn iftop
        send "3"  
        expect "Sort by col 3" {
            exec touch ./gui_3  
        }
        send "q"
        expect eof
EOF
        ls ./gui_3  
        CHECK_RESULT $? 0 0 "Failed to use GUI key: 3"  
        rm -f ./gui_3  
        expect <<EOF
        spawn iftop
        send "o"  
        expect "Order frozen" {
            exec touch ./gui_o  
        }
        send "q"
        expect eof
EOF
    ls ./gui_o  
    CHECK_RESULT $? 0 0 "Failed to use GUI key: o"  
    rm -f ./gui_o  
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
