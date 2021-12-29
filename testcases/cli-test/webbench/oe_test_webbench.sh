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
#@Author    	:   xiehaochen
#@Contact   	:   haochen@isrc.iscas.ac.cn
#@Date      	:   2021-12-12
#@License   	:   Mulan PSL v2
#@Version   	:   1.0
#@Desc      	:   Webbench tests
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function config_params()
{
    LOG_INFO "Start to config params of the case."
    TEST_URL='http://www.baidu.com/'
    TEST_CLIENTS=10
    TEST_TIME=5
    PROXY_SERVER='www.baidu.com'
    PROXY_PORT=80
    WEBBENCH_VERSION=$(rpm -qa webbench | awk -F '-' '{print $2}')
    LOG_INFO "End to config params of the case."
}

function pre_test()
{
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL webbench
    LOG_INFO "End to prepare the test environment."
}

function run_test()
{
    LOG_INFO "Start to run test."
    webbench -h 2>&1 | grep webbench
    CHECK_RESULT $? 0 0 "webbench Help Test -h FAILED."
    webbench -V | grep $WEBBENCH_VERSION
    CHECK_RESULT $? 0 0 "webbench Version Test -V FAILED"
    webbench -c ${TEST_CLIENTS} -t ${TEST_TIME} ${TEST_URL} --get | grep "GET"
    CHECK_RESULT $? 0 0 "webbench GET Test --get FAILED,the return value is not 0."
    webbench -c ${TEST_CLIENTS} -t ${TEST_TIME} ${TEST_URL} --head | grep "HEAD"
    CHECK_RESULT $? 0 0 "webbench HEAD Test --head FAILED,the return value is not 0."
    webbench -c ${TEST_CLIENTS} -t ${TEST_TIME} ${TEST_URL} --options | grep "OPTIONS"
    CHECK_RESULT $? 0 0 "webbench OPTIONS Test --options FAILED,the return value is not 0."
    webbench -c ${TEST_CLIENTS} -t ${TEST_TIME} ${TEST_URL} --trace | grep "TRACE"
    CHECK_RESULT $? 0 0 "webbench TRACE Test --trace FAILED,the return value is not 0."
    webbench -c ${TEST_CLIENTS} -t ${TEST_TIME} ${TEST_URL} -9 | grep "HTTP/0.9"
    CHECK_RESULT $? 0 0 "webbench HTTP/0.9 Test -9 FAILED,the return value is not 0."
    webbench -c ${TEST_CLIENTS} -t ${TEST_TIME} ${TEST_URL} -1 | grep "Benchmarking"
    CHECK_RESULT $? 0 0 "webbench HTTP/1.0 Test -1 FAILED,the return value is not 0."
    webbench -c ${TEST_CLIENTS} -t ${TEST_TIME} ${TEST_URL} -2 | grep "HTTP/1.1"
    CHECK_RESULT $? 0 0 "webbench HTTP/1.1 Test -2 FAILED,the return value is not 0."
    webbench -c ${TEST_CLIENTS} -t ${TEST_TIME} ${TEST_URL} -f | grep "early socket close"
    CHECK_RESULT $? 0 0 "webbench Force Test -f FAILED,the return value is not 0."
    webbench -c ${TEST_CLIENTS} -t ${TEST_TIME} ${TEST_URL} -r | grep "forcing reload"
    CHECK_RESULT $? 0 0 "webbench Reload Test -r FAILED,the return value is not 0."
    webbench -c ${TEST_CLIENTS} -t ${TEST_TIME} -p ${PROXY_SERVER}:${PROXY_PORT} ${TEST_URL} | grep "via proxy server"
    CHECK_RESULT $? 0 0 "webbench Proxy Test -p FAILED,the return value is not 0."
    LOG_INFO "End to run test."
}

function post_test()
{
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}

main "$@"

