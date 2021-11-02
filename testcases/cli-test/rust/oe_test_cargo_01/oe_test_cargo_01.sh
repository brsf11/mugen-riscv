#!/usr/bin/bash

# Copyright (c) 2021 Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# ##############################################
# @Author    :   suhang
# @Contact   :   suhangself@163.com
# @Date      :   2021-10-18
# @License   :   Mulan PSL v2
# @Desc      :   Rust language tools cargo
# ##############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment!"
    DNF_INSTALL cargo
    LOG_INFO "End to prepare the test environment!"
}

function run_test() {
    LOG_INFO "Start executing testcase!"
    cargo -h | grep "USAGE"
    CHECK_RESULT $? 0 0 "Help information printing failed"
    cargo -V | grep -E "[0-9]"
    CHECK_RESULT $? 0 0 "Failed to output the version information"
    cargo --list | grep "Installed Commands"
    CHECK_RESULT $? 0 0 "Failed to list commands"
    cargo --explain E0004 | grep "Erroneous code example"
    CHECK_RESULT $? 0 0 "Failed to interpret code command"
    cargo -vV | grep -E "release|[0-9]"
    CHECK_RESULT $? 0 0 "Failed to list details"
    cargo new hello -q
    CHECK_RESULT $? 0 0 "Silent output failure"
    cd hello || exit 1
    cargo run --color always
    CHECK_RESULT $? 0 0 "Color setting failed"
    cargo run --offline | grep "Hello, world!"
    CHECK_RESULT $? 0 0 "Failed to run offline"
    cargo -Z help | grep "Available unstable (nightly-only) flags"
    CHECK_RESULT $? 0 0 "Help printing failed"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    rm -rf ../hello*
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
