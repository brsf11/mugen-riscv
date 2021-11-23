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
# @Desc      :   exrenvmap
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL "OpenEXR OpenEXR-devel"
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    exrenvmap -o bind_29_1.exr test1 && test -f test1
    CHECK_RESULT $? 0 0 "Check exrenvmap -o failed."
    exrenvmap -m bind_29_1.exr test2 && test -f test2
    CHECK_RESULT $? 0 0 "Check exrenvmap -m failed."
    exrenvmap -c bind_29_1.exr test3 && test -f test3
    CHECK_RESULT $? 0 0 "Check exrenvmap -c failed."
    exrenvmap -l bind_29_1.exr test4 && test -f test4
    CHECK_RESULT $? 0 0 "Check exrenvmap -l failed."
    exrenvmap -ci bind_29_1.exr test5 && test -f test5
    CHECK_RESULT $? 0 0 "Check exrenvmap -ci failed."
    exrenvmap -li bind_29_1.exr test6 && test -f test6
    CHECK_RESULT $? 0 0 "Check exrenvmap -li failed."
    exrenvmap -b bind_29_1.exr test7 && test -f test7
    CHECK_RESULT $? 0 0 "Check exrenvmap -b failed."
    exrenvmap -h 2>&1 | grep "usage:"
    CHECK_RESULT $? 0 0 "Check exrenvmap -h failed."
    exrenvmap -p t b bind_29_1.exr test9 && test -f test9
    CHECK_RESULT $? 0 0 "Check exrenvmap -p failed."
    exrenvmap -d bind_29_1.exr test10 && test -f test10
    CHECK_RESULT $? 0 0 "Check exrenvmap -d failed."
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf test*
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}
main "$@"
