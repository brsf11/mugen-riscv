#!/user/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.
####################################
# @Author    	:   ye mengfei
# @Contact   	:   mengfei@isrc.iscas.ac.cn
# @Date      	:   2022-3-17
# @License   	:   Mulan PSL v2
# @Desc      	:   the test of fcgi package
####################################

source ./common/common_lib.sh

function config_params() {
    LOG_INFO "Start to config params of the case."
    connName1=$(GET_FREE_PORT)
    connName2=$(GET_FREE_PORT)
    appPath=./fcgi2-2.4.2/examples/echo
    serverNum1=1
    serverNum2=2
    cmdPath=./cmdFile
    LOG_INFO "End to config params of the case."
}

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL "fcgi libtool tar"
    pre_fcgi
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."

    cgi-fcgi -connect $connName1 $appPath $serverNum1 | grep "hello, it is a fast cgi application"
    CHECK_RESULT $? 0 0 "cgi-fcgi execute connect command unsuccessfully"

    cgi-fcgi -start -connect $connName2 $appPath $serverNum2
    CHECK_RESULT $? 0 0 "cgi-fcgi execute start command unsuccessfully, maybe the address connName is already in use"

    cgi-fcgi -bind -connect $connName2 | grep "hello, it is a fast cgi application"
    CHECK_RESULT $? 0 0 "cgi-fcgi execute bind command unsuccessfully"

    cgi-fcgi -f $cmdPath | grep "hello, it is a fast cgi application"
    CHECK_RESULT $? 0 0 "cgi-fcgi execute cmdFile command unsuccessfully"

    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    rm -rf fcgi2-2.4.2 2.4.2.tar.gz cmdFile
    LOG_INFO "End to restore the test environment."
}

main "$@"
