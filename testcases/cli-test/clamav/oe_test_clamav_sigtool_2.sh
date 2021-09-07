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
#@Desc      	:   Take the test sigtool normalise
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the database config."

    DNF_INSTALL clamav
    cp /var/lib/clamav/bytecode.cvd /opt
    cp /var/lib/clamav/main.cvd ./
    echo "test" > testfile

    LOG_INFO "End to prepare the database config."
}

function run_test() {
    LOG_INFO "Start to run test."

    # test sigtool normalise
    sigtool --html-normalise=/opt/bytecode.cvd --quiet && test -f nocomment.html
    CHECK_RESULT $? 0 0 "Set --html-normalise failed."
    sigtool --ascii-normalise=/opt/bytecode.cvd && test -f normalised_text
    CHECK_RESULT $? 0 0 "Set --ascii-normalise failed."
    sigtool --utf16-decode=/opt/bytecode.cvd && test -f /opt/bytecode.cvd.ascii
    CHECK_RESULT $? 0 0 "Set --utf16-decode failed."
    sigtool --vba=testfile
    CHECK_RESULT $? 0 0 "Set --vba failed."
    sigtool --vba-hex=testfile
    CHECK_RESULT $? 0 0 "Set --vba-hex failed."
    
    # test sigtool compare
    sigtool --compare /var/lib/clamav/main.cvd ./main.cvd >/dev/null
    CHECK_RESULT $? 0 0 "Check compare failed."
    sigtool --diff /var/lib/clamav/daily.cvd /var/lib/clamav/main.cvd 2>&1 | grep "ERROR: makediff"
    CHECK_RESULT $? 0 0 "Check diff failed."

    # test sigtool sig
    sigtool --mdb /var/lib/clamav/daily.cvd 
    CHECK_RESULT $? 0 0 "Set mdb failed."
    sigtool --imp /var/lib/clamav/daily.cvd
    CHECK_RESULT $? 0 0 "Set imp failed."

    sigtool --version
    CHECK_RESULT $? 0 0 "Check sigtool --version failed."
    sigtool -h
    CHECK_RESULT $? 0 0 "Check sigtool -h failed."

    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."

    rm -rf nocomment.html notags.html rfc2397 /opt/bytecode.cvd /opt/bytecode.cvd.ascii testfile normalised_text main.cvd
    DNF_REMOVE

    LOG_INFO "End to restore the test environment."
}

main "$@"
