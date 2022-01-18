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
    echo "容颜" >zh.txt
    native2ascii zh.txt u.txt
    CHECK_RESULT $?
    grep '5bb9' u.txt | grep '989c'
    CHECK_RESULT $?
    native2ascii -reverse u.txt | grep '容颜'
    CHECK_RESULT $?
    native2ascii -encoding ISO8859-1 zh.txt i.txt
    CHECK_RESULT $?
    grep e5 i.txt | grep ae | grep b9
    CHECK_RESULT $?
    javac Hello.java
    pack200 -help | grep Usage
    CHECK_RESULT $?
    pack200 --version | grep "version [0-9]"
    CHECK_RESULT $?
    jar cvf Hello.jar Hello.class
    CHECK_RESULT $?
    find Hello.jar
    CHECK_RESULT $?
    pack200 Hello.jar.pack.gz Hello.jar
    CHECK_RESULT $?
    find Hello.jar.pack.gz
    CHECK_RESULT $?
    rm -rf Hello.jar
    unpack200 Hello.jar.pack.gz Hello.jar
    CHECK_RESULT $?
    find Hello.jar
    CHECK_RESULT $?
    rm -rf Hello.jar.pack.gz
    pack200 -q Hello.jar.pack.gz Hello.jar
    CHECK_RESULT $?
    find Hello.jar.pack.gz
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Need't to restore the tet environment."
    DNF_REMOVE
    rm -rf Hello.* *.txt
    LOG_INFO "End to restore the test environment."
}

main "$@"
