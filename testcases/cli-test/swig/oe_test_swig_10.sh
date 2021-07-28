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
    swig -java -notemplatereduce example.i
    CHECK_RESULT $?
    grep -i "reduce" example_wrap.c
    CHECK_RESULT $? 1
    swig -java -O example.i
    CHECK_RESULT $?
    grep -i "mod" example_wrap.c
    CHECK_RESULT $?
    swig -java -c++ -o outfile example.i
    CHECK_RESULT $?
    test -f outfile
    CHECK_RESULT $?
    swig -java -outcurrentdir example.i
    CHECK_RESULT $?
    test -f example.java -a -f exampleJNI.java -a -f example_wrap.c && example.java exampleJNI.java example_wrap.c
    swig -java -outdir /tmp example.i
    CHECK_RESULT $?
    test -f /tmp/example.java -a -f /tmp/exampleJNI.java && rm -rf /tmp/example.java /tmp/exampleJNI.java
    CHECK_RESULT $?
    swig -java -pcreversion example.i | grep -i "pcre version"
    CHECK_RESULT $?
    swig -java example.i
    cp -rf example_wrap.c example_wrap.c-bak
    swig -java -small example.i
    CHECK_RESULT $?
    diff -q example_wrap.c example_wrap.c-bak
    CHECK_RESULT $? 0 1
    swig -java -swiglib example.i | grep "/usr/share/swig"
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
