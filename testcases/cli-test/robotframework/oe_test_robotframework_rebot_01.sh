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
    rebot --rpa zl/zl.xml | grep "${path}/log.html"
    CHECK_RESULT $? 0 0 "Failed to open general Automation mode"
    rebot --merge org.xml rerun.xml | grep "${path}/report.html"
    CHECK_RESULT $? 0 0 "Failed to merge the output together"
    rebot --outputdir zl zl/zl.xml | grep "${path}/zl/log.html"
    CHECK_RESULT $? 0 0 "Failed to specify the path to the output file"
    rebot -N robot_zl zl/zl.xml
    grep '"name":"robot_zl"' report.html
    CHECK_RESULT $? 0 0 "Failed to set the name of the top-level suite"
    rebot -o rebot_zl zl/zl.xml | grep "${path}/rebot_zl.xml"
    CHECK_RESULT $? 0 0 "Failed to specify the output file name"
    rebot --doc "vvvlu" zl/zl.xml
    grep "vvvlu" report.html
    CHECK_RESULT $? 0 0 "Failed to set the top-level suite document"
    rebot --metadata Version:1.2 zl/zl.xml
    grep "<p>1.2" report.html
    CHECK_RESULT $? 0 0 "Failed to set metadata for the top-level suite"
    rebot -l zl/zllll zl/zl.xml | grep "Log:     ${path}/zl/zllll.html"
    CHECK_RESULT $? 0 0 "Failed to specify log file"
    rebot -r zl/zllll zl/zl.xml | grep "Report:  ${path}/zl/zllll.html"
    CHECK_RESULT $? 0 0 "Failed to execute the report file path"
    rebot -x zl/zllll zl/zl.xml | grep "XUnit:   ${path}/zl/zllll.xml"
    CHECK_RESULT $? 0 0 "Failed to generate xUnit-compatible result file"
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
