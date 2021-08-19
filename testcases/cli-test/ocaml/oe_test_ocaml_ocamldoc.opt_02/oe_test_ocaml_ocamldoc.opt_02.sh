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
# @Date      :   2020/10/28
# @License   :   Mulan PSL v2
# @Desc      :   The usage of ocamldoc.opt under ocaml package
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
    ocamldoc.opt -dump ocamldoc.dump example.ml
    ocamldoc.opt -verbose -load ocamldoc.dump | grep "Loading ocamldoc.dump"
    CHECK_RESULT $?
    ocamldoc.opt -man example.ml
    CHECK_RESULT $?
    grep -E "Module|Example" Example.3o
    CHECK_RESULT $?
    ocamldoc.opt -dot -o ocaml.out example.ml
    CHECK_RESULT $?
    grep "digraph" ocaml.out
    CHECK_RESULT $?
    ocamldoc.opt -latex -t ocamlll example.ml
    CHECK_RESULT $?
    grep "ocamlll" ocamldoc.out
    CHECK_RESULT $?
    ocamldoc.opt -latex -intro example.ml
    CHECK_RESULT $?
    grep "let plus" ocamldoc.out
    CHECK_RESULT $?
    ocamldoc.opt -v example.ml | grep -i "ocaml"
    CHECK_RESULT $?
    ocaml_version=$(rpm -qa ocaml | awk -F '-' '{print $2}')
    ocamldoc.opt -version example.ml | grep "$ocaml_version"
    CHECK_RESULT $?
    ocamldoc.opt -help | grep "ocamldoc"
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    rm -rf Example.3o example.ml ./ocaml* plus3.3o
    LOG_INFO "End to restore the test environment."
}

main "$@"
