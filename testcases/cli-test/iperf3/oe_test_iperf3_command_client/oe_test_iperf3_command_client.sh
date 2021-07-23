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
#@Desc          :   iperf3 command parameter automation use case
####################################
source ../common/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."

    pre_env

    LOG_INFO "End to prepare the test environment."
}
function run_test() {
    LOG_INFO "Start to run test."

    iperf3 -c "$NODE2_IPV4" -n 1400 -V | grep "1400 bytes to send"
    CHECK_RESULT $? 0 0 "iperf3 -n execution failed."
    iperf3 -c "$NODE2_IPV4" -k 1400 -V | grep "1400 blocks to send"
    CHECK_RESULT $? 0 0 "iperf3 -k execution failed."
    iperf3 -c "$NODE2_IPV4" -P 2 | grep -c connected | grep 2
    CHECK_RESULT $? 0 0 "iperf3 -P execution failed."
    iperf3 -c "$NODE2_IPV4" --get-server-output | grep "Server output"
    CHECK_RESULT $? 0 0 "iperf3 --get-server-output execution failed."
    [ $(expr $(iperf3 -c "$NODE2_IPV4" -w 20240 | grep "sender" | awk '{print $5}') \> $(iperf3 -c "$NODE2_IPV4" -w 102400 | grep "sender" | awk '{print $5}')) -eq 0 ]
    CHECK_RESULT $? 0 0 "iperf3 -w execution failed."
    iperf3 -c "$NODE2_IPV4" -R | grep "Reverse mode"
    CHECK_RESULT $? 0 0 "iperf3 -R execution failed."
    iperf3 -c "$NODE2_IPV4" -T test | grep "test:"
    CHECK_RESULT $? 0 0 "iperf3 -T execution failed."

    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."

    clean_env

    LOG_INFO "End to restore the test environment."
}

main "$@"
