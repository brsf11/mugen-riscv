#!/usr/bin/bash

# Copyright (c) 2023. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.
####################################
#@Author        :   dingjiao
#@Contact       :   15829797643@163.com
#@Date          :   2022-07-04
#@License       :   Mulan PSL v2
#@Desc          :   Check the number of packets sent by mtr
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL mtr
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    mtr -6 -r -c 15 -s 128 -n $(hostname) | awk 'NR==3{print $4}' | grep 15
    CHECK_RESULT $? 0 0 "Check the number of packets sent per second 15: failed!"
    mtr -h | grep "Usage"
    CHECK_RESULT $? 0 0 "Check mtr -h: failed!"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF REMOVE 
    LOG_INFO "End to restore the test environment."
}

main "$@"
