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
# @Desc      :   File system common command test-grep
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
    grep -c id /proc/cpuinfo
    CHECK_RESULT $?
    grep -n id /proc/cpuinfo
    CHECK_RESULT $?

    ps -aux | grep auditd
    CHECK_RESULT $?

    grep --help | grep "Usage"
    CHECK_RESULT $?

    ls /tmp/test && rm -rf /tmp/test
    echo 'abc' >/tmp/test
    grep -i 'A' /tmp/test
    CHECK_RESULT $?
    grep -v 'A' /tmp/test
    CHECK_RESULT $?
    grep -r 'ssh_config' /etc/ssh
    CHECK_RESULT $?
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    rm -rf /tmp/test
    export LANG=${OLD_LANG}
    LOG_INFO "Finish environment cleanup!"
}

main $@
