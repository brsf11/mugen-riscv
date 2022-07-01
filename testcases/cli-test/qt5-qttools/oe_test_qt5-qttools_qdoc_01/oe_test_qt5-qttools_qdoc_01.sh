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
    qt5_version=$(rpm -qa qt5-qttools | awk -F '-' '{print $3}')
    qt5_global=$(rpm -ql qt5-qtbase | grep "global" | head -n 1)
    cp -r $qt5_global ../example* ../hello* ./
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    qdoc -h | grep -E "qdoc | help"
    CHECK_RESULT $?
    qdoc -v | grep "qdoc ${qt5_version}"
    CHECK_RESULT $?
    qdoc -D status=active example.qdocconf --outputdir ./html
    CHECK_RESULT $?
    grep 'status="active"' html/new.qdoc.index
    CHECK_RESULT $?
    qdoc --depends Print example.qdocconf --outputdir ./html
    CHECK_RESULT $?
    grep -i "print" html/new.qdoc.index
    CHECK_RESULT $?
    qdoc --showinternal example.qdocconf --outputdir ./html
    CHECK_RESULT $?
    grep -i "show" html/new.qdoc.index
    CHECK_RESULT $?
    qdoc --redirect-documentation-to-dev-null example.qdocconf --outputdir ./html
    CHECK_RESULT $?
    grep -i "document" html/new.qdoc.index
    CHECK_RESULT $?
    qdoc --no-examples example.qdocconf --outputdir ./html
    CHECK_RESULT $?
    ls html/ | grep example
    CHECK_RESULT $? 1
    rm -rf ./html/new.qdoc.index
    qdoc example.qdocconf --indexdir ./html -outputdir ./html
    CHECK_RESULT $?
    test -f ./html/new.qdoc.index && rm -rf ./html/new.qdoc.index
    CHECK_RESULT $?
    qdoc --highlighting example.qdocconf --outputdir ./html
    CHECK_RESULT $?
    grep -i "Highlighting" ./html/new.qdoc.index
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    rm -rf example.qdoc example.qdocconf hello.cpp hello.h hello.pro html global
    LOG_INFO "End to restore the test environment."
}

main "$@"
