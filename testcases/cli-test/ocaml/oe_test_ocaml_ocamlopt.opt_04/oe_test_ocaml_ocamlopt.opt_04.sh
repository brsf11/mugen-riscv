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
# @Date      :   2020/11/9
# @License   :   Mulan PSL v2
# @Desc      :   The usage of ocamlopt.opt under ocaml package
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL ocaml
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    ocamlopt.opt -depend -all /usr/lib64/ocaml/filename.ml | grep -E ".o|.cmi|.cmo|.cmx"
    CHECK_RESULT $?
    ocamlopt.opt -depend -all /usr/lib64/ocaml/filename.ml | grep -c "filename" | grep -E "4|6"
    CHECK_RESULT $?
    ocamlopt.opt -depend -all -one-line /usr/lib64/ocaml/filename.ml | grep -c "filename" | grep 2
    CHECK_RESULT $?
    ocamlopt.opt -depend -allow-approx /usr/lib64/ocaml/filename.ml | grep -E ".cmo|.cmi|.cmx"
    CHECK_RESULT $?
    ocamlopt.opt -depend -as-map /usr/lib64/ocaml/filename.ml | grep -E "\.o"
    CHECK_RESULT $? 1
    ocamlopt.opt -depend -debug-map /usr/lib64/ocaml/filename.ml | grep -c "cmi" | grep 2
    CHECK_RESULT $?
    ocamlopt.opt -depend -I /usr/lib64/ocaml /usr/lib64/ocaml/filename.ml | grep -E "string|printf|buffer|random|lazy|filename"
    CHECK_RESULT $?
    ocamlopt.opt -depend -impl /usr/lib64/ocaml/filename.ml | grep -E "\.ml"
    CHECK_RESULT $? 1
    ocamlopt.opt -depend -intf /usr/lib64/ocaml/filename.mli /usr/lib64/ocaml/filename.ml | grep -c "cmi" | grep 3
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}

main "$@"
