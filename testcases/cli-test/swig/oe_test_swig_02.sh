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
    swig -octave -v example.i | grep "octave"
    CHECK_RESULT $?
    test -f example_wrap.cxx && rm -rf example_wrap.cxx
    CHECK_RESULT $?
    swig -perl -v example.i | grep "perl"
    CHECK_RESULT $?
    test -f example.pm -a -f example_wrap.c && rm -rf example.pm example_wrap.c
    CHECK_RESULT $?
    swig -php7 -v example.i | grep "php"
    CHECK_RESULT $?
    test -f example.php -a -f example_wrap.c -a -f php_example.h && rm -rf example.php example_wrap.c php_example.h
    CHECK_RESULT $?
    swig -python -v example.i | grep "python"
    CHECK_RESULT $?
    test -f example.py -a -f example_wrap.c && rm -rf example.py example_wrap.c
    CHECK_RESULT $?
    swig -r -v example.i | grep "subdirectory: r"
    CHECK_RESULT $?
    test -f example.R -a -f example_wrap.c && rm -rf example.R example_wrap.c
    CHECK_RESULT $?
    swig -ruby -v example.i | grep "ruby"
    CHECK_RESULT $?
    test -f example_wrap.c && rm -rf example_wrap.c
    CHECK_RESULT $?
    swig -scilab -v example.i | grep "scilab"
    CHECK_RESULT $?
    test -f example_wrap.c -a -f loader.sce && rm -rf example_wrap.c loader.sce
    CHECK_RESULT $?
    swig -tcl -v example.i | grep "tcl"
    CHECK_RESULT $?
    test -f example_wrap.c && rm -rf example_wrap.c
    CHECK_RESULT $?
    swig -xml -c++ example.i
    CHECK_RESULT $?
    test -f example_wrap.xml && rm -rf example_wrap.xml
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}

main "$@"
