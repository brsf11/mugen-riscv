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
    cp ../assistant.qhp ./
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    qhelpgenerator-qt5 assistant.qhp -o outputfile | grep "Building up"
    CHECK_RESULT $?
    test -f outputfile && rm -rf outputfile
    CHECK_RESULT $?
    qhelpgenerator-qt5 assistant.qhp -c -o outputfile | grep "custom filters"
    CHECK_RESULT $?
    test -f outputfile && rm -rf outputfile
    CHECK_RESULT $?
    qhelpgenerator-qt5 assistant.qhp -s -o outputfile | grep "Building up"
    CHECK_RESULT $? 0 1
    qhelpgenerator-qt5 -v | grep -E "Help Generator | ${qt5_version}"
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    rm -rf outputfile assistant.qhp
    LOG_INFO "End to restore the test environment."
}

main "$@"
