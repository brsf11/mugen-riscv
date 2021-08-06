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
# @Desc      :   The usage of ocamlcp.byte under ocaml package
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
    ocamlcp.byte -P a example.ml
    CHECK_RESULT $?
    strings a.out | grep "a'example"
    CHECK_RESULT $?
    ocamlcp.byte -P f example.ml
    CHECK_RESULT $?
    strings a.out | grep "f'example"
    CHECK_RESULT $?
    ocamlcp.byte -P i example.ml
    CHECK_RESULT $?
    strings a.out | grep "i'example"
    CHECK_RESULT $?
    ocamlcp.byte -P l example.ml
    CHECK_RESULT $?
    strings a.out | grep "l'example"
    CHECK_RESULT $?
    ocamlcp.byte -P m example.ml
    CHECK_RESULT $?
    strings a.out | grep "m'example"
    CHECK_RESULT $?
    ocamlcp.byte -P t example.ml
    CHECK_RESULT $?
    strings a.out | grep "t'example"
    CHECK_RESULT $?
    ocamlcp.byte example.ml
    CHECK_RESULT $?
    strings a.out | grep "fm'example"
    CHECK_RESULT $?
    ocamlcp.byte --help | grep "ocamlcp"
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    rm -rf ./example* a.out ocamlprof.dump
    LOG_INFO "End to restore the test environment."
}

main "$@"
