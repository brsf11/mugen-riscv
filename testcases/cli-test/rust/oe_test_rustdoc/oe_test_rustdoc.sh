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
# @Desc      :   Rust language tools rustdoc
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
    rustdoc -h | grep "Options"
    CHECK_RESULT $? 0 0 "Help information printing failed"
    rustdoc -V | grep -E "[0-9]"
    CHECK_RESULT $? 0 0 "Failed to output the version information"
    rustdoc -v -V | grep -E "release|version|[0-9]"
    CHECK_RESULT $?
    rustdoc test.rs -o doc --crate-name mycrate
    CHECK_RESULT $?
    test -d doc/mycrate
    CHECK_RESULT $? 0 0 "Failed to specify the output path"
    rustdoc test.rs -L doc/
    CHECK_RESULT $?
    rustdoc hello.rs --cfg hello
    test -d doc/hello
    CHECK_RESULT $? 0 0 "Failed to pass configuration parameters"
    rustdoc test.rs --extern doc/
    CHECK_RESULT $?
    rustdoc test.rs -C target_feature=+avx
    CHECK_RESULT $?
    rustdoc --document-private-items test.rs
    CHECK_RESULT $?
    rustdoc test.rs --test | grep -E "running|tests"
    CHECK_RESULT $? 0 0 "Failed to run the test code"
    rustdoc test.rs --html-in-header doc/hello/all.html
    CHECK_RESULT $?
    rustdoc test.rs --html-after-content doc/hello/all.html
    CHECK_RESULT $?
    rustdoc test.rs --html-after-content doc/hello/all.html
    CHECK_RESULT $?
    rustdoc test.rs --markdown-no-toc
    CHECK_RESULT $?
    rustdoc test.rs -e doc/dark.css
    CHECK_RESULT $?
    rustdoc lib.rs --crate-type=lib -W missing-docs 2>&1 | grep "warning"
    CHECK_RESULT $? 0 0 "Failed to set Linter option Warn"
    rustdoc lib.rs --crate-type=lib -A missing-docs -o hello_A
    test -d "hello_A"
    CHECK_RESULT $? 0 0 "Failed to set Linter option Allow"
    rustdoc lib.rs --crate-type=lib -D missing-docs 2>&1 | grep "error"
    CHECK_RESULT $? 0 0 "Failed to set Linter option Deny"
    rustdoc lib.rs --crate-type=lib -F missing-docs 2>&1 | grep "error"
    CHECK_RESULT $? 0 0 "Failed to set Linter option Forbit"
    rustdoc war.rs --cap-lints warn
    CHECK_RESULT $? 0 0 "Failed to set Linter level warning"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    rm -rf ./*.rs doc* hello*
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
