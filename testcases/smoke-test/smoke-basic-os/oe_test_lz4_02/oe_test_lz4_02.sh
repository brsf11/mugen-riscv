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
# @Date      :   2022/06/14
# @License   :   Mulan PSL v2
# @Desc      :   Test repeated compression
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    dd if=/dev/zero of=big_file count=10 bs=1M
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    lz4 -z big_file big_file.lz4
    CHECK_RESULT $? 0 0 "Failed to execute lz4 -z"
    test -f big_file.lz4
    CHECK_RESULT $? 0 0 "Failed to find file"
    lz4 -f big_file big_file.lz4 2>&1 | grep Compressed
    CHECK_RESULT $? 0 0 "Failed to execute lz4 -f"
    lz4 -f big_file big_file.lz4 2>&1 | grep "already exists"
    CHECK_RESULT $? 0 1 "Succeed to force repeat compress"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf big_file*
    LOG_INFO "End to restore the test environment."
}

main "$@"
