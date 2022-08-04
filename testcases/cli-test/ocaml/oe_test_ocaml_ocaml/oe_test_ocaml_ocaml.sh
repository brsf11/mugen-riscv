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
# @Date      :   2020/10/22
# @License   :   Mulan PSL v2
# @Desc      :   The usage of ocaml under ocaml package
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL ocaml
    cp -rf ../hello.ml ../example.ml ./
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    ocaml -help | grep "ocaml"
    CHECK_RESULT $?
    ocaml -absname hello.ml >result 2>&1
    CHECK_RESULT $? 0 1
    grep "/hello.ml" result
    CHECK_RESULT $?
    mkdir ocamldir
    ocaml -I ocamldir/ example.ml | grep "6"
    CHECK_RESULT $?
    ocaml -no-app-funct -no-alias-deps -nolabels -noassert -noinit -noprompt -nopromptcont -no-principal -no-rectypes -no-strict-sequence -no-strict-formats -no-version example.ml | grep "6"
    CHECK_RESULT $?
    ocaml -alias-deps -app-funct -labels -open Printf -principal -rectypes example.ml | grep "6"
    CHECK_RESULT $?
    ocaml -safe-string -strict-sequence -strict-formats -unboxed-types -unsafe example.ml | grep "6"
    CHECK_RESULT $?
    ocaml -version example.ml | grep "version"
    CHECK_RESULT $?
    ocaml_version=$(rpm -qa ocaml | awk -F '-' '{print $2}')
    ocaml -vnum example.ml | grep $ocaml_version
    CHECK_RESULT $?
    ocaml -w +a-4-6-7-9-27-29-32..42-44-45-48-50-60 -warn-error -a+31 -short-paths example.ml | grep "6"
    CHECK_RESULT $?
    ocaml -warn-help example.ml | grep "warning"
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    rm -rf hello.ml example.ml ocamldir result
    LOG_INFO "End to restore the test environment."
}

main "$@"
