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
# @Desc      :   exrmultipart exrheader exrenvmap
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL "OpenEXR OpenEXR-devel"
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    exrmultipart -combine -i bind_29_1.exr -o test1.exr -override 1 && test -f test1.exr
    CHECK_RESULT $? 0 0 "Check exrmultipart -combine -i failed."
    exrmultipart -separate -i bind_29_1.exr -o test2 -override 1 && test -f test2.1.exr
    CHECK_RESULT $? 0 0 "Check exrmultipart -separate -i failed."
    exrmultipart -convert -i bind_29_1.exr -o test3.exr -override 1 && test -f test3.exr
    CHECK_RESULT $? 0 0 "Check exrmultipart -convert -i failed."
    rm -rf test*

    exrmultipart -combine -i bind_29_1.exr -o test1.exr view test1.exr && test -f test1.exr
    CHECK_RESULT $? 0 0 "Check exrmultipart -convert view failed."
    exrmultipart -separate -i bind_29_1.exr -o test2 view test2 && test -f test2.1.exr
    CHECK_RESULT $? 0 0 "Check exrmultipart -convert view failed."
    exrmultipart -convert -i bind_29_1.exr -o test3.exr view test3.exr && test -f test3.exr
    CHECK_RESULT $? 0 0 "Check exrmultipart -convert view failed."

    exrheader bind_29_1.exr | grep "file bind_29_1.exr:"
    CHECK_RESULT $? 0 0 "Check exrheader failed."
    exrheader -h 2>&1 | grep "usage:"
    CHECK_RESULT $? 0 0 "Check exrheader -h failed."

    exrenvmap -o bind_29_1.exr test.exr
    CHECK_RESULT $? 0 0 "Check exrenvmap -o failed."
    exrmultiview -z pxr24 example bind_29_1.exr test11 test.exr test5 && test -f test5
    CHECK_RESULT $? 0 0 "Check exrmultiview -z failed."
    exrmultiview -v example bind_29_1.exr test22 test.exr test2 | grep "writing file test2"
    CHECK_RESULT $? 0 0 "Check exrmultiview -v failed."
    exrmultiview -h 2>&1 | grep "usage:"
    CHECK_RESULT $? 0 0 "Check exrmultiview -h failed."
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf test*
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}
main "$@"
