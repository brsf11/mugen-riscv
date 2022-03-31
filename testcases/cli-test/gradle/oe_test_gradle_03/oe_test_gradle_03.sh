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
    cp ../common/build.gradle ./
    LOG_INFO "End to prepare the test environment."
}
function run_test() {
    LOG_INFO "Start to run test."
    gradle -i base | grep "All projects evaluated."
    CHECK_RESULT $? 0 0 "Check gradle -i base failed."
    gradle extend | grep "I'm extend!"
    CHECK_RESULT $? 0 0 "Check gradle extend failed."
    gradle base dolast | grep "dolast"
    CHECK_RESULT $? 0 0 "Check gradle base dolast failed."
    gradle base dolast -x dolast | grep "dolast"
    CHECK_RESULT $? 1 0 "Check gradle base dolast -x dolast failed."
    gradle base --rerun-tasks | grep "BUILD SUCCESSFUL"
    CHECK_RESULT $? 0 0 "Check gradle base --rerun-tasks failed."
    gradle base --continue | grep "BUILD SUCCESSFUL"
    CHECK_RESULT $? 0 0 "Check gradle base --continue failed."
    gradle base --console plain | grep "BUILD SUCCESSFUL"
    CHECK_RESULT $? 0 0 "Check gradle base --console plain failed."
    gradle base --console rich | grep "BUILD SUCCESSFUL"
    CHECK_RESULT $? 0 0 "Check gradle base --console plain failed."
    gradle base --status | grep "STATUS"
    CHECK_RESULT $? 0 0 "Check gradle base --status failed."
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf $(ls | grep -vE "\.sh") .gradle/
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}
main "$@"
