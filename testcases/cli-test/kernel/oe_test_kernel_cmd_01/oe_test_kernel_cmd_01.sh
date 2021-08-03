#!/usr/bin/bash

# Copyright (c) 2021. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.
####################################
# @Author    :   zengcongwei
# @Contact   :   735811396@qq.com
# @Date      :   2021/01/19
# @License   :   Mulan PSL v2
# @Desc      :   Test kernel command
# ##################################
source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL "kernel-tools"
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    cpupower -h | grep "Usage" | grep "cpupower"
    CHECK_RESULT $?
    cpupower help | grep "Usage" | grep "cpupower"
    CHECK_RESULT $?
    cpupower frequency-info | grep "analyzing CPU 0"
    CHECK_RESULT $?
    if ! hostnamectl | grep Virtualization; then
        current_frequency=$(cpupower frequency-info | grep "current CPU frequency" | awk -F ": " '{print $2}' | awk '{print $1}')
        cpupower frequency-set -f 1.0GHz
        CHECK_RESULT $?
        cpupower frequency-info | grep "current CPU frequency" | grep "1000 MHz"
        CHECK_RESULT $?
        cpupower frequency-set -f "${current_frequency}"GHz
    fi
    cpupower idle-info | grep "analyzing CPU 0"
    CHECK_RESULT $?
    cpupower idle-set
    CHECK_RESULT $?
    cpupower info | grep "analyzing CPU 0"
    CHECK_RESULT $?
    gpio-event-mon -? 2>&1 | grep "Usage: gpio-event-mon"
    CHECK_RESULT $?
    gpio-hammer -? 2>&1 | grep "Usage: gpio-hammer"
    CHECK_RESULT $?
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the tet environment."
    DNF_REMOVE
    LOG_INFO "Finish to restore the tet environment."
}

main "$@"
