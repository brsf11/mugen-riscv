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
    ocaml_version=$(rpm -qa ocaml | awk -F '-' '{print $2}')
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    ocamlmklib.byte -v -ldopt example.o example.ml | grep "dllib"
    CHECK_RESULT $?
    ocamlmklib.byte -vnum example.o | grep "$ocaml_version"
    CHECK_RESULT $?
    ocamlmklib.byte -l example.cmo
    CHECK_RESULT $?
    grep -a "Stdlib" a.cma
    CHECK_RESULT $?
    ocamlmklib.byte -verbose example.ml | grep "/usr/bin/ocaml"
    CHECK_RESULT $?
    ocamlmklib.byte -version example.o | grep "$ocaml_version"
    CHECK_RESULT $?
    ocamlmklib.byte -oc example example.o
    CHECK_RESULT $?
    grep -ai "gcc" dllexample.so
    CHECK_RESULT $?
    ocamlmklib.byte -help 2>&1 | grep "ocamlmklib"
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    rm -rf a.a a.cmxa dlla.so ./example* liba.a a.cma a.out dllexample.so help libexample.a
    LOG_INFO "End to restore the test environment."
}

main "$@"
