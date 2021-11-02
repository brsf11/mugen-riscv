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
# @Date      :   2021-10-28
# @License   :   Mulan PSL v2
# @Desc      :   Rust language tools clippy
# ##############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment!"
    DNF_INSTALL clippy
    cp ../common/test.rs test.rs
    LOG_INFO "End to prepare the test environment!"
}

function run_test() {
    LOG_INFO "Start executing testcase!"
    cargo-clippy -h | grep "Usage"
    CHECK_RESULT $? 0 0 "Help information printing failed"
    cargo-clippy -V | grep -E "[0-9]"
    CHECK_RESULT $? 0 0 "Failed to output the version information"
    cargo new hello_world && cd hello_world || exit 1
    cargo check 2>&1 | grep "Finished"
    CHECK_RESULT $? 0 0 "Failure check"
    cargo-clippy -W 2>&1 | grep "Finished"
    CHECK_RESULT $? 0 0 "Failed setup warning"
    cargo-clippy -A 2>&1 | grep "Finished"
    CHECK_RESULT $? 0 0 "Failed setup Allow"
    cargo-clippy -D 2>&1 | grep "Finished"
    CHECK_RESULT $? 0 0 "Failed setup Deny"
    cargo-clippy -F 2>&1 | grep "Finished"
    CHECK_RESULT $? 0 0 "Failed setup Forbit"
    clippy-driver -h | grep "Usage"
    CHECK_RESULT $? 0 0 "Help information printing failed"
    clippy-driver -V | grep -E "[0-9]"
    CHECK_RESULT $? 0 0 "Failed to output the version information"
    cd ../ && clippy-driver --rustc test.rs
    ./test || grep "Hello, world!"
    CHECK_RESULT $? 0 0 "Failed to pass parameters"
    clippy-driver test.rs -W missing-docs 2>&1 | grep "warning"
    CHECK_RESULT $? 0 0 "Failed to set Linter option Allow"
    clippy-driver test.rs -A missing-docs -o hello_A
    ./hello_A | grep "Hello, world!"
    CHECK_RESULT $? 0 0 "Failed to set Linter option Allow"
    clippy-driver test.rs -D missing-docs 2>&1 | grep "error"
    CHECK_RESULT $? 0 0 "Failed to set Linter option Deny"
    clippy-driver test.rs -F missing-docs 2>&1 | grep "error"
    CHECK_RESULT $? 0 0 "Failed to set Linter option Forbit"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    DNF_REMOVE
    rm -rf ./test* hello*
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
