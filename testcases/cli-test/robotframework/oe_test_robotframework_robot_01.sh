#!/usr/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more detaitest -f.

# ########################################################
# @Author    :   zhanglu626
# @Contact   :   m18409319968@163.com
# @Date      :   2022/01/18
# @License   :   Mulan PSL v2
# @Desc      :   A Python based test automation framework
# ########################################################
source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment!"
    DNF_INSTALL "python3-robotframework"
    cd RobotDemo
    LOG_INFO "End to prepare the test environment!"
}

function run_test() {
    LOG_INFO "Start executing testcase!"
    path=$(
        cd "$(dirname $0)" || exit 1
        pwd
    )
    robot --name openEuler keyword_driven.robot && grep 'name="openEuler"' output.xml
    CHECK_RESULT $? 0 0 "Failed to set the name of the top-level suite"
    robot --doc "txt" keyword_driven.robot && grep "<doc>txt</doc>" output.xml
    CHECK_RESULT $? 0 0 "Failed to set the output format"
    robot --metadata Version:1.2 keyword_driven.robot && grep '"Version">1.2' output.xml
    CHECK_RESULT $? 0 0 "Failed to set metadata for the top-level suite"
    robot -G setgg keyword_driven.robot && grep "<tag>setgg" output.xml
    CHECK_RESULT $? 0 0 "Failed to set the given flag for all tests"
    robot -e aaa keyword_driven.robot | grep "${path}/output.xml"
    CHECK_RESULT $? 0 0 "Failed to test for items not contained in the specified tag"
    robot data_driven.robot
    robot -R output.xml data_driven.robot | grep "1 test, 0 passed, 1 failed"
    CHECK_RESULT $? 0 0 "The failed test to be re-executed from the earlier output file failed"
    robot data_driven.robot
    robot -S output.xml data_driven.robot | grep "6 tests, 5 passed, 1 failed"
    CHECK_RESULT $? 0 0 "Failed to select the failed suite to re-execute from the previous output file"
    robot --runemptysuite --include -S output.xml data_driven.robot | grep "0 tests, 0 passed, 0 failed"
    CHECK_RESULT $? 0 0 "Suite execution failed"
    robot -n Alias keyword_driven.robot 2>&1 | grep "have been deprecated"
    CHECK_RESULT $? 0 0 "Alias failed"
    robot -c critical keyword_driven.robot 2>&1 | grep "have been deprecated"
    CHECK_RESULT $? 0 0 "Failure to perform the opposite"
    LOG_INFO "End of testcase execution!"
}

function post_test() {
    LOG_INFO "Start environment cleanup."
    DNF_REMOVE
    rm -rf org.xml rerun.xml
    cd ..
    LOG_INFO "Finish environment cleanup."
}

main $@
