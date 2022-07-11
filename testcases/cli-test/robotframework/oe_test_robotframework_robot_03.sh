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
    robot --reportbackground red:red:red keyword_driven.robot && grep '"background":{"fail":"red","pass":"red","skip":"red"}' report.html
    CHECK_RESULT $? 0 0 "Failed to specify the background color to use in the report file"
    robot -L info keyword_driven.robot | grep "${path}/output.xml"
    CHECK_RESULT $? 0 0 "Failed to set the log level"
    robot --suitestatlevel 4 -r report_suit4.html keyword_driven.robot && grep "statistics td" report.html
    CHECK_RESULT $? 0 0 "Statistics by suite shows how many levels of failure in logs and reports"
    robot --nostatusrc data_driven.robot
    CHECK_RESULT $? 0 0 "The return code is not zero"
    robot -X data_driven.robot | grep "6 tests, 4 passed, 2 failed"
    CHECK_RESULT $? 0 0 "Sets to stop test execution failure if any key tests fail"
    robot --exitonerror data_driven.robot | grep "${path}/log.html"
    CHECK_RESULT $? 0 0 "Test execution is not stopped when an error occurs while parsing"
    robot -X --skipteardownonexit data_driven.robot 2>&1 | grep "Clear"
    CHECK_RESULT $? 1 0 "Test execution stopped early without skipping dismantlement"
    robot --randomize all data_driven.robot | grep "6 tests"
    CHECK_RESULT $? 0 0 "Non-randomize test execution order"
    robot --console dotted data_driven.robot | grep "....F."
    CHECK_RESULT $? 0 0 "Specifies how execution is reported on the console"
    robot --dotted data_driven.robot | grep "....F."
    CHECK_RESULT $? 0 0 "Specifies how to report execution on the console (shortcuts)"
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
