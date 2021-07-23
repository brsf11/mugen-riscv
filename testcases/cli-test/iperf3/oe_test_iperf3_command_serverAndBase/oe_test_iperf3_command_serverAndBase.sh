#!/usr/bin/bash

# Copyright (c) 2021. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.
####################################
#@Author        :   wangjingfeng
#@Contact       :   1136232498@qq.com
#@Date          :   2020/10/10
#@License       :   Mulan PSL v2
#@Desc          :   iperf3 command parameter automation use case,use server execution
####################################
source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."

    DNF_INSTALL "iperf3 net-tools"
    DNF_INSTALL "iperf3" 2

    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."

    iperf3 -v | grep $(rpm -q iperf3 | awk -F '-' '{print $2}')
    CHECK_RESULT $? 0 0 "iperf3 -v execution failed."
    iperf3 --version | grep $(rpm -q iperf3 | awk -F '-' '{print $2}')
    CHECK_RESULT $? 0 0 "iperf3 --version execution failed."
    iperf3 -h | grep "Usage"
    CHECK_RESULT $? 0 0 "iperf3 -h execution failed."
    iperf3 --help | grep "Usage"
    CHECK_RESULT $? 0 0 "iperf3 --help execution failed."
    systemctl stop firewalld
    iperf3 -s &
    SLEEP_WAIT 2
    netstat -lnp | grep 5201 | grep iperf3
    CHECK_RESULT $? 0 0 "iperf3 -s execution failed."
    SSH_CMD "iperf3 -c $NODE1_IPV4" "$NODE2_IPV4" "$NODE2_PASSWORD" "$NODE2_USER" | grep "iperf Done"
    CHECK_RESULT $? 0 0 "iperf3 -c serverIP execution failed."
    kill -9 $(pgrep -f "iperf3 -s")
    rdport=$(GET_FREE_PORT "$NODE1_IPV4")
    iperf3 -s -p "${rdport}" &
    SLEEP_WAIT 2
    netstat -lnp | grep "${rdport}" | grep iperf3
    CHECK_RESULT $? 0 0 "iperf3 -s -p execution failed."
    kill -9 $(pgrep -f "iperf3 -s -p ${rdport}")
    iperf3 -s -I /tmp/iperf3_pid &
    SLEEP_WAIT 2
    result=$(pgrep -f "iperf3 -s -I")
    result1=$(cat /tmp/iperf3_pid)
    [ "$result1" -eq "${result}" ]
    CHECK_RESULT $? 0 0 "iperf3 -s -I execution failed."
    kill -9 "$result1"
    iperf3 -s -1 &
    SSH_CMD "iperf3 -c $NODE1_IPV4" "$NODE2_IPV4" "$NODE2_PASSWORD" "$NODE2_USER"
    [ -z $(pgrep -f "iperf3 -s") ]
    CHECK_RESULT $? 0 0 "iperf3 -s -1 execution failed."

    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."

    DNF_REMOVE
    rm -rf /tmp/iperf3_pid
    systemctl start firewalld

    LOG_INFO "End to restore the test environment."
}

main "$@"
