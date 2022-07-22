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
# @Desc      :   File system common command test-cp
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    OLD_LANG=$LANG
    export LANG=en_US.UTF-8
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start testing..."
    ls test1 || touch test1
    ls /tmp/test1 && rm -rf /tmp/test1
    cp test1 /tmp
    ls /tmp/test1
    CHECK_RESULT $?

    ls test2/test3 || mkdir -p test2/test3
    ls /tmp/test2 && rm -rf /tmp/test2
    cp -r test2 /tmp
    ls /tmp/test2
    CHECK_RESULT $?

    cp --help | grep "Usage"
    CHECK_RESULT $?
    ls /tmp/test4 && rm -rf /tmp/test4
    cp -s test1 test4
    CHECK_RESULT $?
    ls -l test4 | grep "test4 -> test1"
    CHECK_RESULT $?
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    export LANG=${OLD_LANG}
    rm -rf test1 test2 /tmp/test1 /tmp/test2 test4
    LOG_INFO "Finish environment cleanup!"
}

main $@
