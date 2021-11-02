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
# @Date      :   2021-10-29
# @License   :   Mulan PSL v2
# @Desc      :   Rust language tools rustfmt
# ##############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment!"
    DNF_INSTALL "rustfmt rls"
    cp ../common/* ./
    LOG_INFO "End to prepare the test environment!"
}

function run_test() {
    LOG_INFO "Start executing testcase!"
    cargo-fmt -h | grep "USAGE"
    CHECK_RESULT $? 0 0 "cargo-fmt Help information printing failed"
    rustfmt --check hello.rs | grep "Diff in"
    CHECK_RESULT $? 0 0 "Check the failure"
    rustfmt --backup test.rs && test -f test.bk
    CHECK_RESULT $? 0 0 "Check the failure"
    rustfmt --edition 2018 hello.rs
    CHECK_RESULT $? 0 0 "Failed to set the 2018 version"
    rustfmt -h | grep "usage"
    CHECK_RESULT $? 0 0 "rustfmt Help information printing failed"
    rustfmt --print-config default testDir && test -f testDir
    CHECK_RESULT $? 0 0 "Default configuration failed"
    rustfmt --color auto hello.rs
    CHECK_RESULT $? 0 0 "Color setting failed"
    rustfmt -V | grep -E "[0-9]"
    CHECK_RESULT $? 0 0 "Failed to output the version information of rustfmt"
    # RLS packages have only basic commands
    rls -h | grep "help"
    CHECK_RESULT $? 0 0 "Help information printing failed"
    rls -V | grep -E "[0-9]"
    CHECK_RESULT $? 0 0 "Failed to output the version information"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    DNF_REMOVE
    rm -rf ./*.rs test*
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
