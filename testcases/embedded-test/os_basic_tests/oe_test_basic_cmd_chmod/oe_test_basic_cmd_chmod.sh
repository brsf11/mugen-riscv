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
# @Desc      :   File system common command test-chmod
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."

    test -d /tmp/test01 && rm -rf /tmp/test01
    mkdir -p /tmp/test01/test02/test03

    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."

    ls -l /tmp | grep "test01" | awk '{print $1}' | grep "drwxrwxrwx"
    CHECK_RESULT $? 1 0 "dir default mod is drwxrwxrwx"
    per01=$(ls -l /tmp/test01 | grep "test02" | awk '{print $1}')

    chmod 777 /tmp/test01
    ls -l /tmp | grep "test01" | awk '{print $1}' | grep "drwxrwxrwx"
    CHECK_RESULT $? 0 0 "after chmod check /tmp/test01 mod fail"
    per02=$(ls -l /tmp/test01 | grep "test02" | awk '{print $1}')
    [ "$per01" == "$per02" ]
    CHECK_RESULT $? 0 0 "check chmod only change one dir fail"

    chmod -R 777 /tmp/test01
    ls -l /tmp/ | grep "test01" | awk '{print $1}' | grep "drwxrwxrwx"
    CHECK_RESULT $? 0 0 "check chmod -R change test01 mod fail"
    ls -l /tmp/test01 | grep "test02" | awk '{print $1}' | grep "drwxrwxrwx"
    CHECK_RESULT $? 0 0 "check chmod -R change test02 mod fail"

    chmod --help 2>&1 | grep "Usage"
    CHECK_RESULT $? 0 0 "check chmod help fail"

    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."

    rm -rf /tmp/test01

    LOG_INFO "End to restore the test environment."
}

main $@
