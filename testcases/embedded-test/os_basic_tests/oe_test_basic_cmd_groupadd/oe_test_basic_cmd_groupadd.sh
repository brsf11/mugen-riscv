#!/usr/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   xuchunlin
# @Contact   :   xcl_job@163.com
# @Date      :   2020-04-09
# @License   :   Mulan PSL v2
# @Desc      :   Create User Group test
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."

    grep "testgroup:" /etc/group && groupdel testgroup
    grep "testgroup1:" /etc/group && groupdel testgroup1
    grep "testgroup2:" /etc/group && groupdel testgroup2

    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."

    groupadd testgroup
    CHECK_RESULT $? 0 0 "run groupadd testgroup fail"
    grep -w testgroup /etc/group
    CHECK_RESULT $? 0 0 "check groupadd testgroup fail"

    groupadd -g 6666 testgroup1
    CHECK_RESULT $? 0 0 "run groupadd -g 6666 testgroup1 fail"
    grep -w testgroup1 /etc/group | grep 6666
    CHECK_RESULT $? 0 0 "check testgroup1 fail"

    groupadd -g 9999 -o testgroup2
    CHECK_RESULT $? 0 0 "run groupadd -g 9999 -o testgroup2 fail"
    grep -w testgroup2 /etc/group | grep 9999
    CHECK_RESULT $? 0 0 "check testgroup2 fail"

    groupadd --help 2>&1 | grep 'Usage: groupadd'
    CHECK_RESULT $? 0 0 "check groupadd help fail"

    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."

    groupdel testgroup
    groupdel testgroup1
    groupdel testgroup2

    LOG_INFO "End to restore the test environment."
}

main $@
