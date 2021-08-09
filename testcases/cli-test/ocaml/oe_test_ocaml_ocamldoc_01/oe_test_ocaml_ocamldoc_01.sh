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
# @Date      :   2020/10/29
# @License   :   Mulan PSL v2
# @Desc      :   The usage of ocamldoc under ocaml package
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL ocaml
    cp ../example.ml ../file.ml ./
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    ocamldoc -absname file.ml >result 2>&1
    CHECK_RESULT $? 1
    grep "/file.ml" result
    CHECK_RESULT $?
    ocamldoc -dot -I /usr/lib64/ocaml/ocamldoc example.ml
    CHECK_RESULT $?
    grep "Example" ocamldoc.out
    CHECK_RESULT $?
    ocamlc -g example.ml
    CHECK_RESULT $?
    ocamldoc -g example.cmo | grep "6"
    CHECK_RESULT $?
    ocamldoc -customdir example.ml | grep "/usr/lib64/ocaml/ocamldoc/custom"
    CHECK_RESULT $?
    mkdir /tmp/ocamldoc
    ocamldoc -d /tmp/ocamldoc -html example.ml
    CHECK_RESULT $?
    grep -i "html" /tmp/ocamldoc/Example.html
    CHECK_RESULT $?
    ocamldoc -dump ocamldoc.dump example.ml
    CHECK_RESULT $?
    grep -a "example.ml" ocamldoc.dump
    CHECK_RESULT $?
    ocamldoc -latex example.ml
    CHECK_RESULT $?
    grep "ocamldoc" ocamldoc.sty
    CHECK_RESULT $?
    ocamldoc -texi example.ml
    CHECK_RESULT $?
    grep -iE "texinfo|example" ocamldoc.texi
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    rm -rf ./a* ./example* /tmp/ocamldoc example.ml file.ml ./ocamldoc* result
    LOG_INFO "End to restore the test environment."
}

main "$@"
