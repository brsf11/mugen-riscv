#!/usr/bin/bash

# Copyright (c) 2021. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   huyahui
# @Contact   :   huyahui8@163.com
# @Date      :   2020/5/16
# @License   :   Mulan PSL v2
# @Desc      :   Run junit5 in gradle
# #############################################

source "../common/lib.sh"

function pre_test() {
    LOG_INFO "Start environment preparation."
    pre_junit5
    DNF_INSTALL gradle
    JAVA_HOME=/usr/lib/jvm/java-openjdk
    PATH=$PATH:$JAVA_HOME/bin
    export JAVA_HOME PATH
    export GRADLE_HOME=usr/share/gradle
    export PATH=$PATH:$GRADLE_HOME
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    gradle -version
    CHECK_RESULT $?
    mkdir -p junit5-gradle/src/test/java/com/example/project/
    mkdir -p junit5-gradle/src/main/java/com/example/project/
    cp build.gradle junit5-gradle
    cp SecondTest.java junit5-gradle/src/test/java/com/example/project/
    cd junit5-gradle || exit 1
    gradle build >/tmp/gradle_result &
    wait
    sleep 1
    grep '1 tests successful' /tmp/gradle_result
    CHECK_RESULT $?
    grep 'BUILD SUCCESSFUL' /tmp/gradle_result
    CHECK_RESULT $?
    cd - || exit 1
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    clean_junit5
    DNF_REMOVE
    rm -rf junit5-gradle /tmp/gradle_result
    source /etc/profile >/dev/null
    LOG_INFO "Finish environment cleanup!"
}
main "$@"
