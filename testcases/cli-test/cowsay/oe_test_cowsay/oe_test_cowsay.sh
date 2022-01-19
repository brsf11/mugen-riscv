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
# @Author    :   suhang
# @Contact   :   suhangself@163.com
# @Date      :   2022-01-05
# @License   :   Mulan PSL v2
# @Desc      :   Display character tool cowsay
# #############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment!"
    DNF_INSTALL cowsay
    LOG_INFO "End to prepare the test environment!"
}

function run_test() {
    LOG_INFO "Start to run test."
    cowsay -h 2>&1 | grep "Usage"
    CHECK_RESULT $? 0 0 "Help information printing failed"
    cowsay -l | grep "Cow files"
    CHECK_RESULT $? 0 0 "Failed to list COW file"
    cowsay -bdgpstwy hello | grep -E "hello|\.|U"
    CHECK_RESULT $? 0 0 "Parameter -bdgpstwy failed to be set"
    cowsay -e @@ hello | grep -E "hello|@"
    CHECK_RESULT $? 0 0 "Parameter -e failed to be set"
    cowsay -f cheese hello | grep -E "hello|\*"
    CHECK_RESULT $? 0 0 "Parameter -f failed to be set"
    cowsay -T @@ hello | grep -E "hello|@"
    CHECK_RESULT $? 0 0 "Parameter -T failed to be set"
    cowthink hello | grep "hello"
    CHECK_RESULT $? 0 0 "Cowthink print failed"
    cowthink -l | grep "Cow files"
    CHECK_RESULT $? 0 0 "Failed to list COW file"
    animalsay hello | grep "hello"
    CHECK_RESULT $? 0 0 "Animalsay print failed"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
