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
# @Desc      :   exrstdattr
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL "OpenEXR OpenEXR-devel"
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    exrstdattr -longitude 10 bind_29_1.exr test11 && test -f test11
    CHECK_RESULT $? 0 0 "Check exrstdattr -longitude failed."
    exrstdattr -latitude 10 bind_29_1.exr test12 && test -f test12
    CHECK_RESULT $? 0 0 "Check exrstdattr -latitude failed."
    exrstdattr -altitude 10 bind_29_1.exr test13 && test -f test13
    CHECK_RESULT $? 0 0 "Check exrstdattr -altitude failed."
    exrstdattr -focus 10 bind_29_1.exr test14 && test -f test14
    CHECK_RESULT $? 0 0 "Check exrstdattr -focus failed."
    exrstdattr -expTime 10 bind_29_1.exr test15 && test -f test15
    CHECK_RESULT $? 0 0 "Check exrstdattr -expTime failed."
    exrstdattr -aperture 10 bind_29_1.exr test16 && test -f test16
    CHECK_RESULT $? 0 0 "Check exrstdattr -aperture failed."
    exrstdattr -isoSpeed 10 bind_29_1.exr test17 && test -f test17
    CHECK_RESULT $? 0 0 "Check exrstdattr -isoSpeed failed."
    exrstdattr -envmap LATLONG bind_29_1.exr test18 && test -f test18
    CHECK_RESULT $? 0 0 "Check exrstdattr -envmap failed."
    exrstdattr -keyCode 21 21 21 21 21 12 21 bind_29_1.exr test19 && test -f test19
    CHECK_RESULT $? 0 0 "Check exrstdattr -keyCode failed."
    exrstdattr -timeCode 2 2 bind_29_1.exr test20 && test -f test20
    CHECK_RESULT $? 0 0 "Check exrstdattr -timeCode failed."
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf test*
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}
main "$@"
