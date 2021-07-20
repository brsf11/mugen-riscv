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
function config_params() {
    LOG_INFO "This test case has no config params to load!"
}

function pre_test() {
    LOG_INFO "This test case does not require environment preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    ls test1 || touch test1
    ls /home/test1 && rm -rf /home/test1
    cp test1 /home
    ls /home/test1
    CHECK_RESULT $?

    ls test2/test3 || mkdir -p test2/test3
    ls /home/test2 && rm -rf /home/test2
    cp -r test2 /home
    ls /home/test2
    CHECK_RESULT $?

    cp --help | grep "Usage"
    CHECK_RESULT $?
    ls /home/test4 && rm -rf /home/test4
    cp -s test1 test4
    CHECK_RESULT $?
    ls -l test4 | grep "test4 -> test1"
    CHECK_RESULT $?
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    rm -rf test1 test2 /home/test1 /home/test2 test4
    LOG_INFO "Finish environment cleanup!"
}

main $@
