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
    cp ../example.ml ./
    ocaml_version=$(rpm -qa ocaml | awk -F '-' '{print $2}')
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    ocamlc -g example.ml
    ocamlrun a.out | grep "6"
    CHECK_RESULT $?
    ocamlrund a.out 2>&1 | grep "runtime"
    CHECK_RESULT $?
    ocamlruni -v a.out | grep "6"
    CHECK_RESULT $?
    ocamlyacc test.mly
    CHECK_RESULT $?
    grep "parser" test.ml
    CHECK_RESULT $?
    grep "token" test.mli
    CHECK_RESULT $?
    ocamlyacc -b pre test.mly
    CHECK_RESULT $?
    test -f pre.ml -a -f pre.mli
    CHECK_RESULT $?
    ocamlyacc -v test.mly
    CHECK_RESULT $?
    grep "state" test.output
    CHECK_RESULT $?
    ocamlyacc -version test.mly | grep "$ocaml_version"
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    rm -rf example* test.ml test.mli test.output pre* a.out runlog
    LOG_INFO "End to restore the test environment."
}

main "$@"
