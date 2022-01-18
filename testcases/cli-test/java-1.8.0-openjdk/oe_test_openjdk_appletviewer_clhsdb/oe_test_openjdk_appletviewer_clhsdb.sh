#!/usr/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   wanxiaofei_wx5323714
# @Contact   :   wanxiaofei4@huawei.com
# @Date      :   2020-08-02
# @License   :   Mulan PSL v2
# @Desc      :   verification openjdk‘s command
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh
function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL java-1.8.0-openjdk*
    cp ../common/Hello.java .
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    appletviewer | grep Usage
    CHECK_RESULT $?
    appletviewer -debug Hello.java >testlog <<EOF
exit
EOF
    grep "Initializing jdb" testlog
    CHECK_RESULT $?

    clhsdb >testlog <<EOF
quit
EOF
    grep hsdb testlog
    CHECK_RESULT $?

    jar cvf javatest.jar Hello.java
    find javatest.jar
    CHECK_RESULT $?
    idlj 2>&1 | grep Usage
    CHECK_RESULT $?
    idlj -keep javatest.jar
    CHECK_RESULT $?
    idlj -version | grep IDL-to-Java
    CHECK_RESULT $?

    jar -h 2>&1 | grep Usage
    touch Foo.class
    jar cvf classes.jar Foo.class
    CHECK_RESULT $?
    find classes.jar
    CHECK_RESULT $?

    jarsigner -h | grep Usage
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Need't to restore the tet environment."
    DNF_REMOVE
    rm -rf testlog Hello* Foo.class *.jar
    LOG_INFO "End to restore the test environment."
}

main "$@"
