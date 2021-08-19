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
    swig -csharp -v example.i | grep "csharp"
    CHECK_RESULT $?
    test -f example.cs -a -f examplePINVOKE.cs -a -f example_wrap.c && rm -rf example.cs examplePINVOKE.cs example_wrap.c
    CHECK_RESULT $?
    swig -d -v example.i | grep "d"
    CHECK_RESULT $?
    test -f example.d -a -f example_im.d -a -f example_wrap.c && rm -rf example.d example_im.d example_wrap.c
    CHECK_RESULT $?
    swig -go -v -intgosize 32 example.i | grep "go"
    CHECK_RESULT $?
    test -f example.go -a -f example_wrap.c && rm -rf example_gc.c example.go example_wrap.c
    CHECK_RESULT $?
    swig -guile -v example.i | grep "guile"
    CHECK_RESULT $?
    test -f example_wrap.c && rm -rf example_wrap.c
    CHECK_RESULT $?
    swig -java -v example.i | grep "java"
    CHECK_RESULT $?
    test -f example.java -a -f exampleJNI.java -a -f example_wrap.c && rm -rf example.java exampleJNI.java example_wrap.c
    CHECK_RESULT $?
    swig -javascript -v8 -v example.i | grep "javascript/v8"
    CHECK_RESULT $?
    test -f example_wrap.c && rm -rf example_wrap.c
    CHECK_RESULT $?
    swig -lua -v example.i | grep "lua"
    CHECK_RESULT $?
    test -f example_wrap.c && rm -rf example_wrap.c
    CHECK_RESULT $?
    swig -mzscheme -v example.i | grep "mzscheme"
    CHECK_RESULT $?
    test -f example_wrap.c && rm -rf example_wrap.c
    CHECK_RESULT $?
    swig -ocaml -v example.i | grep "ocaml"
    CHECK_RESULT $?
    test -f example.ml -a -f example.mli -a -f example_wrap.c && rm -rf example.ml example.mli example_wrap.c
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}

main "$@"
