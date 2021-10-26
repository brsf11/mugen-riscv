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
    cp ../common/lib.rs lib.rs
    cp ../common/war.rs war.rs
    cp ../common/hello.rs hello.rs
    cp ../common/myhello.rs myhello.rs
    cp ../common/main.rs main.rs
    LOG_INFO "End to prepare the test environment!"
}

function run_test() {
    LOG_INFO "Start to run test."
    rustc lib.rs --crate-type=lib -D missing-docs >Dlog 2>&1
    CHECK_RESULT $? 1
    grep "error" Dlog
    CHECK_RESULT $? 0 0 "Failed to set Linter option Deny"
    rustc lib.rs --crate-type=lib -F missing-docs >Flog 2>&1
    CHECK_RESULT $? 1
    grep "error" Flog 
    CHECK_RESULT $? 0 0 "Failed to set Linter option Forbit"
    rustc war.rs --cap-lints warn >caplog 2>&1
    CHECK_RESULT $?
    grep "warning" caplog 
    CHECK_RESULT $? 0 0 "Failed to set Linter level warning"
    rustc -C opt-level=2 hello.rs -o hello_C
    CHECK_RESULT $?
    ls |grep "hello_C" 
    CHECK_RESULT $? 0 0 "Failed to output the hello_C file"
    rustc -V |grep "rustc" 
    CHECK_RESULT $? 0 0 "Failed to output the version information"
    rustc -v hello.rs -o hello_v
    CHECK_RESULT $?
    ls |grep "hello_v" 
    CHECK_RESULT $? 0 0 "Failed to output the hello_v file"
    rustc -C help |grep "Available codegen options" 
    CHECK_RESULT $?
    rustc -W help |grep "Available lint options" 
    CHECK_RESULT $?
    rustc --crate-type staticlib myhello.rs
    CHECK_RESULT $?
    rustc --crate-type rlib myhello.rs
    CHECK_RESULT $?
    rustc -L. -l myhello main.rs
    CHECK_RESULT $?
    ./main |grep "Hello World!" 
    CHECK_RESULT $? 0 0 "Link library failed"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    rm -rf $(ls | grep -v ".sh")
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup!"
}

main $@