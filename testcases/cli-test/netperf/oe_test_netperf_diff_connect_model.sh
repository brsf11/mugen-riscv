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
#@Author        :   hejinjin
#@Contact       :   jinjin@isrc.iscas.ac.cn
#@Date          :   2021/12/19
#@License       :   Mulan PSL v2
#@Desc          :   netperf test different connect models
####################################
source "./common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    pre_env
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."

    P_SSH_CMD --cmd "netserver -p ${rdport}" | grep "Starting netserver"
    CHECK_RESULT $? 0 0 "netserver execution failed."
    
    netperf -H "$NODE2_IPV4" -p ${rdport} -t UDP_STREAM -l 1 | grep "UDP STREAM TEST"
    CHECK_RESULT $? 0 0 "netperf -t UDP_STREAM execution failed."
    netperf -H "$NODE2_IPV4" -p ${rdport} -t TCP_STREAM -l 1 | grep "TCP STREAM TEST"
    CHECK_RESULT $? 0 0 "netperf -t TCP_STREAM execution failed."
    netperf -H "$NODE2_IPV4" -p ${rdport} -t TCP_RR -l 1 | grep "TCP REQUEST/RESPONSE TEST"
    CHECK_RESULT $? 0 0 "netperf -t TCP_RR execution failed."
    netperf -H "$NODE2_IPV4" -p ${rdport} -t TCP_CRR -l 1 | grep "TCP Connect/Request/Response TEST"
    CHECK_RESULT $? 0 0 "netperf -t TCP_CRR execution failed."
    netperf -H "$NODE2_IPV4" -p ${rdport} -t UDP_RR -l 1 | grep "UDP REQUEST/RESPONSE TEST"
    CHECK_RESULT $? 0 0 "netperf -t UDP_RR execution failed."
    
    P_SSH_CMD --cmd "pkill -9 netserver
        netstat -apn" | grep netserver
    CHECK_RESULT $? 0 1 "pkill -9 netserver execution failed."

    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    clean_env
    LOG_INFO "End to restore the test environment."
}

main "$@"