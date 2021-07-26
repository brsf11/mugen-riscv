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
# @Date      :   2020/10/19
# @License   :   Mulan PSL v2
# @Desc      :   The usage of commands in multipath-tools package
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL multipath-tools
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    mpathconf --allow 360000000000000000e00000000010001 --outfile multipath.conf
    CHECK_RESULT $?
    grep "360000000000000000e00000000010001" multipath.conf
    CHECK_RESULT $?
    mpathconf --disable
    CHECK_RESULT $?
    mpathconf | grep "multipath is disabled"
    CHECK_RESULT $?
    mpathconf --enable --with_multipathd y
    CHECK_RESULT $?
    mpathconf | grep "multipath is enabled"
    CHECK_RESULT $?
    mpathconf --user_friendly_names y
    CHECK_RESULT $?
    mpathconf | grep "user_friendly_names is enabled"
    CHECK_RESULT $?
    mpathconf --find_multipaths y
    CHECK_RESULT $?
    mpathconf | grep "find_multipaths is enabled"
    CHECK_RESULT $?
    mpathconf --with_module y | grep "dm_multipath module is loaded"
    CHECK_RESULT $?
    multipathd
    CHECK_RESULT $?
    mpathconf | grep "multipathd is running"
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    rm -rf multipath.conf
    LOG_INFO "End to restore the test environment."
}

main "$@"
