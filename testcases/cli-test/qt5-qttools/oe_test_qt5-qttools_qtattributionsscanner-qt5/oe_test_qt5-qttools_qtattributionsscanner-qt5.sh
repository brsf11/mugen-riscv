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
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    qtattributionsscanner-qt5 -h | grep -E "qtattributionsscanner-qt5 |help"
    CHECK_RESULT $?
    qtattributionsscanner-qt5 -v | grep "Qt Attributions Scanner"
    CHECK_RESULT $?
    qtattributionsscanner-qt5 --verbose --output-format json -o outputfile.json ./ 2>&1 | grep "json"
    CHECK_RESULT $?
    qtattributionsscanner-qt5 --filter QDocModule=qtcore -o outputfile.json ./
    CHECK_RESULT $?
    grep "qtcore" outputfile.json
    CHECK_RESULT $?
    qtattributionsscanner-qt5 --verbose --basedir ./ -o outputfile.json ./ 2>&1 | grep "scanning ./"
    CHECK_RESULT $?
    qtattributionsscanner-qt5 --verbose -o outputfile.json ./ 2>&1 | grep "done"
    CHECK_RESULT $?
    test -z "$(qtattributionsscanner-qt5 -s -o outputfile.json ./)"
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    rm -rf outputfile.json
    LOG_INFO "End to restore the test environment."
}

main "$@"
