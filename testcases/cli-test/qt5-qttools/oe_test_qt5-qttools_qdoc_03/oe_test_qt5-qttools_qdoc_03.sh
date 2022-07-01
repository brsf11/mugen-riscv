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
# @Desc      :   The usage of commands in qt5-doctools binary package
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL "qt5-qttools qt5-doctools"
    qt5_global=$(rpm -ql qt5-qtbase | grep "global" | head -n 1)
    cp -r $qt5_global ../example* ../hello* ./
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    qdoc example.qdocconf -outputdir ./html --log-progress 2>&1 | grep -E "qt.qdoc|LOG"
    CHECK_RESULT $?
    qdoc example.qdocconf --write-qa-pages
    CHECK_RESULT $?
    grep "page" ./html/new.qdoc.index
    CHECK_RESULT $?
    rm -rf html
    qdoc example.qdocconf -I ./html
    CHECK_RESULT $?
    test -f ./html/new.qdoc.index && rm -rf ./html/new.qdoc.index
    CHECK_RESULT $?
    test -d ./html/images/ && rm -rf ./html/images/
    CHECK_RESULT $?
    qdoc example.qdocconf --isystem ./html/
    CHECK_RESULT $?
    grep -i "system" ./html/new.qdoc.index
    CHECK_RESULT $?
    qdoc example.qdocconf -F ./example.qdoc --debug 2>&1 | grep -i "include"
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    rm -rf example.qdoc example.qdocconf hello.cpp hello.h hello.pro html global result
    LOG_INFO "End to restore the test environment."
}

main "$@"
