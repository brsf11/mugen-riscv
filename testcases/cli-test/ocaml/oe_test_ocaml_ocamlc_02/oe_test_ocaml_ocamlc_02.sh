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
# @Date      :   2020/10/23
# @License   :   Mulan PSL v2
# @Desc      :   The usage of ocamlc under ocaml package
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL ocaml
    cp -rf ../example.ml ../a.c ./
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    ocamlc -annot example.ml
    rm -rf a.out
    ocamlc -compat-32 example.cmo
    CHECK_RESULT $?
    ./a.out | grep 6 && rm -rf a.out
    CHECK_RESULT $?
    ocamlc -dllib -l /usr/lib64/libbfd-*.so a.c
    CHECK_RESULT $?
    test -f a.o && rm -rf a.o
    CHECK_RESULT $?
    ocamlc -dllpath ../ a.c
    CHECK_RESULT $?
    test -f a.o && rm -rf a.o
    CHECK_RESULT $?
    ocamlc -dtypes example.ml
    CHECK_RESULT $?
    grep -A 3 "type" example.annot
    CHECK_RESULT $?
    ocamlc -for-pack P -c example.ml
    CHECK_RESULT $?
    grep -ai "examplep" example.cmo
    CHECK_RESULT $?
    ocamlc -g a.c
    CHECK_RESULT $?
    objdump -x a.o | grep "debug"
    CHECK_RESULT $?
    ocamlc -nostdlib a.c
    CHECK_RESULT $?
    objdump -x a.o | grep "stdlib"
    CHECK_RESULT $? 1
    cp -rf ../hello_stubs.c ./
    ocamlc -i hello_stubs.c
    CHECK_RESULT $?
    objdump -x hello_stubs.o | grep "caml_print_hello"
    CHECK_RESULT $?
    ocamlc -I +/usr/lib64/ocaml hello_stubs.c
    CHECK_RESULT $?
    grep -ai "hello world" hello_stubs.o
    CHECK_RESULT $?
    rm -rf a.out
    cp -rf example.ml exampletest
    ocamlc -impl exampletest
    CHECK_RESULT $?
    grep -ai "exampletest" exampletest.cmi
    CHECK_RESULT $?
    cp -rf /usr/lib64/ocaml/lazy.mli lazytest
    ocamlc -intf lazytest
    CHECK_RESULT $?
    grep -ai "lazytest" lazytest.cmi
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    rm -rf ./a* ./example* ./hello* ./lazytest*
    LOG_INFO "End to restore the test environment."
}

main "$@"
