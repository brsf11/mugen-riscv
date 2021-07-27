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
    swig -java -debug-symtabs example.i | grep -i "symbol tables"
    CHECK_RESULT $?
    swig -java -debug-symbols example.i | grep -i "symbols"
    CHECK_RESULT $?
    swig -java -debug-csymbols example.i | grep -i "csymbols"
    CHECK_RESULT $?
    swig -java -debug-lsymbols example.i | grep -i "language symbols"
    CHECK_RESULT $?
    swig -java -debug-tags example.i | grep -i "include"
    CHECK_RESULT $?
    swig -java -debug-top 3 example.i | grep -i "debug-top stage 3"
    CHECK_RESULT $?
    swig -java -debug-typedef example.i | grep -i "scope"
    CHECK_RESULT $?
    swig -java -debug-typemap example.i | grep -i "typemap"
    CHECK_RESULT $?
    swig -java -debug-tmsearch example.i | grep -i "search"
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
