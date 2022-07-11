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
    cargo new hello_world
    CHECK_RESULT $?
    test -d "hello_world"
    CHECK_RESULT $? 0 0 "Failed to create a new package"
    cd hello_world && cargo build
    CHECK_RESULT $?
    ./target/debug/hello_world | grep "Hello, world!"
    CHECK_RESULT $? 0 0 "Failed to compile package"
    cargo run | grep "Hello, world!"
    CHECK_RESULT $? 0 0 "Failed to run package"
    cargo test | grep -E "running|test result"
    CHECK_RESULT $? 0 0 "Failed to execute tests"
    cargo bench | grep -E "running|test result"
    CHECK_RESULT $? 0 0 "Failed to execute the benchmark"
    cargo check
    CHECK_RESULT $? 0 0 "Failure check kit"
    cargo doc && test -d target/doc
    CHECK_RESULT $? 0 0 "Failed to build the package document"
    cargo clean && test -d target
    CHECK_RESULT $? 1 0 "Failed to delete a file"
    mkdir INI && cd INI || exit 1
    cargo init && test -d src
    CHECK_RESULT $? 0 0 "Failed to create a new package"
    cargo update && test -f Cargo.lock
    CHECK_RESULT $? 0 0 "Failed to update file"
    https_code=$(curl -s -w '%{http_code}' https://github.com/rust-lang/crates.io-index -o /dev/null)
    SLEEP_WAIT 3
    if [ ${https_code} == "200" ]; then
        cargo search && cargo search serde | grep "serde"
        CHECK_RESULT $? 0 0 "Failed to search for serde package"
    fi
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    rm -rf ../../hello_world*
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
