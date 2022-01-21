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
# @Desc      :   Test iftop text mode
# #############################################

source "../common/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL iftop
    DNF_INSTALL bind-utils
    DNF_INSTALL ipcalc
    IFS=' ' read -r -a net_cards <<< "$(TEST_NIC)"
    ipv4_addr_1=$(nmcli device show ${net_cards[0]} | grep IP4.ADDRESS | awk '{print $2}' | cut -d '/' -f1)
    ipv4_addr_2=$(nmcli device show ${net_cards[1]} | grep IP4.ADDRESS | awk '{print $2}' | cut -d '/' -f1)
    ipv4_target_addr=$(host huawei.com | grep 'has address' | awk '{print $4}')
    IFS='.' read -r -a target_addr <<< "$ipv4_target_addr"
    ipv4_target_hostname="${target_addr[3]}.${target_addr[2]}.${target_addr[1]}.${target_addr[0]}"
    ipv4_target_network=$(ipcalc -n $ipv4_target_addr/24 | cut -d '=' -f2)
    ipv6_target_addr=$(host huawei.com | grep 'IPv6' | awk '{print $5}')
    ipv6_target_network=$(ipcalc -n $ipv6_target_addr/64 | cut -d '=' -f2)
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    iftop -h | grep 'Synopsis: iftop'
    CHECK_RESULT $? 0 0 "Failed to use option: -h"
    iftop -t -s 1 2>&1 | grep 'Listening on'
    CHECK_RESULT $? 0 0 "Failed to use option: -s and -t"
    ping $ipv4_target_addr -c 100 >/dev/null 2>&1 &
    dns_resolution_work=1
    for ((i = 0; i < 100; i++)); do
        if iftop -t -s 1 2>&1 | grep "$ipv4_target_hostname"; then
            dns_resolution_work=0
            break
        fi
    done
    pkill -f 'ping'
    if [ $dns_resolution_work -eq 0 ]; then
        ping "${ipv4_target_addr}" -c 100 >/dev/null 2>&1 &
        iftop -t -s 1 -n 2>&1 | grep "$ipv4_target_hostname"
        CHECK_RESULT $? 0 1 "Failed to use option: -n"
    else
        LOG_WARN "DNS RESOLUTION NOT WORK."
    fi
    pkill -f 'ping'
    result=1
    for ((i = 0; i < 10; i++)); do
        if iftop -t -s 1 -P | grep ':ssh'; then
            result=0
            break
        fi
    done
    CHECK_RESULT $result 0 0 "Failed to use option: -P"
    result=1
    for ((i = 0; i < 10; i++)); do
        if iftop -t -s 1 -P -N 2>&1 | grep ':22'; then
            result=0
            break
        fi
    done
    CHECK_RESULT $result 0 0 "Failed to use option: -N"
    result=1
    ping -I "${ipv4_addr_1}" "${ipv4_target_addr}" -c 100 > /dev/null 2>&1 &
    ping -I "${ipv4_addr_2}" "${ipv4_target_addr}" -c 100 > /dev/null 2>&1 &
    for ((i = 0; i < 10; i++)); do
        output=$(iftop -t -s 1 -n -p 2>&1)
        if (echo "${output}" | grep -A 1 "${ipv4_addr_1}" | grep "${ipv4_target_addr}") && (echo "${output}" | grep -A 1 "${ipv4_addr_2}" | grep "${ipv4_target_addr}"); then
            result=0
            break
        fi
    done
    CHECK_RESULT $result 0 0 "Failed to use option: -p"
    pkill -f 'ping'
    result=1
    ping -I "${ipv4_addr_1}" "${ipv4_target_addr}" -c 100 >/dev/null 2>&1 &
    for ((i = 0; i < 10; i++)); do
        if iftop -t -s 1 -B 2>&1 | grep "${ipv4_addr_1}" | grep 'B'; then
            result=0
            break
        fi
    done
    CHECK_RESULT $result 0 0 "Failed to use option: -B"
    pkill -f 'ping'
    iftop -t -s 1 -i ${net_cards[0]} 2>&1 | grep "Listening on ${net_cards[0]}"
    CHECK_RESULT $? 0 0 "Failed to use option: -i"
    iftop -t -s 1 -P -N -f "dst port 22" 2>&1 | grep ':22'
    CHECK_RESULT $? 0 0 "Failed to use option: -f"
    iftop -t -s 1 -m 10b 2>&1 | grep 'Listening on'
    CHECK_RESULT $? 0 0 "Failed to use option: -m"
    iftop -t -s 5 -o 2s 2>&1 | grep '2s'
    CHECK_RESULT $? 0 0 "Failed to use option: -o 2s"
    iftop -t -s 15 -o 10s 2>&1 | grep '10s'
    CHECK_RESULT $? 0 0 "Failed to use option: -o 10s"
    iftop -t -s 45 -o 40s 2>&1 | grep '40s'
    CHECK_RESULT $? 0 0 "Failed to use option: -o 40s"
    iftop -t -s 1 -o source 2>&1 | grep 'Listening on'
    CHECK_RESULT $? 0 0 "Failed to use option: -o source"
    iftop -t -s 1 -o destination 2>&1 | grep 'Listening on'
    CHECK_RESULT $? 0 0 "Failed to use option: -o destination"
    iftop -t -s 1 -L 5 2>&1 | grep 'Listening on'
    CHECK_RESULT $? 0 0 "Failed to use option: -L"
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
