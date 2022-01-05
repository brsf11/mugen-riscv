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
#@Desc          :   netperf test remote command-netserver
####################################
source "./common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    pre_env
    LOG_INFO "End to prepare the test environment."
}
function run_test() {
    LOG_INFO "Start to run test."

    P_SSH_CMD --cmd "netserver -h 2>&1 | grep Usage"
    CHECK_RESULT $? 0 0 "netserver -h failed."
    P_SSH_CMD --cmd "netserver -V" | grep "version"
    CHECK_RESULT $? 0 0 "netserver -V failed."
    P_SSH_CMD --cmd "netserver -d -p ${rdport}" | grep "check_if_inetd"
    CHECK_RESULT $? 0 0 "netserver -d failed."
    test_server "Throughput" "-d"
    P_SSH_CMD --cmd "netserver -f -N -v 2 -p ${rdport}" | grep "Starting netserver"
    CHECK_RESULT $? 0 0 "netserver -f -N -v 2 failed."
    test_server "Throughput" "-f -N -v 2"
    P_SSH_CMD --cmd "netserver -L ,AF_INET6 -p ${rdport}" | grep "AF_INET6"
    CHECK_RESULT $? 0 0 "netserver -L name,family failed."
    test_server "Throughput" "-L name,family"
    P_SSH_CMD --cmd "netserver -4 -p ${rdport}" | grep "Starting netserver"
    CHECK_RESULT $? 0 0 "netserver -4 failed."
    test_server "Throughput" "-4"
    P_SSH_CMD --cmd "netserver -6 -p ${rdport}" | grep "AF_INET6"
    CHECK_RESULT $? 0 0 "netserver -6 failed."
    test_server "Throughput" "-6"
    P_SSH_CMD --cmd "netserver -Z 123 -p ${rdport}" | grep "Starting netserver"
    CHECK_RESULT $? 0 0 "netserver -Z 123 failed."
    netperf -H "$NODE2_IPV4" -Z 123 -p ${rdport} -l 1 | grep "Throughput"
    CHECK_RESULT $? 0 0 "after netserver -Z 123,netperf -Z execution failed."
    P_SSH_CMD --cmd "pkill -9 netserver
        netstat -apn" | grep netserver
    CHECK_RESULT $? 0 1 "pkill -9 netserver execution failed."
    SLEEP_WAIT 1

    LOG_INFO "End to run test."
}
function post_test() {
    LOG_INFO "Start to restore the test environment."
    clean_env
    LOG_INFO "End to restore the test environment."
}

main "$@"