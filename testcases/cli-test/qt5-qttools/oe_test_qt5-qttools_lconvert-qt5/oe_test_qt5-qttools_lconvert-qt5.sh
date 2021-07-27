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
    swedish=$(rpm -ql qt5-linguist | grep "swedish.qph")
    cp $swedish ./
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    lconvert-qt5 -h | grep -E "lconvert|help"
    CHECK_RESULT $?
    lconvert-qt5 -i swedish.qph -o swedish
    CHECK_RESULT $?
    grep "context" swedish
    CHECK_RESULT $?
    lconvert-qt5 -if qph -i swedish.qph -of ts -o swedish.ts
    CHECK_RESULT $?
    grep -i "ts" swedish.ts
    CHECK_RESULT $?
    lconvert-qt5 -i swedish.qph -o swedish -drop-tags xml
    CHECK_RESULT $?
    grep -i "xml" swedish
    CHECK_RESULT $?
    lconvert-qt5 -i swedish.qph -o swedish -drop-translations
    CHECK_RESULT $?
    grep "unfinished" swedish
    CHECK_RESULT $?
    lconvert-qt5 -i swedish.qph -o swedish -source-language POSIX
    CHECK_RESULT $?
    grep "sourcelanguage=\"POSIX\"" swedish
    CHECK_RESULT $?
    lconvert-qt5 -i swedish.qph -o swedish -target-language POSIX
    CHECK_RESULT $?
    grep "language=\"POSIX\"" swedish
    CHECK_RESULT $?
    lconvert-qt5 -i swedish.qph -o swedish -no-obsolete
    CHECK_RESULT $?
    grep "obsolete" swedish
    CHECK_RESULT $? 0 1
    lconvert-qt5 -i swedish.qph -o swedish -no-finished
    CHECK_RESULT $?
    grep "type=\"finished\"" swedish
    CHECK_RESULT $? 0 1
    lconvert-qt5 -i swedish.qph -o swedish -no-untranslated
    CHECK_RESULT $?
    grep "untranslated" swedish
    CHECK_RESULT $? 0 1
    rm -rf ./swedish
    lconvert-qt5 -i swedish.qph -o swedish -sort-contexts
    CHECK_RESULT $?
    grep -i "context-sensitive" swedish
    CHECK_RESULT $?
    lconvert-qt5 -locations absolute -i swedish.qph -o swedish
    CHECK_RESULT $?
    grep "DOCTYPE TS" swedish
    CHECK_RESULT $?
    lconvert-qt5 -i swedish.qph -o swedish -no-ui-lines
    CHECK_RESULT $?
    grep " ui " swedish
    CHECK_RESULT $? 1
    lconvert-qt5 -i swedish.qph -o swedish -verbose 2>&1 | grep "Source"
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    rm -rf swedish swedish.qph verbose swedish.ts
    LOG_INFO "End to restore the test environment."
}

main "$@"
