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
    DNF_INSTALL "kernel-tools bpftool perf"
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    lsgpio -h 2>&1 | grep "GPIO chip"
    CHECK_RESULT $?
    tmon -h | grep "Usage: tmon"
    CHECK_RESULT $?
    tmon -v | grep "TMON version"
    CHECK_RESULT $?
    tmon -d
    CHECK_RESULT $?
    bpftool version | grep bpftool
    CHECK_RESULT $?
    bpftool perf help 2>&1 | grep Usage
    CHECK_RESULT $?
    bpftool perf show
    CHECK_RESULT $?
    bpftool perf list
    CHECK_RESULT $?
    bpftool prog help 2>&1 | grep help
    CHECK_RESULT $?
    bpftool prog show --json id 3 2>&1 | grep error
    CHECK_RESULT $?
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the tet environment."
    DNF_REMOVE
    LOG_INFO "Finish to restore the tet environment."
}

main "$@"
