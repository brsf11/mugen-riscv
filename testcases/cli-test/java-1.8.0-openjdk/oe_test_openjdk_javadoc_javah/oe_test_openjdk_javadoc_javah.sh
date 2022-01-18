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
    cp ../common/* .
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    javadoc -help | grep -i usage
    CHECK_RESULT $?
    javadoc -public Hello1.java -d public
    CHECK_RESULT $?
    find public
    CHECK_RESULT $?
    javadoc -protected Hello1.java -d protected
    CHECK_RESULT $?
    find protected
    CHECK_RESULT $?
    javadoc -private Hello1.java -d private
    CHECK_RESULT $?
    find private
    CHECK_RESULT $?
    javadoc -package Hello1.java -d package
    CHECK_RESULT $?
    find package
    CHECK_RESULT $?

    javah -h | grep -i Usage
    CHECK_RESULT $?
    javah -version | grep 'javah version'
    CHECK_RESULT $?
    javah -v Hello | grep 'Hello.h'
    CHECK_RESULT $?
    find Hello.h
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Need't to restore the tet environment."
    DNF_REMOVE
    rm -rf Hello* public protected private package

    LOG_INFO "End to restore the test environment."
}

main "$@"
