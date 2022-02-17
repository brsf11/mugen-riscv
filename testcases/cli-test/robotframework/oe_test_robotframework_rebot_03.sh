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
    mkdir zl
    robot --output org.xml data_driven.robot
    robot --rerunfailed org.xml --output rerun.xml data_driven.robot
    robot --output zl/zl.xml data_driven.robot
    LOG_INFO "End to prepare the test environment!"
}

function run_test() {
    LOG_INFO "Start executing testcase!"
    path=$(
        cd "$(dirname $0)" || exit 1
        pwd
    )
    rebot --suitestatlevel 4 -r report_suit2.html zl/zl.xml
    grep "statistics td" report.html
    CHECK_RESULT $? 0 0 "Failed to set logging and reporting levels"
    rebot --starttime '2022-11-16 11:14:42.268' zl/zl.xml | grep "${path}/log.html"
    CHECK_RESULT $? 0 0 "Failed to set the execution start time"
    rebot --endtime '2022-11-16 11:18:42.268' zl/zl.xml | grep "${path}/report.html"
    CHECK_RESULT $? 0 0 "Failed to set the end time"
    rebot --nostatusrc zl/zl.xml
    CHECK_RESULT $? 0 0 "The return code is not set to zero"
    rebot -C on zl/zl.xml | grep "${path}/log.html"
    CHECK_RESULT $? 0 0 "Failed to set the use of color on console output"
    rebot -h 2>&1 | grep "Usage:  rebot"
    CHECK_RESULT $? 0 0 "Failed to print help information"
    rebot --version 2>&1 | grep "Rebot "
    CHECK_RESULT $? 0 0 "Failed to print version information"
    LOG_INFO "End of testcase execution!"
}

function post_test() {
    LOG_INFO "Start environment cleanup."
    DNF_REMOVE
    rm -rf zl org.xml rerun.xml
    cd ..
    LOG_INFO "Finish environment cleanup."
}

main $@
