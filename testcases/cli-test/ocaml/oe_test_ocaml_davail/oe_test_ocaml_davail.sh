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
# @Date      :   2020/10/27
# @License   :   Mulan PSL v2
# @Desc      :   The usage of davail under ocaml package
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL ocaml
    cp -rf ../example.ml ../hello_stubs.c ../hello.ml ./
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    ocamlmktop -unsafe-string example.ml
    CHECK_RESULT $?
    grep -ai "unsafe" a.out && rm -rf a.out
    CHECK_RESULT $?
    ocamlmktop.opt -unsafe-string example.ml
    CHECK_RESULT $?
    grep -ai "unsafe" a.out && rm -rf a.out
    CHECK_RESULT $?
    ocamlmktop.byte -unsafe-string example.ml
    CHECK_RESULT $?
    grep -ai "unsafe" a.out && rm -rf a.out
    CHECK_RESULT $?
    ocamlopt.byte -davail example.ml
    CHECK_RESULT $?
    grep -az vail a.out
    CHECK_RESULT $?
    ocamlopt.opt -davail example.ml
    CHECK_RESULT $?
    grep -az vail a.out
    CHECK_RESULT $?
    ocamloptp.byte -davail example.ml
    CHECK_RESULT $?
    grep -az "vail" a.out
    CHECK_RESULT $?
    ocamloptp -davail example.ml
    CHECK_RESULT $?
    grep -az vail a.out
    CHECK_RESULT $?
    ocamlopt -davail example.ml
    CHECK_RESULT $?
    grep -az vail a.out
    CHECK_RESULT $?
    ocamloptp.opt -davail example.ml
    CHECK_RESULT $?
    grep -az vail a.out
    CHECK_RESULT $?
    ocamlmklib.byte -dllpath /tmp example.o
    CHECK_RESULT $?
    strings dlla.so | grep "/tmp"
    CHECK_RESULT $?
    ocamlmklib.byte -rpath /tmp example.o
    CHECK_RESULT $?
    strings dlla.so | grep "/tmp" && rm -rf dlla.so
    CHECK_RESULT $?
    ocamlmklib.byte -R /tmp example.o
    CHECK_RESULT $?
    strings dlla.so | grep "/tmp"
    CHECK_RESULT $?
    ocamlmklib.opt -dllpath /tmp example.o
    CHECK_RESULT $?
    strings dlla.so | grep "/tmp"
    CHECK_RESULT $?
    ocamlmklib.opt -rpath /tmp example.o
    CHECK_RESULT $?
    strings dlla.so | grep "/tmp" && rm -rf dlla.so
    CHECK_RESULT $?
    ocamlmklib.opt -R /tmp example.o
    CHECK_RESULT $?
    strings dlla.so | grep "/tmp"
    CHECK_RESULT $?
    ocamlmklib -dllpath /tmp example.o
    CHECK_RESULT $?
    strings dlla.so | grep "/tmp"
    CHECK_RESULT $?
    ocamlmklib -rpath /tmp example.o
    CHECK_RESULT $?
    strings dlla.so | grep "/tmp" && rm -rf dlla.so
    CHECK_RESULT $?
    ocamlmklib -R /tmp example.o
    CHECK_RESULT $?
    strings dlla.so | grep "/tmp"
    CHECK_RESULT $?
    ocamlmktop -o hellotop.exe -custom hello_stubs.c hello.ml
    ocamlbyteinfo hellotop.exe | grep -E "Imported|caml"
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    rm -rf a.* dlla* example* hello* liba.a ocamlprof.dump
    LOG_INFO "End to restore the test environment."
}

main "$@"
