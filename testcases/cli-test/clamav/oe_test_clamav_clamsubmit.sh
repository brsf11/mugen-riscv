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
#@Desc      	:   Take the test clamsubmit & clamav-config
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the database config."

    DNF_INSTALL "clamav clamav-devel"

    LOG_INFO "End to prepare the database config."
}

function run_test() {
    LOG_INFO "Start to run test."

    # test clamsubmit
    clamsubmit -N bubble -n file
    CHECK_RESULT $? 0 0 "Set clamsubmit name failed."
    clamsubmit -e 244349477@qq.com -n file
    CHECK_RESULT $? 0 0 "Set clamsubmit email failed."
    clamsubmit -V -p file
    CHECK_RESULT $? 0 0 "Check virush failed."
    clamsubmit --version
    CHECK_RESULT $? 0 0 "Check clamsubmit version failed."
    clamsubmit --help
    CHECK_RESULT $? 0 0 "Check clamsubmit help message failed."

    # test clamav-config
    clamav-config --version
    CHECK_RESULT $? 0 0 "Check clambc help message failed."
    clamav-config --help
    CHECK_RESULT $? 0 0 "Check clambc help message failed."
    clamav-config --libs
    CHECK_RESULT $? 0 0 "Check clambc help message failed."
    clamav-config --cflags
    CHECK_RESULT $? 0 0 "Check clambc help message failed."
    clamav-config --prefix | grep "/usr"
    CHECK_RESULT $? 0 0 "Check clambc help message failed."

    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."

    DNF_REMOVE

    LOG_INFO "End to restore the test environment."
}

main "$@"
