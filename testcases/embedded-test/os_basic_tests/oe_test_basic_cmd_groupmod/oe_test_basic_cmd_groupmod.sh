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
# @Desc      :   Modity User Group test
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."

    grep -w testuser1 /etc/passwd && userdel -r /home/testuser1
    grep -w testgroup1 /etc/group && groupdel testgroup1
    useradd testuser1
    groupadd testgroup1
    groupmod -g 6666 testgroup1

    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."

    grep -w testgroup1 /etc/group | grep 6666
    CHECK_RESULT $? 0 0 "check testgroup1 fail"
    groupmod -g 8888 testgroup1
    CHECK_RESULT $? 0 0 "run groupmod -g 8888 testgroup1 fail"
    grep -w testgroup1 /etc/group | grep 8888
    CHECK_RESULT $? 0 0 "check mod testgroup1 fail"

    groupmod -n testgroup2 testgroup1
    CHECK_RESULT $? 0 0 "run groupmod -n fail"
    grep -w testgroup2 /etc/group | grep 8888
    CHECK_RESULT $? 0 0 "check testgroup2 fail"

    grep -w testgroup1 /etc/group
    CHECK_RESULT $? 1 0 "check testgroup1 fail"

    usermod -a -G testgroup2 testuser1
    CHECK_RESULT $? 0 0 "run usermod -a -G fail"
    grep -w testgroup2 /etc/group | grep testuser1
    CHECK_RESULT $? 0 0 "check testgroup2 fail"

    groupmod --help 2>&1 | grep Usage
    CHECK_RESULT $? 0 0 "check groupmod help fail"

    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."

    groupdel testgroup2
    userdel -r testuser1

    LOG_INFO "End to restore the test environment."
}

main $@
