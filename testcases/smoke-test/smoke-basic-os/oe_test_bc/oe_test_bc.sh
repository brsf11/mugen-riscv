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
# @Date      :   2022/06/07
# @License   :   Mulan PSL v2
# @Desc      :   Test the basic functions of bc
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL bc
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    echo "1>0" | bc | grep 1
    CHECK_RESULT $? 0 0 "Failed calculations"
    echo "1<0" | bc | grep 0
    CHECK_RESULT $? 0 0 "Failed calculations"
    echo "1+1" | bc | grep 2
    CHECK_RESULT $? 0 0 "Failed calculations"
    echo "1-1" | bc | grep 0
    CHECK_RESULT $? 0 0 "Failed calculations"
    echo "1*1" | bc | grep 1
    CHECK_RESULT $? 0 0 "Failed calculations"
    echo "1/1" | bc | grep 1
    CHECK_RESULT $? 0 0 "Failed calculations"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}

main "$@"
