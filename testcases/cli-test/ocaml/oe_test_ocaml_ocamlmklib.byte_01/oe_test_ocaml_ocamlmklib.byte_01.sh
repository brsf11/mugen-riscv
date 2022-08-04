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
# @Date      :   2020/11/2
# @License   :   Mulan PSL v2
# @Desc      :   The usage of ocamlmklib, ocamlmklib.opt and ocamlmklib.byte in ocaml package
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
    ocamlc -g example.ml
    ocamlmklib.byte -o example example.cmo
    CHECK_RESULT $?
    grep -ai "example" example.cma
    CHECK_RESULT $?
    ocamlc -a example.ml -o c
    ocamlmklib.byte -v -cclib c example.ml | grep "ocamlc -a" | grep cclib
    CHECK_RESULT $?
    ocamlmklib.byte -v -ccopt c example.ml | grep "ocamlc -a" | grep ccopt
    CHECK_RESULT $?
    ocamlmklib.byte -v -custom example.o | grep "gcc"
    CHECK_RESULT $? 1
    ocamlmklib.byte -v -g example.ml
    CHECK_RESULT $?
    objdump -x example.o | grep debug
    CHECK_RESULT $?
    ocamlmklib.byte -linkall example.o
    CHECK_RESULT $?
    objdump -x example.o | grep "camlStdlib"
    CHECK_RESULT $?
    ocamlmklib.byte -v -I /tmp example.ml | grep "tmp"
    CHECK_RESULT $?
    ocamlmklib.byte -failsafe example.o
    CHECK_RESULT $?
    grep -a "example.ml" example.o
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    rm -rf a.a a.cmxa c dlla.so ./example* a.cma a.out liba.a
    LOG_INFO "End to restore the test environment."
}

main "$@"
