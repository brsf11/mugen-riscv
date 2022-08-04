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
# @Desc      :   File system common command test-dd
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function run_test() {
    LOG_INFO "Start to run test."

    dd if=/dev/zero of=test bs=1M count=100
    CHECK_RESULT $? 0 0 "run dd if=/dev/zero fail"
    ls -l test | grep "104857600"
    CHECK_RESULT $? 0 0 "run dd test size fail"

    ls file && rm -rf file
    echo "test" >file
    dd if=file of=test1 bs=1M count=100
    CHECK_RESULT $? 0 0 "run dd if=file fail"

    dd --help 2>&1 | grep "Usage"
    CHECK_RESULT $? 0 0 "check dd help fail"

    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."

    rm -f test test1 file

    LOG_INFO "End to restore the test environment."
}

main $@
