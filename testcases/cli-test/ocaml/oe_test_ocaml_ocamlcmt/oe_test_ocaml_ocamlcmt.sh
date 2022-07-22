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
# @Date      :   2020/10/21
# @License   :   Mulan PSL v2
# @Desc      :   The usage of ocamlcmt, ocamldebug and other commands in ocaml package
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL ocaml
    cp -rf ../example.ml ../hello_stubs.c ../hello.ml ./
    ocamlc -bin-annot example.ml
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    ocamlcmt -o file.cmt example.cmt
    CHECK_RESULT $?
    grep -iE "example|ocamlcmt" file.cmt
    CHECK_RESULT $?
    ocamlcmt -annot example.cmt
    CHECK_RESULT $?
    grep "example" example.cmt.annot
    CHECK_RESULT $?
    ocamlcmt -save-cmt-info example.cmt | grep "import"
    CHECK_RESULT $?
    ocamlcmt -src example.cmt
    CHECK_RESULT $?
    grep "plus" example.cmt.ml
    CHECK_RESULT $?
    ocamlcmt -info example.cmt | grep "module name" -A 15
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    rm -rf a.out ./example* file.cmt ./hello*
    LOG_INFO "End to restore the test environment."
}

main "$@"
