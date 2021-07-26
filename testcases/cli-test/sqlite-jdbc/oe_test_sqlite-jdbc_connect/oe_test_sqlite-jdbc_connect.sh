#!/usr/bin/bash

# Copyright (c) 2021. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.
####################################
#@Author        :   wangjingfeng
#@Contact       :   1136232498@qq.com
#@Date          :   2020/11/16
#@License       :   Mulan PSL v2
#@Desc          :   SQLite jdbc driver test
####################################
source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."

    if ! java -version; then
        java_version=$(dnf list | grep "java-1.8.*-openjdk" | awk -F '-' '{print $2}' | sed -n '1p')
        DNF_INSTALL "java-${java_version}-openjdk java-${java_version}-openjdk-devel sqlite-jdbc"
    else
        DNF_INSTALL "sqlite-jdbc"
    fi
    sqlite_jdbc_jar=$(rpm -ql sqlite-jdbc | grep sqlite-jdbc.jar)
    export CLASSPATH=${sqlite_jdbc_jar}:.

    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."

    javac Test.java
    CHECK_RESULT $? 0 0 "java source code compilation failed."
    java Test | grep "org.sqlite.SQLiteConnection" && java Test | grep "t_user_name"
    CHECK_RESULT $? 0 0 "sqlite-jdbc driver is invalid."

    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."

    unset CLASSPATH
    rm -rf ./*.class
    DNF_REMOVE

    LOG_INFO "End to restore the test environment."
}

main "$@"
