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
    lupdate-qt5 -locations absolute ../hello.cpp -ts hello.ts
    CHECK_RESULT $?
    grep "location" hello.ts && rm -rf hello.ts
    CHECK_RESULT $?
    lupdate-qt5 -no-ui-lines ../hello.cpp -ts hello.ts
    CHECK_RESULT $?
    grep "ui" hello.ts
    CHECK_RESULT $? 1
    lupdate-qt5 -disable-heuristic number ../hello.cpp -ts hello.ts | grep "3 source text"
    CHECK_RESULT $?
    lupdate-qt5 -pro ../hello.pro -ts hello.ts | grep "creating stash file"
    CHECK_RESULT $?
    lupdate-qt5 -pro-out /tmp ../hello.pro -ts hello.ts | grep "/tmp/.qmake.stash"
    CHECK_RESULT $?
    lupdate-qt5 -pro-debug ../hello.pro -ts hello.ts 2>&1 | grep -i "debug" && rm -rf hello.ts
    CHECK_RESULT $?
    lupdate-qt5 -source-language POSIX ../hello.cpp -ts hello.ts
    CHECK_RESULT $?
    grep 'sourcelanguage="POSIX"' hello.ts && rm -rf hello.ts
    CHECK_RESULT $?
    lupdate-qt5 ../hello.cpp -target-language en_US -ts hello.ts
    CHECK_RESULT $?
    grep 'language="en_US"' hello.ts
    CHECK_RESULT $?
    lupdate-qt5 ../hello.pro -tr-function-alias tr=tr -ts hello.ts
    CHECK_RESULT $?
    grep "tr" hello.ts
    CHECK_RESULT $?
    lupdate-qt5 ../hello.pro -ts test.ts | grep "Updating 'test.ts'"
    CHECK_RESULT $?
    lupdate-qt5 -version | grep -E "lupdate|${qt5_version}"
    CHECK_RESULT $?
    echo "../hello.pro" >list
    lupdate-qt5 @list -ts test.ts
    CHECK_RESULT $?
    test -f test.ts && rm -rf test.ts
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    rm -rf hello.ts debug test.ts list
    LOG_INFO "End to restore the test environment."
}

main "$@"
