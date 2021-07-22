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
# @Desc      :   Use with ant
# #############################################

source "../common/lib.sh"

function pre_test() {
    LOG_INFO "Start environment preparation."
    pre_junit5
    DNF_INSTALL "ant ant-junit5"
    JAVA_HOME=/usr/lib/jvm/java-openjdk
    PATH=$PATH:$JAVA_HOME/bin
    export JAVA_HOME PATH
    export ANT_HOME=/usr/share/ant
    export PATH=$PATH:$ANT_HOME/bin
    cp ../common/junit-platform-console-standalone-1.6.2.jar /usr/share/ant/lib/
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    ant -version
    CHECK_RESULT $?
    mkdir -p junit5_ant/src/test/java/com/example/project/
    mkdir -p junit5_ant/src/main/java/com/example/project/
    cp Calculator.java junit5_ant/src/main/java/com/example/project/
    cp CalculatorTests.java junit5_ant/src/test/java/com/example/project/
    cp build.xml junit5_ant
    cd junit5_ant || exit 1
    ant test >/tmp/ant_result &
    wait
    grep '1 tests successful' /tmp/ant_result
    CHECK_RESULT $?
    grep 'BUILD SUCCESSFUL' /tmp/ant_result
    CHECK_RESULT $?
    cd - || exit 1
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    clean_junit5
    DNF_REMOVE
    rm -rf junit5_ant /tmp/ant_result
    source /etc/profile >/dev/null
    LOG_INFO "Finish environment cleanup!"
}
main "$@"
