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
# @Date      :   2020/11/4
# @License   :   Mulan PSL v2
# @Desc      :   The usage of ocamlmktop.opt under ocaml package
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL ocaml
    cp ../a.c ../example.ml ./
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    ocamlmktop.opt -principal example.ml
    CHECK_RESULT $?
    grep -ai "principal" a.out && rm -rf a.out
    CHECK_RESULT $?
    ocamlmktop.opt -rectypes example.ml
    CHECK_RESULT $?
    grep -ai "rectypes" a.out && rm -rf a.out
    CHECK_RESULT $?
    ocamlmktop.opt -strict-sequence example.ml
    CHECK_RESULT $?
    grep -ai "sequence" a.out && rm -rf a.out
    CHECK_RESULT $?
    ocamlmktop.opt -strict-formats example.ml
    CHECK_RESULT $?
    grep -ai "formats" a.out && rm -rf a.out
    CHECK_RESULT $?
    ocamlmktop.opt -unboxed-types example.ml
    CHECK_RESULT $?
    grep -ai "unboxed" a.out && rm -rf a.out
    CHECK_RESULT $?
    ocamlmktop.opt -w +a-4-6-7-9-27-29-32..42-44-45-48-50-60 example.ml
    CHECK_RESULT $?
    grep -aiE "+a-4-6-7-9-27-29-32..42-44-45-48-50-60|+a-4-7-9-27-29-30-32..42-44-45-48-50-60-66..70" a.out && rm -rf a.out
    CHECK_RESULT $?
    ocamlmktop.opt -warn-error -a+31 example.ml
    CHECK_RESULT $?
    grep -ai "a+31" a.out && rm -rf a.out
    CHECK_RESULT $?
    ocamlmktop.opt -no-keep-locs -no-alias-deps -no-app-funct -nolabels -no-check-prims -noassert -noautolink -no-keep-docs -no-principal -no-rectypes -no-strict-sequence -no-strict-formats -no-unboxed-types example.ml
    CHECK_RESULT $?
    grep -a "none" example.cmi
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    rm -rf ./a* ./example*
    LOG_INFO "End to restore the test environment."
}

main "$@"
