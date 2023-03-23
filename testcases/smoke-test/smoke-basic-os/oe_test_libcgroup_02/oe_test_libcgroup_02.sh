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
# @Author    :   liujingjing
# @Contact   :   liujingjing25812@163.com
# @Date      :   2022/06/13
# @License   :   Mulan PSL v2
# @Desc      :   Test cgget and cgset
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL libcgroup
    cgcreate -g cpu:test
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    cgget -g cpu:test | grep -A 10 test | grep cpu
    CHECK_RESULT $? 0 0 "Failed to execute cgget"
    cgset -r cpu.shares=2048 test
    CHECK_RESULT $? 0 0 "Failed to execute cgset"
    cgget -g cpu:test | grep "cpu.shares: 2048"
    CHECK_RESULT $? 0 0 "Failed to display cpu.shares"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    cgdelete -g cpu:test
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}

main "$@"
