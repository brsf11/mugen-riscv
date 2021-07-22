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
#@Date          :   2020/4/29
#@License       :   Mulan PSL v2
#@Desc          :   testNG multi-threaded processing
####################################
source ../common/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."

    pre_env

    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."

    javac TExpTh*.java
    CHECK_RESULT $? 0 0 "java source code compilation failed."
    java -cp "${CLASSPATH}" org.testng.TestNG TExpTh1.xml | grep "Thread Id"
    CHECK_RESULT $? 0 0 "testng execution use case failed,The xml file is TExpTh1.xml"
    java -cp "${CLASSPATH}" org.testng.TestNG TExpTh2.xml | grep "Thread Id"
    CHECK_RESULT $? 0 0 "testng execution use case failed,The xml is TExpTh2.xml"
    java -cp "${CLASSPATH}" org.testng.TestNG TExpTh3.xml | grep "Thread Id"
    CHECK_RESULT $? 0 0 "testng execution use case failed,The xml is TExpTh3.xml"
    if hostnamectl | grep "Virtualization"; then
        java -cp "${CLASSPATH}" org.testng.TestNG TExpTh4.xml | grep "Thread Id"
        CHECK_RESULT $? 0 0 "testng execution use case failed,The xml is TExpTh4.xml"
    else
        java -cp "${CLASSPATH}" org.testng.TestNG TExpTh6.xml | grep "Thread Id"
        CHECK_RESULT $? 0 0 "testng execution use case failed,The xml is TExpTh6.xml"
    fi

    if hostnamectl | grep "Virtualization"; then
        java -cp "${CLASSPATH}" org.testng.TestNG TExpTh5.xml | grep "Thread Id"
        CHECK_RESULT $? 0 0 "testng execution use case failed,The xml is TExpTh5.xml"
    else
        java -cp "${CLASSPATH}" org.testng.TestNG TExpTh7.xml | grep "Thread Id"
        CHECK_RESULT $? 0 0 "testng execution use case failed,The xml is TExpTh7.xml"
    fi

    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."

    clean_env

    LOG_INFO "End to restore the test environment."
}

main "$@"
