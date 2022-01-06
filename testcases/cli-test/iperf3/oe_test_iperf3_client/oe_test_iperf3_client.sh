#!/usr/bin/bash

#@ License : Mulan PSL v2
# Copyright (c) 2021. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# ##################################
# @Author    :   juniorpy
# @Contact   :   alucard_zjh@163.com
# @Date      :   2021/07/21
# @Desc      :   Test "iperf3 -c 127.0.0.1 -t 3 -i 1 -p 51314" command
# ##################################

source "$OET_PATH/libs/locallibs/common_lib.sh"
 
function pre_test() {
    DNF_INSTALL iperf3
}

function run_test() {
    LOG_INFO "Start to run test."
    iperf3 -s -p 51314 -i 1 -D 2>&1
    CHECK_RESULT $? 0 0 "CHECK iperf3 -s -p 51314 -i 1 -D FAILED"
    SLEEP_WAIT 1
    iperf3 -c 127.0.0.1 -i 1 -t 3 -p 51314 2>&1
    CHECK_RESULT $? 0 0 "Error: iperf3 -c ... run failed"  
    iperf3 -s -p 51314 -D 2>&1
    CHECK_RESULT $? 0 0 "CHECK iperf3 -s -p 51314 -D FAILED"
    SLEEP_WAIT 1
    iperf3 -c 127.0.0.1 -P 2 -t 2 -p 51314 -d 2>&1
    CHECK_RESULT $? 0 0 "Error: iperf3 -P ... run failed"
    iperf3 -s -p 51314 -D 2>&1
    CHECK_RESULT $? 0 0 "CHECK iperf3 -s -p 51314 -D FAILED"
    ss -ntlp | grep 51314 | grep iperf3 2>&1
    CHECK_RESULT $? 0 0 "Error: iperf3 -s ... run failed"
    iperf3 -s -p 51314 -D 2>&1
    CHECK_RESULT $? 0 0 "CHECK iperf3 -s -p 51314 -D FAILED"
    SLEEP_WAIT 1
    iperf3 -u -c 127.0.0.1 -p 51314 -b 10M -P 10 -t 3 2>&1
    CHECK_RESULT $? 0 0 "Error: iperf3 -u -b ... run failed"
    iperf3 -v 2>&1 | grep "iperf 3"
    CHECK_RESULT $? 0 0 "Error: iperf3 -v run failed"
    iperf3 --version  2>&1 | grep "iperf 3"
    CHECK_RESULT $? 0 0 "Error: iperf3 --version run failed"
    LOG_INFO "End of the test."
}

function post_test() {
    DNF_REMOVE
}

main "$@"
