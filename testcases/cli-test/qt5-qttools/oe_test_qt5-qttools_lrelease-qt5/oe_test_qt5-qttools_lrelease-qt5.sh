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
    lrelease-qt5 -h | grep "lrelease"
    CHECK_RESULT $?
    lupdate-qt5 ../hello.pro -ts hello.ts
    lrelease-qt5 -idbased hello.ts -qm hello.qm | grep "ID"
    CHECK_RESULT $?
    grep "hello.cpp" hello.ts
    CHECK_RESULT $?
    lrelease-qt5 -compress hello.qm | grep "Updating"
    CHECK_RESULT $?
    lrelease-qt5 -nounfinished hello.ts -qm hello.qm | grep "untranslated"
    CHECK_RESULT $?
    lrelease-qt5 -removeidentical hello.ts -qm hello.qm | grep "equal"
    CHECK_RESULT $?
    lrelease-qt5 -markuntranslated 123456 hello.ts -qm hello.qm
    grep -aE "1|2|3|4|5|6" hello.qm
    CHECK_RESULT $?
    test -z "$(lrelease-qt5 -silent hello.ts -qm hello.qm)"
    CHECK_RESULT $?
    lrelease-qt5 -version | grep -E "lrelease|${qt5_version}"
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    rm -rf hello.ts hello.qm
    LOG_INFO "End to restore the test environment."
}

main "$@"
