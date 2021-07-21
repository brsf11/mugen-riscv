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
#@Author    	:   guochenyang_wx5323712
#@Contact   	:   lemon.higgins@aliyun.com
#@Date      	:   2020-10-10 09:30:43
#@License   	:
#@Version   	:   1.0
#@Desc      	:   verification clang‘s command
#####################################
source ${OET_PATH}/libs/locallibs/common_lib.sh
function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL "clang clang-tools-extra"
    cp -r ../common ../common1
    cd ../common1
    LOG_INFO "End to prepare the test environment."
}
function run_test() {
    LOG_INFO "Start to run test."
    clang-format -i test.c
    CHECK_RESULT $?
    clang-format -style=google test.c
    CHECK_RESULT $?
    clang-format -style=llvm -dump-config >./clang-format
    CHECK_RESULT $?
    clang-format -style=file test.c
    CHECK_RESULT $?
    clang-format -lines=1:2 test.c
    CHECK_RESULT $?
    test -f test.cpp
    CHECK_RESULT $?
    clang-check test.cpp
    CHECK_RESULT $?
    clang-check test.cpp -ast-print -ast-dump-filter ActionFactory::newASTConsumer
    CHECK_RESULT $?
    clang-check test.cpp -ast-list
    CHECK_RESULT $?
    clang-check test.cpp -ast-dump
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
