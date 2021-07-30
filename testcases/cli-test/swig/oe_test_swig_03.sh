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
# @Date      :   2020/10/14
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
    swig -help | grep swig
    CHECK_RESULT $?
    swig -java -addextern example.i
    CHECK_RESULT $?
    grep "extern double My_variable;"$'\n'"int fact(int);" example_wrap.c
    CHECK_RESULT $?
    test -f example.java -a -f exampleJNI.java && rm -rf example.java exampleJNI.java example_wrap.c
    CHECK_RESULT $?
    swig -java -c++ -v example.i | grep "C++ analysis"
    CHECK_RESULT $?
    grep "ThrowNew(excep, msg)" example_wrap.cxx
    CHECK_RESULT $?
    test -f example.java -a -f exampleJNI.java && rm -rf example.java exampleJNI.java example_wrap.cxx
    CHECK_RESULT $?
    swig -java -copyctor example.i
    CHECK_RESULT $?
    grep "ctor" example_wrap.c
    CHECK_RESULT $?
    test -f example.java -a -f exampleJNI.java && rm -rf example.java exampleJNI.java example_wrap.c
    CHECK_RESULT $?
    swig -java -cpperraswarn example.i
    CHECK_RESULT $?
    grep -iE "err|warn" example_wrap.c
    CHECK_RESULT $?
    test -f example.java -a -f exampleJNI.java && rm -rf example.java exampleJNI.java example_wrap.c
    CHECK_RESULT $?
    swig -guile -c++ -cppext json example.i
    CHECK_RESULT $?
    test -f example_wrap.json && rm -rf example_wrap.json
    CHECK_RESULT $?
    swig -java -copyright example.i | grep -i "copyright"
    CHECK_RESULT $?
    swig -java -debug-classes example.i | grep -i "classes"
    CHECK_RESULT $?
    swig -java -debug-module 3 example.i | grep "debug-module stage 3"
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
