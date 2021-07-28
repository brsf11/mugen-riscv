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
    swig -java -debug-tmused example.i | grep -i "typemap"
    CHECK_RESULT $?
    swig -java -debug-template example.i
    CHECK_RESULT $?
    grep -i "template" example_wrap.c
    CHECK_RESULT $?
    swig -java -directors example.i
    CHECK_RESULT $?
    grep -i "director" example_wrap.c
    CHECK_RESULT $?
    swig -java -dirprot example.i
    CHECK_RESULT $?
    grep -i "jclass excep" -A 20 example_wrap.c
    CHECK_RESULT $?
    swig -d -D example.i
    CHECK_RESULT $?
    grep " D " example_wrap.c
    CHECK_RESULT $?
    swig -java -E example.i | grep -E ' swig.swg|typemap|rename predicates|endoffile'
    CHECK_RESULT $?
    cp -rf example.i example-bak.i
    swig -java -external-runtime example.i
    CHECK_RESULT $?
    diff example.i example-bak.i >log
    CHECK_RESULT $? 1
    cp -rf example-bak.i example.i
    swig -java -fakeversion 6 example.i
    CHECK_RESULT $?
    grep -i "version 6" example.java
    CHECK_RESULT $?
    rm -rf example_wrap.c
    swig -java -fcompact example.i
    CHECK_RESULT $?
    grep "int arg1 ; int arg2 ;" example_wrap.c
    CHECK_RESULT $? 0
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    rm -rf $(ls | grep -vE ".sh|example.i") example_im.d
    LOG_INFO "End to restore the test environment."
}

main "$@"
