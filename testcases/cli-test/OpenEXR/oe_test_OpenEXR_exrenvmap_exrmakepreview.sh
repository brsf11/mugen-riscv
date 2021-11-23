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
# @Author    :   wangshan
# @Contact   :   wangshan@163.com
# @Date      :   2021-08-04
# @License   :   Mulan PSL v2
# @Desc      :   exrenvmap exrmakepreview
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL "OpenEXR OpenEXR-devel"
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    exrenvmap -u bind_29_1.exr test11 && test -f test11
    CHECK_RESULT $? 0 0 "Check exrenvmap -u failed."
    exrenvmap -z zip bind_29_1.exr test12 && test -f test12
    CHECK_RESULT $? 0 0 "Check exrenvmap -z failed."
    exrenvmap -v bind_29_1.exr test13 | grep "done" && test -f test13
    CHECK_RESULT $? 0 0 "Check exrenvmap -v failed."
    exrenvmap -w 256 bind_29_1.exr test14 && test -f test14
    CHECK_RESULT $? 0 0 "Check exrenvmap -w failed."
    exrenvmap -f 3 4 bind_29_1.exr test15 && test -f test15
    CHECK_RESULT $? 0 0 "Check exrenvmap -f failed."
    exrenvmap -t 256 156 bind_29_1.exr test16 && test -f test16
    CHECK_RESULT $? 0 0 "Check exrenvmap -t failed."

    exrmakepreview -w 100 bind_29_1.exr test1 && test -f test1
    CHECK_RESULT $? 0 0 "Check exrmakepreview -w failed."
    exrmakepreview -e 2 bind_29_1.exr test2 && test -f test2
    CHECK_RESULT $? 0 0 "Check exrmakepreview -e failed."
    exrmakepreview -v bind_29_1.exr test3 | grep "done"
    CHECK_RESULT $? 0 0 "Check exrmakepreview -v failed."
    exrmakepreview -h 2>&1 | grep "usage:"
    CHECK_RESULT $? 0 0 "Check exrmakepreview -h failed."
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf test*
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}
main "$@"
