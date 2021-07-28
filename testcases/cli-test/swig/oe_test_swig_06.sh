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
    swig -java -fvirtual example.i
    CHECK_RESULT $?
    grep -i "virtual" example_wrap.c
    CHECK_RESULT $?
    swig -java -I- example.i
    CHECK_RESULT $?
    grep -i "/swig" example_wrap.c
    CHECK_RESULT $?
    current_path=$(
        cd "$(dirname $0)" || exit 1
        pwd
    )
    swig -module swig -java -I ${current_path}/
    CHECK_RESULT $?
    test -f swig.java -a -f swigJNI.java -a -f _wrap.c
    CHECK_RESULT $?
    swig -java -ignoremissing example.i
    CHECK_RESULT $?
    grep -i "miss" example_wrap.c
    CHECK_RESULT $? 1
    swig -java -importall example.i
    CHECK_RESULT $?
    grep -i "#include" example_wrap.c
    CHECK_RESULT $?
    swig -java -includeall example.i
    CHECK_RESULT $?
    grep -i "#include <jni.h>"$'\n'"#include <stdlib.h>"$'\n'"#include <string.h>" example_wrap.c
    CHECK_RESULT $?
    swig -java -lexample.i example.i
    CHECK_RESULT $?
    grep "example" example_wrap.c
    CHECK_RESULT $?
    swig -java -macroerrors example.i
    CHECK_RESULT $?
    grep -i "macro" example_wrap.c
    CHECK_RESULT $?
    swig -java -makedefault example.i
    CHECK_RESULT $?
    grep -i "default" example_wrap.c
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
