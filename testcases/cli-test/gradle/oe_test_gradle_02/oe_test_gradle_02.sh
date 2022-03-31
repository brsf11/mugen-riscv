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
    mkdir subdir
    cat >./subdir/myproject.gradle <<EOF
task hello << {
    println "using build file '$buildFile.name' in '$buildFile.parentFile.name'."
}
EOF
    cat >./subdir/build.gradle <<EOF
task hello << {
    println "using build file '$buildFile.name' in '$buildFile.parentFile.name'."
}
EOF
    LOG_INFO "End to prepare the test environment."
}
function run_test() {
    LOG_INFO "Start to run test."
    gradle tasks init | grep "BUILD SUCCESSFUL"
    CHECK_RESULT $? 0 0 "Check gradle tasks init failed"
    gradle tasks wrapper | grep "BUILD SUCCESSFUL"
    CHECK_RESULT $? 0 0 "Check gradle tasks wrapper failed."
    cp -f ../common/build.gradle ./
    gradle -m build | grep "BUILD SUCCESSFUL"
    CHECK_RESULT $? 0 0 "Check gradle -m build failed."
    gradle build --profile | grep "BUILD SUCCESSFUL"
    CHECK_RESULT $? 0 0 "Check gradle build --profile failed."
    gradle -q -b subdir/myproject.gradle hello | grep "using build file '.name' in '.parentFile.name'."
    CHECK_RESULT $? 0 0 "Check gradle -q -b failed."
    gradle -q -p subdir hello | grep "using build file '.name' in '.parentFile.name'."
    CHECK_RESULT $? 0 0 "Check gradle -q -p failed."
    gradle base | grep "Task"
    CHECK_RESULT $? 0 0 "Check gradle base failed."
    gradle -q base | grep "BUILD SUCCESSFUL"
    CHECK_RESULT $? 1 0 "Check gradle -q base failed."
    gradle -w base | grep "warning"
    CHECK_RESULT $? 0 0 "Check gradle -w base failed."
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf $(ls | grep -vE "\.sh") .gradle/
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}
main "$@"
