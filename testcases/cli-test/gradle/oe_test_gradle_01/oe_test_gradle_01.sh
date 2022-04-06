#!/usr/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.
####################################
#@Author    	:   guochenyang
#@Contact   	:   377012421@qq.com
#@Date      	:   2022-3-29 09:30:43
#@License   	:   Mulan PSL v2
#@Desc      	:   verification gradle‘s command
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh
function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL gradle
    version=$(rpm -qa gradle | awk -F "-" '{print$2}')
    LOG_INFO "End to prepare the test environment."
}
function run_test() {
    LOG_INFO "Start to run test."
    gradle --help | grep -i "USAGE:"
    CHECK_RESULT $? 0 0 "Check gradle --help failed"
    test "$(gradle --version | grep "Gradle" | awk '{print $2}')" == $version
    CHECK_RESULT $? 0 0 "Check gradle --version failed."
    gradle | grep "BUILD SUCCESSFUL"
    CHECK_RESULT $? 0 0 "Check gradle failed."
    gradle buildEnvironment | grep "BUILD SUCCESSFUL"
    CHECK_RESULT $? 0 0 "Check gradle buildEnvironment failed."
    gradle components | grep "BUILD SUCCESSFUL"
    CHECK_RESULT $? 0 0 "Check gradle components failed."
    gradle model | grep "model"
    CHECK_RESULT $? 0 0 "Check gradle model failed."
    gradle properties | grep "BUILD SUCCESSFUL"
    CHECK_RESULT $? 0 0 "Check gradle properties failed."
    gradle -q projects | grep "project"
    CHECK_RESULT $? 0 0 "Check gradle -q projects failed."
    gradle dependencies | grep "BUILD SUCCESSFUL"
    CHECK_RESULT $? 0 0 "Check gradle dependencies failed."
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf .gradle/
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}
main "$@"
