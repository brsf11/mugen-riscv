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
    ocamldoc.opt -latex -notoc example.ml
    CHECK_RESULT $?
    grep "tableofcontents" ocamldoc.out
    CHECK_RESULT $? 1
    ocamldoc.opt -latex -notrailer example.ml
    CHECK_RESULT $?
    grep "end{document}" ocamldoc.out
    CHECK_RESULT $? 1
    ocamldoc.opt -latex -sepfiles example.ml
    CHECK_RESULT $?
    grep -Ei "module|example" Example.tex
    CHECK_RESULT $?
    ocamldoc.opt -texi -esc8 example.ml
    CHECK_RESULT $?
    grep "Indices" ocamldoc.texi
    CHECK_RESULT $?
    ocamldoc.opt -texi -info-entry example.ml
    CHECK_RESULT $?
    grep "@direntry"$'\n'"example.ml"$'\n'"@end direntry" ocamldoc.texi
    CHECK_RESULT $?
    ocamldoc.opt -texi -info-section example.ml
    CHECK_RESULT $?
    grep "@dircategory example.ml" ocamldoc.texi
    CHECK_RESULT $?
    ocamldoc.opt -texi -noheader example.ml
    CHECK_RESULT $?
    grep "start of header" ocamldoc.texi
    CHECK_RESULT $? 1
    ocamldoc.opt -texi -noindex example.ml
    CHECK_RESULT $?
    grep "index" ocamldoc.texi
    CHECK_RESULT $? 1
    ocamldoc.opt -texi -notrailer example.ml
    CHECK_RESULT $?
    grep "@bye" ocamldoc.texi
    CHECK_RESULT $? 1
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    rm -rf example.ml Example.tex ./ocamldoc*
    LOG_INFO "End to restore the test environment."
}

main "$@"
