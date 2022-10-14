#!/usr/bin/bash

# Copyright (c) 2020. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# ##################################
# @Author    :   LiuZiyi
# @Contact   :   lavandejoey@outlook.com
# @Date      :   2022/4/29
# @Desc      :   Test "ifnames-2.13" command
# ##################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL autoconf213
    dir=$(pwd)
    cd common || exit
    # test_macro
    cp -r /usr/share/autoconf-2.13 test-macro
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    ifnames-2.13 --help 2>&1 | grep "Usage: ifnames"
    CHECK_RESULT $? 0 0 "Error: ifnames-2.13 --help run failed"
    ifnames-2.13 --h 2>&1 | grep "Usage: ifnames"
    CHECK_RESULT $? 0 0 "Error: ifnames-2.13 -h run failed"
    ifnames-2.13 --version 2>&1 | grep "Autoconf version"
    CHECK_RESULT $? 0 0 "Error: ifnames-2.13 --version run failed"
    ifnames-2.13 ./ifname_test* 2>&1 | grep -Pz "(?s)DEF_VAR_1.*DEF_VAR_2.*IFNDEF_VAR"
    CHECK_RESULT $? 0 0 "Error: ifnames-2.13 run failed"
    # [-m dir] [--macrodir=dir]
    ifnames-2.13 -m test-macro ifname_test* 2>&1 | grep -Pz "(?s)DEF_VAR_1.*DEF_VAR_2.*IFNDEF_VAR"
    CHECK_RESULT $? 0 0 "Error: ifnames-2.13 run failed"
    ifnames-2.13 --macrodir=test-macro ifname_test* 2>&1 | grep -Pz "(?s)DEF_VAR_1.*DEF_VAR_2.*IFNDEF_VAR"
    CHECK_RESULT $? 0 0 "Error: ifnames-2.13  run failed"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf test-macro
    cd "$dir" || exit
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}

main "$@"
