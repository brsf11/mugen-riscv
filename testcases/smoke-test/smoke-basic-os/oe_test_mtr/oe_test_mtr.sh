#!/usr/bin/bash

# Copyright (c) 2022 Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   dengailing
# @Contact   :   dengailing@uniontech.com
# @Date      :   2022-12-07
# @License   :   Mulan PSL v2
# @Desc      :   test mtr
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL mtr
    OLD_LANG=$LANG
    export LANG=en_US.UTF-8
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start testing..."
    mtr -v | grep 'mtr'
    CHECK_RESULT $? 0 0 "mtr -v fail"
    mtr -h | grep 'Usage:'
    CHECK_RESULT $? 0 0 "mtr -h fail"
    mtr -r dns.google | grep 'dns.google'
    CHECK_RESULT $? 0 0 "mtr -r dns fail"
    mtr -r -e | grep 'HOST'
    CHECK_RESULT $? 0 0 "mtr -e fail"
    mtr -r -u | grep 'HOST'
    CHECK_RESULT $? 0 0 "mtr -u fail"
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE 
    export LANG=${OLD_LANG}
    LOG_INFO "End to restore the test environment."
}

main "$@"
