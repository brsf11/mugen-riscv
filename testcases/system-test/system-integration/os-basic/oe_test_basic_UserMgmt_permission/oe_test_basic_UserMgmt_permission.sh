#!/usr/bin/bash

# Copyright (c) 2021. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   doraemon2020
# @Contact   :   xcl_job@163.com
# @Date      :   2020-04-09
# @License   :   Mulan PSL v2
# @Desc      :   Command test-who -b/-s
# ############################################
source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    id -u testuser1 || useradd testuser1
    LOG_INFO "End to prepare the test environment."
}
function run_test() {
    LOG_INFO "Start to run test."
    su - testuser1 -c "useradd test"
    CHECK_RESULT $? 1
    su - testuser1 -c "sudo useradd test"
    CHECK_RESULT $? 1
    id -u test || useradd test
    su - testuser1 -c "usermod -u 555 test"
    CHECK_RESULT $? 1

    usermod -u 666 test
    CHECK_RESULT $?
    grep "test:x:666" /etc/passwd
    CHECK_RESULT $?
    userdel -rf test
    CHECK_RESULT $?

    groupadd testgroup
    su - testuser1 -c "groupadd testgroup" | grep "Permission denied"
    CHECK_RESULT $? 1
    su - testuser1 -c "groupmod -g 555 testgroup" | grep "Permission denied"
    CHECK_RESULT $? 1

    grep "testgroup" /etc/group 
    CHECK_RESULT $?
    groupmod -g 555 testgroup
    CHECK_RESULT $?
    grep "testgroup:x:555" /etc/group
    CHECK_RESULT $?
    groupdel testgroup
    CHECK_RESULT $?
    grep "testgroup" /etc/group
    CHECK_RESULT $? 1
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "End to clean the test environment."
    userdel -rf testuser1
    LOG_INFO "End to clean the test environment."
}

main "$@"
