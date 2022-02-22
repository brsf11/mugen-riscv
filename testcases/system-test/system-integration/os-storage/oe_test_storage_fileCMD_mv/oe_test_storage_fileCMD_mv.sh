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
# @Date      :   2020-04-10
# @License   :   Mulan PSL v2
# @Desc      :   File system common command test-mv
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh
function pre_test() {
    LOG_INFO "Start environment preparation."
    mkdir test1
    mv test1 /home
    LOG_INFO "Environmental preparation is over."
}

function run_test() {
    LOG_INFO "Start executing testcase!"
    test -d /home/test1
    CHECK_RESULT $?
    mv /home/test1 /home/haha
    CHECK_RESULT $?
    test -d /home/haha
    CHECK_RESULT $?
    rm -rf /home/haha
    test -d /tmp/haha || mkdir /tmp/haha 
    CHECK_RESULT $?
    mv -f /tmp/haha /home
    CHECK_RESULT $?
    test -d /tmp/haha
    CHECK_RESULT $? 1
    test -d /home/haha
    CHECK_RESULT $?
    mv --help | grep "Usage"
    CHECK_RESULT $?
    LOG_INFO "End of testcase execution!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    rm -rf /home/haha
    LOG_INFO "Finish environment cleanup."
}

main $@
