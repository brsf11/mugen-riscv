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
    robot --quiet data_driven.robot >quiet_file 2>&1
    test -s qutet_file
    CHECK_RESULT $? 1 0 "In addition to errors and warnings, there is output"
    robot -W 60 data_driven.robot 2>&1 | head -n 1 | wc -c | grep 61
    CHECK_RESULT $? 0 0 "Failed to set the width of console output"
    robot -C off data_driven.robot | grep "output.xml"
    CHECK_RESULT $? 0 0 "Colors are used on the console output"
    robot -h 2>&1 | grep "Usage:  robot"
    CHECK_RESULT $? 0 0 "Failed to print help information. Procedure"
    robot --version 2>&1 | grep "Robot Framework "
    CHECK_RESULT $? 0 0 "Failed to print version information. Procedure"
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
