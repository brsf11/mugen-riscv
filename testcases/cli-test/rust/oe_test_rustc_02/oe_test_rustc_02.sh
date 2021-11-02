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
    rustc --print crate-name hello.rs | grep "hello"
    CHECK_RESULT $? 0 0 "Failed to output the hello file"
    rustc --print file-names hello.rs | grep "hello"
    CHECK_RESULT $? 0 0 "Failed to output the hello file"
    rustc --print sysroot hello.rs | grep "/usr"
    CHECK_RESULT $? 0 0 "Failed to output the sysroot information"
    rustc --print target-libdir hello.rs | grep "/usr/lib/rustlib"
    CHECK_RESULT $? 0 0 "Failed to output the target libdir"
    rustc --print cfg hello.rs | grep -E "debug|target|unix"
    CHECK_RESULT $? 0 0 "Failed to output the cfg information"
    rustc --print target-list hello.rs | grep -E ".*"
    CHECK_RESULT $? 0 0 "Failed to output the target list"
    rustc --print target-cpus hello.rs | grep "Target CPU"
    CHECK_RESULT $? 0 0 "Failed to output the target cpus"
    rustc --print target-features hello.rs | grep "features"
    CHECK_RESULT $? 0 0 "Failed to output the target features"
    rustc --print relocation-models hello.rs | grep "Available relocation models"
    CHECK_RESULT $? 0 0 "Failed to output the relocation models"
    rustc --print code-models hello.rs | grep "Available code models"
    CHECK_RESULT $? 0 0 "Failed to output the code models"
    rustc --print tls-models hello.rs | grep "Available TLS models"
    CHECK_RESULT $? 0 0 "Failed to output the stls models"
    rustc --print native-static-libs hello.rs --crate-name hello_print
    CHECK_RESULT $?
    test -f "hello_print"
    CHECK_RESULT $? 0 0 "Failed to output the priname file"
    rustc -g hello.rs -o hello_g
    CHECK_RESULT $?
    test -f "hello_g"
    CHECK_RESULT $? 0 0 "Failed to output the hello_g file"
    rustc -O hello.rs -o hello_O
    CHECK_RESULT $?
    test -f "hello_O"
    CHECK_RESULT $? 0 0 "Failed to output the hello_O file"
    rustc -o hello_o hello.rs
    CHECK_RESULT $?
    test -f "hello_o"
    CHECK_RESULT $? 0 0 "Failed to output the demo file"
    rustc --out-dir ./ hello.rs --crate-name hello_dir
    CHECK_RESULT $?
    test -f "hello_dir"
    CHECK_RESULT $? 0 0 "Failed to output the dirname file"
    rustc --explain E0426 | grep "Erroneous code example"
    CHECK_RESULT $?
    rustc --test hello.rs --crate-name hello_test
    CHECK_RESULT $?
    ./hello_test | grep "running"
    CHECK_RESULT $? 0 0 "Test tool build failed"
    rustc lib.rs --crate-type=lib -W missing-docs 2>&1 | grep "warning"
    CHECK_RESULT $? 0 0 "Failed to set Linter option Warn"
    rustc lib.rs --crate-type=lib -A missing-docs -o hello_A
    CHECK_RESULT $?
    test -f "hello_A"
    CHECK_RESULT $? 0 0 "Failed to set Linter option Allow"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    rm -rf ./*.rs ./*.rlib hello*
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
