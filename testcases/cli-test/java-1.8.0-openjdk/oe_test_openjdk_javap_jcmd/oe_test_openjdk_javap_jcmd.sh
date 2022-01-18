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
    javac Hello.java
    javap -help | grep Usage
    CHECK_RESULT $?
    javap -version | grep [0-9]
    CHECK_RESULT $?
    javap -public Hello | grep 'class Hello'
    CHECK_RESULT $?
    javap -protected Hello | grep 'class Hello'
    CHECK_RESULT $?
    javap -package Hello | grep 'class Hello'
    CHECK_RESULT $?
    javap -private Hello | grep 'class Hello'
    CHECK_RESULT $?
    javap -p -v Hello | grep 'Classfile'
    CHECK_RESULT $?

    jcmd -h | grep Usage
    CHECK_RESULT $?
    jcmd -l | grep 'jcmd'
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Need't to restore the tet environment."
    DNF_REMOVE
    rm -rf Hello.*
    LOG_INFO "End to restore the test environment."
}

main "$@"
