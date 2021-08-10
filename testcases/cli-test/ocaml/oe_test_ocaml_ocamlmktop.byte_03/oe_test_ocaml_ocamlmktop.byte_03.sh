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
# @Desc      :   The usage of ocamlmktop.byte under ocaml package
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL ocaml
    cp ../a.c ../example.ml ../hello.ml ./
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    cp /usr/lib64/ocaml/lazy.mli lazy.mli
    ocamlmktop.byte -intf-suffix mli lazy.mli
    CHECK_RESULT $?
    grep -ai "lazy" lazy.cmi
    CHECK_RESULT $?
    ocamlmktop.byte -alias-deps example.ml
    CHECK_RESULT $?
    grep -ai "alias" a.out && rm -rf a.out
    CHECK_RESULT $?
    ocamlmktop.byte -keep-locs example.ml
    CHECK_RESULT $?
    grep -ai "locs" a.out && rm -rf a.out
    CHECK_RESULT $?
    ocamlmktop.byte -app-funct example.ml
    CHECK_RESULT $?
    grep -ai "app-funct" a.out && rm -rf a.out
    CHECK_RESULT $?
    ocamlmktop.byte -labels example.ml
    CHECK_RESULT $?
    grep -ai "labels" a.out && rm -rf a.out
    CHECK_RESULT $?
    ocamlmktop.byte -linkall example.ml
    CHECK_RESULT $?
    grep -ai "linkall" a.out && rm -rf a.out
    CHECK_RESULT $?
    ocamlmktop.byte -keep-docs example.ml
    CHECK_RESULT $?
    grep -ai "docs" a.out && rm -rf a.out
    CHECK_RESULT $?
    ocamlmktop.byte -safe-string example.ml
    CHECK_RESULT $?
    grep -ai "safe" a.out && rm -rf a.out
    CHECK_RESULT $?
    ocamlmktop.byte -open Printf example.ml
    CHECK_RESULT $?
    grep -a "Printf" a.out && rm -rf a.out
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    rm -rf ./a* ./example* ./hello* ./lazy* result
    LOG_INFO "End to restore the test environment."
}

main "$@"
