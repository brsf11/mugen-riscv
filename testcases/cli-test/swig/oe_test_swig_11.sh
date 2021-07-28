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
    swig -tcl -nosafe example.i
    CHECK_RESULT $?
    grep -i "SafeInit" example_wrap.c
    CHECK_RESULT $? 1
    swig -tcl -prefix pre example.i
    CHECK_RESULT $?
    grep -i "define SWIG_prefix" example_wrap.c
    CHECK_RESULT $?
    swig -tcl -namespace example.i
    CHECK_RESULT $?
    grep "define SWIG_namespace" example_wrap.c
    CHECK_RESULT $?
    swig -tcl -pkgversion 3 example.i
    CHECK_RESULT $?
    grep -i "define SWIG_version" example_wrap.c
    CHECK_RESULT $?
    swig -ocaml -features 6 example.i
    CHECK_RESULT $?
    grep -E "SWIG_DivisionByZero|-6" example_wrap.c
    CHECK_RESULT $?
    swig -java -fastdispatch example.i
    CHECK_RESULT $?
    cp -rf example.i example-bak.i
    sed -i '2s/module/modle/g' example.i
    swig -java -Fstandard example.i >standard 2>&1
    CHECK_RESULT $? 1
    grep "example.i:9" standard
    CHECK_RESULT $?
    swig -java -Fmicrosoft example.i >microsoft 2>&1
    CHECK_RESULT $? 1
    grep "example.i(9)" microsoft
    CHECK_RESULT $?
    cp -rf example-bak.i example.i && rm -rf example-bak.i
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    rm -rf $(ls | grep -vE ".sh|example.i")
    LOG_INFO "End to restore the test environment."
}

main "$@"
