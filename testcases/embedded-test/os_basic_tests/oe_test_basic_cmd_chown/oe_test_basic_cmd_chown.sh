#!/usr/bin/bash

# Copyright (c) 2021 Huawei Technologies Co.,Ltd.ALL rights reserved.
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
# @Date      :   2020-04-10
# @License   :   Mulan PSL v2
# @Desc      :   File system common command test-chown
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."

    grep "test:" /etc/passwd && userdel -rf test
    useradd test

    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."

    mkdir -p /tmp/tmp/tmp01

    [ $(ls -l /tmp/tmp | tail -n 1 | awk '{print $3}') == "root" ]
    CHECK_RESULT $? 0 0 "check /tmp/tmp own user fail"
    [ $(ls -l /tmp/tmp | tail -n 1 | awk '{print $4}') == "root" ]
    CHECK_RESULT $? 0 0 "check /tmp/tmp own group fail"

    chown -R test:test /tmp/tmp
    CHECK_RESULT $? 0 0 "run chown fail"

    own_user02=$(ls -l /tmp/tmp | tail -n 1 | awk '{print $3}')
    own_group02=$(ls -l /tmp/tmp | tail -n 1 | awk '{print $4}')
    [ "$own_user02" == "test" ]
    CHECK_RESULT $? 0 0 "after chmod check /tmp/tmp own user fail"
    [ "$own_group02" == "test" ]
    CHECK_RESULT $? 0 0 "after chmod check /tmp/tmp own group fail"

    chown --help 2>&1 | grep "Usage"
    CHECK_RESULT $? 0 0 "check chown help fail"

    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."

    rm -rf /tmp/tmp
    userdel -rf test

    LOG_INFO "End to restore the test environment."
}

main $@
