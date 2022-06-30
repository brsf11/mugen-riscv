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
# @Author    :   liujuan
# @Contact   :   lchutian@163.com
# @Date      :   2020/10/14
# @License   :   Mulan PSL v2
# @Desc      :   verify the uasge of ctest3 command
# ############################################

source "../common/common_cmake.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    deploy_env
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    ctest3 --help | grep -E "Usage|ctest \[options\]"
    CHECK_RESULT $?
    ctest3 --version | grep "ctest version"
    CHECK_RESULT $?
    cmake ..
    CHECK_RESULT $?
    test -d CMakeFiles
    CHECK_RESULT $?
    test -f cmake_install.cmake -a -f CMakeCache.txt -a -f Makefile -a -f CTestTestfile.cmake
    CHECK_RESULT $?
    make | grep "Built target my_test"
    CHECK_RESULT $?
    test -f my_test
    CHECK_RESULT $?
    ctest3 -C "Debug" | grep "100% tests passed"
    CHECK_RESULT $?
    test -d Testing
    CHECK_RESULT $?
    ctest3 --verbose | grep -E "UpdateCTestConfiguration|Test command:|100% tests passed"
    CHECK_RESULT $?
    ctest3 --extra-verbose | grep -E "UpdateCTestConfiguration|Test command:|100% tests passed"
    CHECK_RESULT $?
    ctest3 --debug | grep -E "Constructing a list of tests|Done constructing a list of tests|Updating test list for fixtures|Added 0 tests to meet fixture requirements|100% tests passed|Total Test time (real)"
    CHECK_RESULT $?
    ctest3 --output-on-failure | grep "100% tests passed"
    CHECK_RESULT $?
    ctest3 -F | grep "100% tests passed"
    CHECK_RESULT $?
    ctest3 -j 1 | grep "100% tests passed"
    CHECK_RESULT $?
    ctest3 -Q | grep "100% tests passed"
    CHECK_RESULT $? 1
    ctest3 -O result
    CHECK_RESULT $?
    grep -E "\[HANDLER_OUTPUT\]|100% tests passed" result
    CHECK_RESULT $?
    ctest3 -N | grep "Total Tests: 2"
    CHECK_RESULT $?
    ctest3 -N -E test_1_plus_3 | grep -E "Test #1: test_run2|Total Tests: 1"
    CHECK_RESULT $?
    ctest3 -R test_run2 | grep "1/1 Test #1: test_run2"
    CHECK_RESULT $?
    ctest3 --build-and-test | grep "100% tests passed"
    CHECK_RESULT $?
    ctest3 --build-target . | grep "100% tests passed"
    CHECK_RESULT $?
    ctest3 --build-nocmake | grep "100% tests passed"
    CHECK_RESULT $?
    ctest3 -build-run-dir . | grep "100% tests passed"
    CHECK_RESULT $?
    ctest3 --build-two-config | grep "100% tests passed"
    CHECK_RESULT $?
    ctest3 --build-exe-dir . | grep "100% tests passed"
    CHECK_RESULT $?
    ctest3 --build-generator "Unix Makefiles" | grep "100% tests passed"
    CHECK_RESULT $?
    ctest3 --build-generator-toolset "Visual Studio" | grep "100% tests passed"
    CHECK_RESULT $?
    ctest3 --build-project my_test | grep "100% tests passed"
    CHECK_RESULT $?
    ctest3 --print-labels | grep "Labels"
    CHECK_RESULT $?
    ctest3 --timeout 0.0001 | grep -E "0% tests passed, 2 tests failed out of 2|1 - test_run2 \(Timeout\)|2 - test_1_plus_3 \(Timeout\)"
    CHECK_RESULT $?
    ctest3 --stop-time 0.001 | grep "100% tests passed"
    CHECK_RESULT $?
    ctest3 --http1.0 | grep "100% tests passed"
    CHECK_RESULT $?
    ctest3 --no-compress-output | grep "100% tests passed"
    CHECK_RESULT $?
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    clear_env
    LOG_INFO "Finish restoring the test environment."
}

main $@
