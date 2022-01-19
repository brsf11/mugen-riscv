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
    rebot -T zl/zl.xml | grep "log-$(date +%Y%m%d)"
    CHECK_RESULT $? 0 0 "Failed to use timestamp ended file format"
    rebot --xunitskipnoncritical zl/zl.xml 2>&1 | grep "has been deprecated"
    CHECK_RESULT $? 0 0 "Failed to use Xunit"
    rebot -c zlll zl/zl.xml 2>&1 | grep "no effect"
    CHECK_RESULT $? 0 0 "Failed to use the critical tag"
    rebot -n zlll zl/zl.xml 2>&1 | grep "have been deprecated"
    CHECK_RESULT $? 0 0 "Failed to use the noncritical tag"
    rebot -G setgg zl/zl.xml
    grep "setgg" log.html
    CHECK_RESULT $? 0 0 "Failed to set the given flag for all tests"
    rebot -e aaa zl/zl.xml | grep "${path}/log.html"
    CHECK_RESULT $? 0 0 "Failed to test for items not contained in the specified tag"
    rebot --logtitle zltitle zl/zl.xml
    grep '"title":"zltitle"' log.html
    CHECK_RESULT $? 0 0 "The generated log file title failed"
    rebot --reporttitle zlreporttitle zl/zl.xml
    grep '"title":"zlreporttitle"' report.html
    CHECK_RESULT $? 0 0 "The generated report file title failed"
    rebot --reportbackground red:red:red zl/zl.xml
    grep '"background":{"fail":"red","pass":"red","skip":"red"' report.html
    CHECK_RESULT $? 0 0 "Failed to specify the background color to use in the report file"
    rebot -L info zl/zl.xml | grep "report.html"
    CHECK_RESULT $? 0 0 "Failed to set the log level"
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
