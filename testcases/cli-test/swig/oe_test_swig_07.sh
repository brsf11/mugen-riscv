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
# @Author    :   liujingjing
# @Contact   :   liujingjing25812@163.com
# @Date      :   2020/10/15
# @License   :   Mulan PSL v2
# @Desc      :   The usage of commands in swig package
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL swig
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    swig -java -M example.i | grep ".swg"
    CHECK_RESULT $?
    swig -java -MD example.i
    CHECK_RESULT $?
    test -f example_wrap.d && rm -rf example_wrap.d
    CHECK_RESULT $?
    swig -java -M -MF file example.i
    CHECK_RESULT $?
    grep -E "example_wrap.c|/usr/share/swig/|example.i" file
    CHECK_RESULT $?
    swig -java -MM example.i | grep "/usr/share/swig/3.0.12/"
    CHECK_RESULT $? 0 1
    swig -java -MMD example.i
    CHECK_RESULT $?
    test -f example_wrap.d && rm -rf example_wrap.d
    CHECK_RESULT $?
    swig -java -module name example.i
    CHECK_RESULT $?
    test -f name.java -a -f nameJNI.java && rm -rf name.java nameJNI.java
    CHECK_RESULT $?
    swig -java -MP example.i
    CHECK_RESULT $?
    grep -i "exampleJNI" example_wrap.c
    CHECK_RESULT $?
    swig -java -MT target example.i
    CHECK_RESULT $?
    swig -java -nocontract example.i
    CHECK_RESULT $?
    grep -iE "contract|nullreturn" example_wrap.c
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    rm -rf $(ls | grep -vE ".sh|example.i")
    LOG_INFO "End to restore the test environment."
}

main "$@"
