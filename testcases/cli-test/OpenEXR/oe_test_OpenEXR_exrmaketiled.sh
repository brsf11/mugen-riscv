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
# @Desc      :   exrmaketiled
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL "OpenEXR OpenEXR-devel"
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    exrmaketiled -o bind_29_1.exr test1 && test -f test1
    CHECK_RESULT $? 0 0 "Check exrmaketiled -o failed."
    exrmaketiled -m bind_29_1.exr test2 && test -f test2
    CHECK_RESULT $? 0 0 "Check exrmaketiled -m failed."
    exrmaketiled -r bind_29_1.exr test3 && test -f test3
    CHECK_RESULT $? 0 0 "Check exrmaketiled -r failed."
    exrmaketiled -f c bind_29_1.exr test4 && test -f test4
    CHECK_RESULT $? 0 0 "Check exrmaketiled -f failed."
    exrmaketiled -e black clamp bind_29_1.exr test5 && test -f test5
    CHECK_RESULT $? 0 0 "Check exrmaketiled -e failed."
    exrmaketiled -t 22 44 bind_29_1.exr test6 && test -f test6
    CHECK_RESULT $? 0 0 "Check exrmaketiled -t failed."
    exrmaketiled -d bind_29_1.exr test7 && test -f test7
    CHECK_RESULT $? 0 0 "Check exrmaketiled -d failed."
    exrmaketiled -u bind_29_1.exr test8 && test -f test8
    CHECK_RESULT $? 0 0 "Check exrmaketiled -u failed."
    exrmaketiled -z pxr24 bind_29_1.exr test9 && test -f test9
    CHECK_RESULT $? 0 0 "Check exrmaketiled -z failed."
    exrmaketiled -v bind_29_1.exr test10 | grep "done" && test -f test10
    CHECK_RESULT $? 0 0 "Check exrmaketiled -v failed."
    exrmaketiled -h 2>&1 | grep "usage:"
    CHECK_RESULT $? 0 0 "Check exrmaketiled -h failed."
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf test*
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}
main "$@"
