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
    exrstdattr -wrapmodes 2 bind_29_1.exr test21 && test -f test21
    CHECK_RESULT $? 0 0 "Check exrstdattr -wrapmodes failed."
    exrstdattr -pixelAspectRatio 10 bind_29_1.exr test22 && test -f test22
    CHECK_RESULT $? 0 0 "Check exrstdattr -pixelAspectRatio failed."
    exrstdattr -screenWindowWidth 10 bind_29_1.exr test23 && test -f test23
    CHECK_RESULT $? 0 0 "Check exrstdattr -screenWindowWidth failed."
    exrstdattr -screenWindowCenter 10 10 bind_29_1.exr test24 && test -f test24
    CHECK_RESULT $? 0 0 "Check exrstdattr -screenWindowCenter failed."
    exrstdattr -string s s bind_29_1.exr test25 && test -f test25
    CHECK_RESULT $? 0 0 "Check exrstdattr -string failed."
    exrstdattr -float s f bind_29_1.exr test26 && test -f test26
    CHECK_RESULT $? 0 0 "Check exrstdattr -float failed."
    exrstdattr -int s i bind_29_1.exr test27 && test -f test27
    CHECK_RESULT $? 0 0 "Check exrstdattr -int failed."
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf test*
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}
main "$@"
