#!/usr/bin/bash

# Copyright (c) 2021. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.
####################################
#@Author    	:   doraemon2020
#@Contact   	:   xcl_job@163.com
#@Date      	:   2020-10-12
#@License   	:   Mulan PSL v2
#@Desc      	:   command test-libpng12
#####################################
source "${OET_PATH}"/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL "libpng12 libpng12-devel"
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    test "/$(rpm -ql libpng12 | grep '.so' | awk -F '/' 'NR==1{print $2}')" == "$(libpng12-config --prefix)"
    CHECK_RESULT $?
    test "$(rpm -ql libpng12 | grep '.so' | awk -F '/libpng12' 'NR==1{print $1}')" == "$(libpng12-config --libdir)"
    CHECK_RESULT $?
    libpng12-config --libs | grep '\-lpng12'
    CHECK_RESULT $?
    libpng12-config --cflags | grep '\-I/usr/include/libpng12'
    CHECK_RESULT $?
    libpng12-config --I_opts | grep '\-I/usr/include/libpng12'
    CHECK_RESULT $?
    libpng12-config --L_opts | grep '\-L/usr/lib64'
    CHECK_RESULT $?
    libpng12-config --ldflags | grep '\-L/usr/lib64 -lpng12'
    CHECK_RESULT $?
    libpng12-config --help | grep 'Usage'
    CHECK_RESULT $?
    test "$(libpng12-config --version)" == "$(rpm -qi libpng12 | grep 'Version' | awk '{print$3}')"
    CHECK_RESULT $?
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    LOG_INFO "Finish restoring the test environment."
}

main "$@"
