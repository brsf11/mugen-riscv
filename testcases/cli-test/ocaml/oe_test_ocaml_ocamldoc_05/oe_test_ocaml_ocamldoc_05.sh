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
# @Date      :   2020/10/29
# @License   :   Mulan PSL v2
# @Desc      :   The usage of ocamldoc under ocaml package
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL ocaml
    cp ../example.ml ./
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    ocamldoc -dot -dot-colors Red example.ml
    CHECK_RESULT $?
    grep "Red" ocamldoc.out
    CHECK_RESULT $?
    cp /usr/lib64/ocaml/filename.ml ./
    ocamldoc -dot -dot-include-all filename.ml
    CHECK_RESULT $?
    grep "Buffer" ocamldoc.out
    CHECK_RESULT $?
    ocamldoc -verbose -dot -dot-reduce example.ml | grep "Analysing file example.ml"
    CHECK_RESULT $?
    ocamldoc -dot -dot-types example.ml
    CHECK_RESULT $?
    grep "style" ocamldoc.out
    CHECK_RESULT $? 1
    ocamldoc -man -man-mini example.ml
    CHECK_RESULT $?
    test -f plus3.3o
    CHECK_RESULT $? 0 1
    ocamldoc -man -man-suffix suffix example.ml
    CHECK_RESULT $?
    grep "plus3" plus3.suffix
    CHECK_RESULT $?
    ocamldoc -man -man-section 100 example.ml
    CHECK_RESULT $?
    grep "100" plus3.3o
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    rm -rf Example.3o ./*ml ocamldoc.out ./*suffix plus3.3o
    LOG_INFO "End to restore the test environment."
}

main "$@"
