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
#@Desc          :   netperf basic command line test 
####################################
source "./common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    pre_env
    touch test.txt
    echo teststring > test.txt
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."

    P_SSH_CMD --cmd "netserver -p ${rdport}" | grep "Starting netserver"
    CHECK_RESULT $? 0 0 "netserver execution failed."

    netperf -V | grep "version"
    CHECK_RESULT $? 0 0 "netperf -V execution failed."
    netperf -h 2>&1 | grep "Usage"
    CHECK_RESULT $? 0 0 "netperf -h execution failed."
    netperf -H "$NODE2_IPV4" -p ${rdport} -l 1 | grep "Throughput"
    CHECK_RESULT $? 0 0 "netperf -H execution failed."
    netperf -H "$NODE2_IPV4" -p ${rdport} -a 1024,1024 -A 1024,1024 -l 1 | grep "Throughput"
    CHECK_RESULT $? 0 0 "netperf -a -A execution failed."
    netperf -H "$NODE2_IPV4" -p ${rdport} -c 0.5 -C 0.5 -l 1 | grep "% S"
    CHECK_RESULT $? 0 0 "netperf -c -C execution failed."
    netperf -H "$NODE2_IPV4" -p ${rdport} -d -l 1 | grep "complete_addrinfo"
    CHECK_RESULT $? 0 0 "netperf -d execution failed."
    netperf -H "$NODE2_IPV4" -p ${rdport} -F test.txt -l 1 | grep "Throughput"
    CHECK_RESULT $? 0 0 "netperf -F file execution failed."
    netperf -H "$NODE2_IPV4" -p ${rdport} -i 2,1 -I 95% -l 1 | grep "95% conf"
    CHECK_RESULT $? 0 0 "netperf -i -I execution failed."
    netperf -H "$NODE2_IPV4" -p ${rdport} -i 2,1 -I 95% -r -l 1 | grep "on result only"
    CHECK_RESULT $? 0 0 "netperf -r execution failed."
    netperf -H "$NODE2_IPV4" -p ${rdport} -j -L 0.0.0.0 AF_INET -l 1 | grep "Throughput"
    CHECK_RESULT $? 0 0 "netperf -j -L execution failed."
    netperf -H "$NODE2_IPV4" -p ${rdport} -o 1024,1024 -n 2 -l 1 | grep "Throughput"
    CHECK_RESULT $? 0 0 "netperf -o -n 2 execution failed."
    netperf -H "$NODE2_IPV4" -p ${rdport} -N -l 1 | grep "no control"
    CHECK_RESULT $? 0 0 "netperf -N execution failed."
    netperf -H "$NODE2_IPV4" -p ${rdport} -s 1 -S -l 1 | grep "Throughput"
    CHECK_RESULT $? 0 0 "netperf -s 1 -S 1execution failed."
    netperf -H "$NODE2_IPV4" -p ${rdport} -T 1,1 -l 1 | grep "cpu bind"
    CHECK_RESULT $? 0 0 "netperf -T 1,1 -S 1execution failed."
    netperf -H "$NODE2_IPV4" -p ${rdport} -v 2 -l 1 | grep "Segment"
    CHECK_RESULT $? 0 0 "netperf -v 2 1execution failed."
    netperf -H "$NODE2_IPV4" -p ${rdport} -y 1,1 -l 1 | grep "Throughput"
    CHECK_RESULT $? 0 0 "netperf -y 1,1 1execution failed."
    netperf -H "$NODE2_IPV4" -p ${rdport} -Y 1,1 -l 1 | grep "Throughput"
    CHECK_RESULT $? 0 0 "netperf -Y 1,1 1execution failed."
    netperf -H "$NODE2_IPV4" -p ${rdport} -f M -l 1 | grep "MBytes/sec"
    CHECK_RESULT $? 0 0 "netperf -f M execution failed."
    netperf -H "$NODE2_IPV4" -p ${rdport} -l 5 | grep " 5."
    CHECK_RESULT $? 0 0 "netperf -l 5 execution failed."
    netperf -H "$NODE2_IPV4" -p ${rdport} -t UDP_STREAM -l 1 -- -m 1024 | grep "1024"
    CHECK_RESULT $? 0 0 "netperf -m 1024 execution failed."
    netperf -H "$NODE2_IPV4" -p ${rdport} -P 0 -l 1 -- -m 1024 | grep "MIGRATED"
    CHECK_RESULT $? 0 1 "netperf -P 0 execution failed."
    netperf -H "$NODE2_IPV4" -p ${rdport} -l 1 -O "MIN_LAETENCY,MAX_LATENCY,MEAN_LATENCY,P90_LATENCY,P99_LATENCY,THROUGHPUT,THROUGHPUT_UNITS" | grep "sec"
    CHECK_RESULT $? 0 0 "netperf -O with different options execution failed."

    P_SSH_CMD --cmd "pkill -9 netserver
        netstat -apn" | grep netserver
    CHECK_RESULT $? 0 1 "pkill -9 netserver execution failed."
    
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf test.txt
    clean_env
    LOG_INFO "End to restore the test environment."
}

main "$@"