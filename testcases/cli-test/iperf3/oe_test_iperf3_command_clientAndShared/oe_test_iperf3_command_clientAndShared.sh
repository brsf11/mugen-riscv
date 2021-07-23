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

    iperf3 -c "$NODE2_IPV4" -d | grep "sent.*bytes of.*total"
    CHECK_RESULT $? 0 0 "iperf3 -d execution failed."
    iperf3 -c "$NODE2_IPV4" -f k | grep "Kbits"
    CHECK_RESULT $? 0 0 "iperf3 -f execution failed."
    iperf3 -c "$NODE2_IPV4" -V | grep "Cookie"
    CHECK_RESULT $? 0 0 "iperf3 -V execution failed."
    iperf3 -c "$NODE2_IPV4" -J | sed -n '1p' | grep "{" && iperf3 -c "$NODE2_IPV4" -J | sed -n '$p' | grep "}"
    CHECK_RESULT $? 0 0 "iperf3 -J execution failed."
    iperf3 -c "$NODE2_IPV4" --logfile /tmp/iperf3.log && grep "iperf Done" /tmp/iperf3.log
    CHECK_RESULT $? 0 0 "iperf3 --logfile execution failed."
    iperf3 -c "$NODE2_IPV4" -u | grep "Datagrams"
    CHECK_RESULT $? 0 0 "iperf3 -u execution failed."
    time -p (iperf3 -c "$NODE2_IPV4" -t 2 | sed -n '/real/p' >/tmp/tmp) >>/tmp/tmp 2>&1
    [ $(expr $(sed -n '1p' /tmp/tmp | grep "real" | awk '{print $2}') \< 3) -eq 1 ]
    CHECK_RESULT $? 0 0 "iperf3 -t 2 execution failed."

    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."

    clean_env
    rm -rf /tmp/iperf3.log /tmp/tmp

    LOG_INFO "End to restore the test environment."
}

main "$@"
