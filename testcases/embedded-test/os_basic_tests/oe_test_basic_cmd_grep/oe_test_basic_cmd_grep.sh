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

function run_test() {
    LOG_INFO "Start to run test."

    grep -c id /proc/cpuinfo
    CHECK_RESULT $? 0 0 "check grep -c fail"
    grep -n id /proc/cpuinfo
    CHECK_RESULT $? 0 0 "check grep -n fail"

    ps -aux | grep auditd
    CHECK_RESULT $? 0 0 "check grep whih | fail "

    ls /tmp/test && rm -rf /tmp/test
    echo 'abc' >/tmp/test
    grep -i 'A' /tmp/test
    CHECK_RESULT $? 0 0 "check grep -i fail"

    grep -v 'A' /tmp/test
    CHECK_RESULT $? 0 0 "check grep -v fail"

    grep -r 'ssh_config' /etc/ssh
    CHECK_RESULT $? 0 0 "check grep -r fail"

    grep --help 2>&1 | grep "Usage"
    CHECK_RESULT $? 0 0 "check grep help fail"

    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."

    rm -rf /tmp/test

    LOG_INFO "End to restore the test environment."
}

main $@
