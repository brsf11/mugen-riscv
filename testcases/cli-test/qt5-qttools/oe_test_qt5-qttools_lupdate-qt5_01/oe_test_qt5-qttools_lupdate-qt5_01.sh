#!/usr/bin/bash

# Copyright (c) 2021. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.
# #############################################
# @Author    :   liujingjing
# @Contact   :   liujingjing25812@163.com
# @Date      :   2020/11/19
# @License   :   Mulan PSL v2
# @Desc      :   The usage of commands in qt5-linguist binary package
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL "qt5-qttools qt5-linguist qt5-qtbase-devel"
    qt5_version=$(rpm -qa qt5-qttools | awk -F '-' '{print $3}')
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    lupdate-qt5 -help | grep -E "lupdate|help"
    CHECK_RESULT $?
    lupdate-qt5 -no-obsolete ../hello.pro -ts hello.ts
    CHECK_RESULT $?
    grep "obsolete" hello.ts
    CHECK_RESULT $? 0 1
    lupdate-qt5 -extensions ../hello.cpp -pro ../hello.pro -ts hello.ts | grep "Updating"
    CHECK_RESULT $?
    lupdate-qt5 -pluralonly ../hello.pro -ts hello.ts | grep "plural"
    CHECK_RESULT $?
    lupdate-qt5 -silent ../hello.pro -ts hello.ts | grep "Updating"
    CHECK_RESULT $? 1
    lupdate-qt5 -no-sort ../hello.pro -ts hello.ts
    CHECK_RESULT $?
    grep -E "click me|click button" hello.ts
    CHECK_RESULT $?
    mkdir -p dir/dir
    cp ../hello.cpp dir/dir/
    lupdate-qt5 -no-recursive dir -ts hello.ts | grep "0 new and 0 already"
    CHECK_RESULT $?
    grep -E "context|Widget|click" hello.ts
    CHECK_RESULT $? 1
    lupdate-qt5 -recursive dir -ts hello.ts | grep "3 new and 0 already"
    CHECK_RESULT $?
    grep -E "context|Widget|click" hello.ts
    CHECK_RESULT $?
    lupdate-qt5 -I../ ../ -ts hello.ts | grep "Scanning directory"
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    rm -rf hello.ts dir
    LOG_INFO "End to restore the test environment."
}

main "$@"
