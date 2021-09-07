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
#@Author    	:   meitingli
#@Contact   	:   244349477@qq.com
#@Date      	:   2021-08-03
#@License   	:   Mulan PSL v2
#@Desc      	:   Take the test sigtool info cmd
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the database config."

    DNF_INSTALL clamav
    mkdir testu testunpack
    cp /var/lib/clamav/main.cvd testu/
    cp /var/lib/clamav/main.cvd testunpack/

    LOG_INFO "End to prepare the database config."
}

function run_test() {
    LOG_INFO "Start to run test."

    # test sigtool --hex-dump 
    echo 2 | sigtool --hex-dump | grep "320a"
    CHECK_RESULT $? 0 0 "Check hex-dump 2 failed."
    echo 100 | sigtool --hex-dump --stdout | grep "3130300a"
    CHECK_RESULT $? 0 0 "Check hex-dump 100 failed."
    sigtool --md5 /var/lib/clamav/main.cvd | grep "main.cvd"
    CHECK_RESULT $? 0 0 "Check md5 failed."
    sigtool --sha1 /var/lib/clamav/main.cvd | grep "main.cvd"
    CHECK_RESULT $? 0 0 "Check sha1 failed."
    sigtool --sha256 /var/lib/clamav/main.cvd | grep "main.cvd"
    CHECK_RESULT $? 0 0 "Check sha256 failed."

    # test sigtool --info
    sigtool --info /var/lib/clamav/main.cvd | grep "Signatures"
    CHECK_RESULT $? 0 0 "Checkinfo failed."
    sigtool --info /var/lib/clamav/main.cvd --flevel 1 --cvd-version 1 --no-cdiff --unsigned --hybrid | grep "Signatures"
    CHECK_RESULT $? 0 0 "Check info with flevel,cvd-version,no-cdiff,unsigned,hybrid failed."
    sigtool -i /var/lib/clamav/main.cvd | grep "Signatures"
    CHECK_RESULT $? 0 0 "Check sigtool -i failed."
    sigtool -i /var/lib/clamav/main.cvd --debug
    CHECK_RESULT $? 0 0 "Check sigtool -i --debug failed."

    # test sigtool -u
    cd testu/
    sigtool -u main.cvd && ls main.hsb
    CHECK_RESULT $? 0 0 "Execute sigtool -u cmd failed."
    cd ../testunpack/
    sigtool --unpack /var/lib/clamav/main.cvd && ls main.hsb
    CHECK_RESULT $? 0 0 "Execute sigtool -unpack cmd failed."

    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."

    cd ../ && rm -rf testu testunpack
    DNF_REMOVE

    LOG_INFO "End to restore the test environment."
}

main "$@"
