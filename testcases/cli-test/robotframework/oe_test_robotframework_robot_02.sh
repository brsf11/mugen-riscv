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
    robot -d zl keyword_driven.robot | grep "${path}/zl/output.xml"
    CHECK_RESULT $? 0 0 "Failed to specify the output file directory"
    robot -o zlfile keyword_driven.robot | grep "${path}/zlfile.xml"
    CHECK_RESULT $? 0 0 "Failed to specifies the name of the output file"
    robot -l zllog keyword_driven.robot | grep "${path}/zllog.html"
    CHECK_RESULT $? 0 0 "Failed to specifies a log file"
    robot -r zlreport keyword_driven.robot | grep "${path}/zlreport.html"
    CHECK_RESULT $? 0 0 "Failed to specifies the report file"
    robot -x zlxunit keyword_driven.robot | grep "${path}/zlxunit.xml"
    CHECK_RESULT $? 0 0 "Failed to specifies the result file compatible with xUnit"
    robot --xunitskipnoncritical keyword_driven.robot 2>&1 | grep "has no effect"
    CHECK_RESULT $? 0 0 "Failed to specifies the result file compatible with xunit"
    robot -b zldebug keyword_driven.robot | grep "${path}/zldebug.txt"
    CHECK_RESULT $? 0 0 "Failed to write debug file during execution"
    robot -T keyword_driven.robot | grep "${path}/output-$(date +%Y%m%d)"
    CHECK_RESULT $? 0 0 "Failed to add the timestamp between the base name and extension of all generated output files"
    robot --logtitle zllogtitle keyword_driven.robot && grep '"log","title":"zllogtitle"' log.html
    CHECK_RESULT $? 0 0 "The generated log file title failed"
    robot --reporttitle zlreporttitle keyword_driven.robot && grep '"title":"zlreporttitle"' report.html
    CHECK_RESULT $? 0 0 "The generated report file title failed"
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
