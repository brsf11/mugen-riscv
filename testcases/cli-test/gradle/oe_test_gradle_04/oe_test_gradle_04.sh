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
    expect <<-END
    log_file gradle_log
    spawn gradle base --scan
    expect " "
    send "yes\n"
    expect eof
END
    grep "BUILD SUCCESSFUL" gradle_log
    CHECK_RESULT $? 0 0 "Check gradle base --scan failed"
    gradle build | grep "BUILD SUCCESSFUL"
    CHECK_RESULT $? 0 0 "Check gradle build failed."
    gradle check | grep "BUILD SUCCESSFUL"
    CHECK_RESULT $? 0 0 "Check gradle check failed."
    gradle clean | grep "BUILD SUCCESSFUL"
    CHECK_RESULT $? 0 0 "Check gradle clean failed."
    gradle -q help task base
    CHECK_RESULT $? 0 0 "Check gradle -q help task base failed."
    gradle dependencyInsight --dependency someDep | grep "BUILD SUCCESSFUL"
    CHECK_RESULT $? 0 0 "Check gradle dependencyInsight failed."
    gradle javadoc | grep "BUILD SUCCESSFUL"
    CHECK_RESULT $? 0 0 "Check gradle javadoc failed."
    gradle assemble | grep "BUILD SUCCESSFUL"
    CHECK_RESULT $? 0 0 "Check gradle assemble failed."
    gradle jar | grep "BUILD SUCCESSFUL"
    CHECK_RESULT $? 0 0 "Check gradle jar failed."
    gradle testClasses | grep "BUILD SUCCESSFUL"
    CHECK_RESULT $? 0 0 "Check gradle testClasses failed."
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf $(ls | grep -vE "\.sh") .gradle/
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}
main "$@"
