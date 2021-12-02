#!/usr/bin/bash

# Copyright (c) 2021. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   doraemon2020
# @Contact   :   xcl_job@163.com
# @Date      :   2020-04-09
# @License   :   Mulan PSL v2
# @Desc      :   Process monitoring -iostat
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh
function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL sysstat
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    iostat
    CHECK_RESULT $?
    iostat -c | grep avg-cpu
    CHECK_RESULT $?
    iostat -d | grep Device
    CHECK_RESULT $?
    iostat -k | grep -E 'avg-cpu|Device'
    CHECK_RESULT $?
    iostat -p | grep Device | grep tps | grep kB_read
    CHECK_RESULT $?
    iostat --help 2>&1 | grep Usage
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}

main "$@"
