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
# @Desc      :   File system common command test-mkdir
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environment preparation."
    test -d /tmp/test1 && rm -rf /tmp/test1
    test -d /tmp/test2 && rm -rf /tmp/test2
    test -d /tmp/test3 && rm -rf /tmp/test3
    test -d /tmp/test5 && rm -rf /tmp/test5
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    mkdir /tmp/test1 /tmp/test2
    test -d /tmp/test1 && test -d /tmp/test2
    CHECK_RESULT $?

    mkdir -p /tmp/test3/test4
    test -d /tmp/test3/test4
    CHECK_RESULT $?

    mkdir -m 777 /tmp/test5
    ls -l /tmp | grep test5 | grep "drwxrwxrwx"
    CHECK_RESULT $?

    mkdir --help | grep "Usage"
    CHECK_RESULT $?
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    rm -rf /tmp/test*
    LOG_INFO "Finish environment cleanup!"
}

main $@
