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
#@Desc      	:   Take the test clamscan
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the database config."

    DNF_INSTALL clamav
    mkdir /opt/testscan
    cd /opt/testscan/ && sigtool -u /var/lib/clamav/daily.cvd && cd -

    LOG_INFO "End to prepare the database config."
}

function run_test() {
    LOG_INFO "Start to run test."

    clamscan --version | grep "ClamAV"
    CHECK_RESULT $? 0 0 "Check clamscan version failed."
    clamscan --help
    CHECK_RESULT $? 0 0 "Check clamscan help failed."
    clamscan -a | grep "SCAN SUMMARY" >/dev/null
    CHECK_RESULT $? 0 0 "Check clamscan -a failed." >/dev/null
    clamscan -v | grep "SCAN SUMMARY" >/dev/null
    CHECK_RESULT $? 0 0 "Check clamscan -v failed." >/dev/null
    clamscan --debug >/dev/null
    CHECK_RESULT $? 0 0 "Check clamscan --debug failed." >/dev/null
    clamscan --quiet --stdout
    CHECK_RESULT $? 0 0 "Check clamscan --quiet --stdout failed." >/dev/null
    clamscan --no-summary >/dev/null
    CHECK_RESULT $? 0 0 "Check clamscan --no-summary failed." >/dev/null
    clamscan -i /opt/testscan/daily.cbd | grep "SCAN SUMMARY" >/dev/null
    CHECK_RESULT $? 0 0 "Check clamscan -i failed." >/dev/null
    clamscan --bell | grep "SCAN SUMMARY" >/dev/null
    CHECK_RESULT $? 0 0 "Check clamscan --bell failed." >/dev/null
    clamscan -r | grep "SCAN SUMMARY" >/dev/null
    CHECK_RESULT $? 0 0 "Check clamscan -r failed." >/dev/null
    clamscan -o /opt/testscan/daily.cbd | grep "SCAN SUMMARY" >/dev/null
    CHECK_RESULT $? 0 0 "Check clamscan -o failed." >/dev/null

    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."

    rm -rf /opt/testscan
    DNF_REMOVE

    LOG_INFO "End to restore the test environment."
}

main "$@"
