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
# @Date      :   2021-09-22
# @License   :   Mulan PSL v2
# @Desc      :   Rust language tools rustc
# ##############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment!"
    DNF_INSTALL rust
    cp ../common/* ./
    LOG_INFO "End to prepare the test environment!"
}

function run_test() {
    LOG_INFO "Start to run test."
    rustc lib.rs --crate-type=lib -D missing-docs 2>&1 |grep "error"
    CHECK_RESULT $? 0 0 "Failed to set Linter option Deny"
    rustc lib.rs --crate-type=lib -F missing-docs 2>&1 |grep "error"
    CHECK_RESULT $? 0 0 "Failed to set Linter option Forbit"
    rustc war.rs --cap-lints warn 2>&1 |grep "warning"
    CHECK_RESULT $? 0 0 "Failed to set Linter level warning"
    rustc -C opt-level=2 hello.rs -o hello_C && test -f "hello_C"
    CHECK_RESULT $? 0 0 "Failed to output the hello_C file"
    rustc -V | grep -E "[0-9]"
    CHECK_RESULT $? 0 0 "Failed to output the version information"
    rustc -v hello.rs -o hello_v && test -f "hello_v"
    CHECK_RESULT $? 0 0 "Failed to output the hello_v file"
    rustc -C help | grep "Available codegen options"
    CHECK_RESULT $? 0 0 "-C help printing fails"
    rustc -W help | grep "Available lint options"
    CHECK_RESULT $? 0 0 "-W help printing fails"
    rustc --crate-type staticlib myhello.rs
    CHECK_RESULT $?
    rustc --crate-type rlib myhello.rs
    CHECK_RESULT $?
    rustc -L. -l myhello main.rs
    CHECK_RESULT $?
    ./main | grep "Hello World!"
    CHECK_RESULT $? 0 0 "Link library failed"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    rm -rf ./*.rs hello* lib* main war
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
