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
# @Desc      :   Test iftop config
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
    ipv6_target_addr=$(host huawei.com | grep 'IPv6' | awk '{print $5}')
    ipv6_target_network=$(ipcalc -n $ipv6_target_addr/64 | cut -d '=' -f2)
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    echo "interface: ${net_cards[0]}" > ./iftoprc
    iftop -t -s 1 2>&1 | grep "Listening on ${net_cards[0]}"
    CHECK_RESULT $? 0 0 "Failed to use config directive: interface"
    ping "${ipv4_target_addr}" -c 100 > /dev/null 2>&1 &
    dns_resolution_work=1
    for ((i = 0; i < 10; i++)); do
        if iftop -t -s 1 2>&1 | grep "${ipv4_target_hostname}"; then
            dns_resolution_work=0
            break
        fi
    done
    pkill -f 'ping'
    if [ $dns_resolution_work -eq 0 ]; then
        ping "${ipv4_target_addr}" -c 100 >/dev/null 2>&1 &
        echo 'dns-resolution: no' > ./iftoprc
        iftop -t -s 1 -c ./iftoprc 2>&1 | grep "${ipv4_target_hostname}"
        CHECK_RESULT $? 0 1 "Failed to use config directive: dns-resolution"
    else
        LOG_WARN "DNS RESOLUTION NOT WORK."
    fi
    pkill -f 'ping'
    result=1
    echo 'port-resolution: no' > ./iftoprc
    for ((i = 0; i < 10; i++)); do
        if iftop -t -s 1 -P -c ./iftoprc 2>&1 | grep ':22'; then
            result=0
            break
        fi
    done
    CHECK_RESULT $result 0 0 "Failed to use config directive: port-resolution"
    result=1
    echo 'filter-code: dst port 22' > ./iftoprc
    for ((i = 0; i < 10; i++)); do
        if iftop -t -s 1 -P -N -c ./iftoprc 2>&1 | grep ':22'; then
            result=0
            break
        fi
    done
    CHECK_RESULT $result 0 0 "Failed to use config directive: filter-code"
    echo 'show-bars: yes' > ./iftoprc
    expect <<EOF
        spawn iftop -c ./iftoprc
        expect "Listening on" {
            exec touch ./config_show_bars
        }
        send "q"
        expect eof
EOF
    ls ./config_show_bars
    CHECK_RESULT $? 0 0 "Failed to use config directive: show-bars"
    rm -f ./config_show_bars
    echo 'promiscuous: yes' > ./iftoprc
    result=1
    ping -I "${ipv4_addr_1}" "${ipv4_target_addr}" -c 100 > /dev/null 2>&1 &
    ping -I "${ipv4_addr_2}" "${ipv4_target_addr}" -c 100 > /dev/null 2>&1 &
    for ((i = 0; i < 10; i++)); do
        output=$(iftop -t -s 1 -n -c ./iftoprc 2>&1)
        if (echo "${output}" | grep -B 1 "${ipv4_target_addr}" | grep "${ipv4_addr_1}") && (echo "${output}" | grep -B 1 "${ipv4_target_addr}" | grep "${ipv4_addr_2}"); then
            result=0
            break
        fi
    done
    CHECK_RESULT $result 0 0 "Failed to use config directive: promiscuous"
    pkill -f 'ping'
    echo 'port-display: on' > ./iftoprc
    result=1
    for ((i = 0; i < 10; i++)); do
        if iftop -t -s 1 -c ./iftoprc 2>&1 | grep ':ssh'; then
            result=0
            break
        fi
    done
    CHECK_RESULT $result 0 0 "Failed to use config directive: port-display"
    echo 'link-local: yes' > ./iftoprc
    iftop -t -s 1 -c ./iftoprc 2>&1 | grep 'Listening on'
    CHECK_RESULT $? 0 0 "Failed to use config directive: link-local"
    ping -I "${ipv4_addr_1}" "${ipv4_target_addr}" -c 100 > /dev/null 2>&1 &
    echo 'hide-source: yes' > ./iftoprc
    iftop -t -s 1 -n -c ./iftoprc 2>&1 | grep -B 1 "${ipv4_target_addr}" | grep '*'
    CHECK_RESULT $? 0 0 "Failed to use config directive: hide-source"
    pkill -f 'ping'
    ping -I "${ipv4_addr_1}" "${ipv4_target_addr}" -c 100 > /dev/null 2>&1 &
    echo 'hide-destination: yes' > ./iftoprc
    iftop -t -s 1 -n -c ./iftoprc 2>&1 | grep -A 1 "${ipv4_addr_1}" | grep '*'
    CHECK_RESULT $? 0 0 "Failed to use config directive: hide-destination"
    pkill -f 'ping'
    echo 'bandwidth-unit: bytes' > ./iftoprc
    expect <<EOF
        spawn iftop -c ./iftoprc
        expect "KB" {
            exec touch ./config_bandwidt_unit
        }
        send "q"
        expect eof
EOF
    ls ./config_bandwidt_unit
    CHECK_RESULT $? 0 0 "Failed to use config directive: bandwidth-unit"
    rm -f ./config_bandwidt_unit
    echo 'use-bytes: yes' > ./iftoprc
    expect <<EOF
        spawn iftop -c ./iftoprc
        expect "KB" {
            exec touch ./config_use_bytes
        }
        send "q"
        expect eof
EOF
    ls ./config_use_bytes
    CHECK_RESULT $? 0 0 "Failed to use config directive: use-bytes"
    rm -f ./config_use_bytes
    echo 'sort: 2s' > ./iftoprc
    iftop -t -s 1 -c ./iftoprc 2>&1 | grep '2s'
    CHECK_RESULT $? 0 0 "Failed to use config directive: sort"
    echo 'line-display: two-line' > ./iftoprc
    iftop -t -s 1 -c ./iftoprc 2>&1 | grep 'Listening on'
    CHECK_RESULT $? 0 0 "Failed to use config directive: line-display"
    echo 'show-totals: yes' > ./iftoprc
    iftop -t -s 1 -c ./iftoprc 2>&1 | grep 'cumulative'
    CHECK_RESULT $? 0 0 "Failed to use config directive: show-totals"
    echo 'log-scale: yes' > ./iftoprc
    iftop -t -s 1 -c ./iftoprc 2>&1 | grep 'Listening on'
    CHECK_RESULT $? 0 0 "Failed to use config directive: log-scale"
    echo 'max-bandwidth: 5M' > ./iftoprc
    expect <<EOF
        spawn iftop -c ./iftoprc
        expect "5.00Mb" {
            exec touch ./config_max_bandwidth
        }
        send "q"
        expect eof
EOF
    ls ./config_max_bandwidth
    CHECK_RESULT $? 0 0 "Failed to use config directive: max_bandwidth"
    rm -f ./config_max_bandwidth
    echo "net-filter: ${ipv4_target_network}/24" > ./iftoprc
    ping "${ipv4_target_addr}" -c 100 >/dev/null 2>&1 &
    expect <<EOF
        spawn iftop -n -c ./iftoprc
        expect "$ipv4_target_addr" {
            exec touch ./config_net_filter
        }
        send "q"
        expect eof
EOF
    ls ./config_net_filter
    CHECK_RESULT $? 0 0 "Failed to use config directive: net-filter"
    rm -f ./config_net_filter
    pkill -f 'ping'
    echo "net-filter6: $ipv6_target_network" > ./iftoprc
    ping -6 $ipv6_target_addr -c 100 > /dev/null 2>&1 &
    expect <<EOF
        spawn iftop -c ./iftoprc
        expect "$ipv6_target_network" {
            exec touch ./config_net_filter6
        }
        send "q"
        expect eof
EOF
    ls ./config_net_filter6
    CHECK_RESULT $? 0 0 "Failed to use config directive: net-filter6"
    rm -f ./config_net_filter6
    pkill -f 'ping'
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    DNF_REMOVE
    rm -f ./iftoprc
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
