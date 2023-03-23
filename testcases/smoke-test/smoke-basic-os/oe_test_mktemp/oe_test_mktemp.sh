#!/usr/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
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
# @Date      :   2022/06/07
# @License   :   Mulan PSL v2
# @Desc      :   Test the basic functions of mktemp
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function run_test() {
    LOG_INFO "Start to run test."
    mktemp /tmp/mktemp1.log.XXXXX
    CHECK_RESULT $? 0 0 "Failed to execute mktemp"
    test -f /tmp/mktemp1.log.*
    CHECK_RESULT $? 0 0 "File does not exist in tmp"
    mktemp_ver=$(rpm -qa coreutils | awk -F '-' '{print $2}')
    mktemp -V | grep $mktemp_ver
    CHECK_RESULT $? 0 0 "Failed to execute mktemp -V"
    mkdir testdir
    mktemp -p testdir
    CHECK_RESULT $? 0 0 "Failed to execute mktemp -p"
    test -f testdir/tmp*
    CHECK_RESULT $? 0 0 "File does not exist in testdir"
    mktemp -d /tmp/mktempdirXXXXX
    CHECK_RESULT $? 0 0 "Failed to execute mktemp -d"
    test -d /tmp/mktempdir*
    CHECK_RESULT $? 0 0 "Directory does not exist"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf /tmp/mktemp* testdir
    LOG_INFO "End to restore the test environment."
}

main "$@"
