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
# @Date      :   2020/11/6
# @License   :   Mulan PSL v2
# @Desc      :   The usage of ocamloptp under ocaml package
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL ocaml
    cp ../a.c ../file.ml ../example.ml ./
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    ocamloptp -a -o a.o a.c
    CHECK_RESULT $?
    grep -aE "Caml|a.o" a.o
    CHECK_RESULT $?
    ocamloptp -annot example.ml
    CHECK_RESULT $?
    ./a.out | grep "6"
    CHECK_RESULT $?
    ocamloptp -bin-annot example.ml
    CHECK_RESULT $?
    ocamlcmt -info example.cmt | grep "module name" -A 15
    CHECK_RESULT $?
    ocamloptp -c a.c
    CHECK_RESULT $?
    grep -ai "editor" a.o
    CHECK_RESULT $?
    ocamloptp -color auto a.c
    CHECK_RESULT $?
    grep -a "rela.eh_frame" a.o
    CHECK_RESULT $?
    ocamloptp -absname file.ml >result 2>&1
    CHECK_RESULT $? 0 1
    grep "/tmp" result
    CHECK_RESULT $?
    ocamloptp -config a.c | grep -E "version|ocamlc" -A 55
    CHECK_RESULT $?
    ocamloptp -annot example.ml
    rm -rf a.out
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    rm -rf ./a* ./example* ./hello* file.ml result ocamlprof.dump
    LOG_INFO "End to restore the test environment."
}

main "$@"
