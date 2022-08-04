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
# @Desc      :   File system common command test-rmdir
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."

    ls /tmp/test1 && rm -rf /tmp/test1

    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."

    mkdir /tmp/test1
    rmdir /tmp/test1 && ls /tmp/test1
    CHECK_RESULT $? 0 1 "rmdir test1 fail"

    mkdir -p /tmp/test1/test2
    rmdir -p /tmp/test1/test2 && ls /tmp/test1
    CHECK_RESULT $? 0 1 "rmdir -p test1 fail"

    rmdir --help 2>&1 | grep "Usage"
    CHECK_RESULT $? 0 0 "check rmdir help fail"

    LOG_INFO "End to run test."
}

main $@
