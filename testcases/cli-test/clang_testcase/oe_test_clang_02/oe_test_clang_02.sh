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
#@Author    	:   guochenyang
#@Contact   	:   377012421@qq.com
#@Date      	:   2020-10-10 09:30:43
#@License       :   Mulan PSL v2
#@Desc      	:   verification clang‘s command
#####################################
source ${OET_PATH}/libs/locallibs/common_lib.sh
function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL clang
    cp -r ../common ../common1
    cd ../common1
    LOG_INFO "End to prepare the test environment."
}
function run_test() {
    LOG_INFO "Start to run test."
    clang -ftime-report test.c
    CHECK_RESULT $?
    clang -dump-raw-token test.c
    CHECK_RESULT $?
    clang test.c -fsyntax-only
    CHECK_RESULT $?
    clang++ -E test.c -o test.i
    CHECK_RESULT $?
    test -f test.i
    CHECK_RESULT $?
    clang++ -S test.i
    CHECK_RESULT $?
    clang++ -c test.s
    CHECK_RESULT $?
    clang++ -o test test.c
    CHECK_RESULT $?
    test -f test
    CHECK_RESULT $?
    clang-format test.c
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}
function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf ../common1
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}
main "$@"
