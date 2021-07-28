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
# @Date      :   2020/05/20
# @License   :   Mulan PSL v2
# @Desc      :   Compare the performance of running multiple test classes with placing the test classes in the test suite,and using the TestSuite class from junit and run it.
# ############################################

source "../common/common_junit.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    deploy_env
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    compile_java
    CHECK_RESULT $?
    execute_java TestRunnerTotal | grep -vE "TestJunit1Time|TestJunit2Time|TestJunit3Time|TestTotalTime" >actual_result
    diff actual_result expect_result1
    CHECK_RESULT $?
    execute_java | grep -v "SuiteTestTime" >actual_result
    diff actual_result expect_result2
    CHECK_RESULT $?
    execute_java JunitTestSuite | grep -v "JunitTestSuiteTime" >actual_result
    diff actual_result expect_result3
    CHECK_RESULT $?
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    clear_env
    LOG_INFO "Finish restoring the test environment."
}

main $@
