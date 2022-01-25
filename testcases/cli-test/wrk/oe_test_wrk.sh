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
# @Date      :   2022/1/24
# @License   :   Mulan PSL v2
# @Desc      :   Test iftop text mode
# #############################################

source "../common/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL wrk
    DNF_INSTALL nginx
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    systemctl start nginx
    wrk http://127.0.0.1 2>&1 | grep 'Running'
    CHECK_RESULT $? 0 0 "Failed: Minimal test"
    wrk -v 2>&1 | grep 'Copyright' | grep '[[:digit:]]*'
    CHECK_RESULT $? 0 0 "Failed option: -v"
    wrk --version 2>&1 | grep 'Copyright' | grep '[[:digit:]]*'
    CHECK_RESULT $? 0 0 "Failed option: --version"
    wrk --help 2>&1 | grep 'Usage: wrk'
    CHECK_RESULT $? 0 0 "Failed option: --help"
    wrk -c6 http://127.0.0.1 2>&1 | grep '6 connections'
    CHECK_RESULT $? 0 0 "Failed option: -c"
    wrk --connections 22 http://127.0.0.1 2>&1 | grep '22 connections'
    CHECK_RESULT $? 0 0 "Failed option: --connections"
    wrk -d8s http://127.0.0.1 2>&1 | grep 'Running 8s test'
    CHECK_RESULT $? 0 0 "Failed option: -d"
    wrk --duration 8s http://127.0.0.1 2>&1 | grep 'Running 8s test'
    CHECK_RESULT $? 0 0 "Failed option: --duration"
    wrk -c6 -t6 http://127.0.0.1 2>&1 | grep '6 threads'
    CHECK_RESULT $? 0 0 "Failed option: -t"
    wrk -c6 --threads 6 http://127.0.0.1 2>&1 | grep '6 threads'
    CHECK_RESULT $? 0 0 "Failed option: --threads"
    wrk -s ./report.lua http://127.0.0.1 2>&1 | grep -cE '50%,|90%,|99%,|99.999%,' | grep 4
    CHECK_RESULT $? 0 0 "Failed option: -s"
    wrk --script ./report.lua http://127.0.0.1 2>&1 | grep -cE '50%,|90%,|99%,|99.999%,' | grep 4
    CHECK_RESULT $? 0 0 "Failed option: --script"
    wrk -H 'GET / HTTP/1.1' http://127.0.0.1 | grep 'Running'
    CHECK_RESULT $? 0 0 "Failed option: -H"
    wrk --header 'GET / HTTP/1.1' http://127.0.0.1 | grep 'Running'
    CHECK_RESULT $? 0 0 "Failed option: --header"
    wrk --latency http://127.0.0.1 | grep 'Latency Distribution'
    CHECK_RESULT $? 0 0 "Failed option: --latency"
    wrk --timeout 1s http://127.0.0.1 | grep 'Running'
    CHECK_RESULT $? 0 0 "Failed option: --timeout"
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
