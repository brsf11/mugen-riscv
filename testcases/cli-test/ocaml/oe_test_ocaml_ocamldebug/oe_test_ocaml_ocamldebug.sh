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
    mkdir ocamltest
    ocaml_version=$(rpm -qa ocaml | awk -F '-' '{print $2}')
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    ocamlc -g example.ml
    ocamldebug -c 2 a.out >log <<EOF
    run
    quit
EOF
    grep -i "Loading program... 6" log
    CHECK_RESULT $?
    cp a.out ocamltest/ && rm -rf a.ou
    ocamldebug -cd ./ocamltest a.out >log <<EOF
    run
    quit
EOF
    grep -i "Loading program... 6" log
    CHECK_RESULT $?
    cp ocamltest/a.out ./
    ocamldebug -emacs a.out >log <<EOF
    run
    quit
EOF
    grep "H" log
    CHECK_RESULT $?
    ocamldebug -I /usr/lib64/ocaml/ a.out >log <<EOF
    run
    quit
EOF
    grep -i "Program exit" log
    CHECK_RESULT $?
    ocamldebug -machine-readable a.out >log <<EOF
    run
    quit
EOF
    grep "(ocd)" log
    CHECK_RESULT $?
    ocamldebug -version a.out | grep "The OCaml debugger, version $ocaml_version"
    CHECK_RESULT $?
    ocamldebug -vnum a.out | grep "$ocaml_version"
    CHECK_RESULT $?
    ocamldebug -no-version a.out >log <<EOF
    quit
EOF
    grep "version" log
    CHECK_RESULT $? 1
    ocamldebug -no-prompt a.out >log <<EOF
    quit
EOF
    grep "(ocd)" log
    CHECK_RESULT $? 1
    ocamldebug -no-time a.out >log <<EOF
    run
    quit
EOF
    grep -i "time" log
    CHECK_RESULT $? 1
    ocamldebug -no-breakpoint-message a.out >log <<EOF
    goto 5
    break
    delet 1
    quit
EOF
    grep -i "breakpoint" log
    CHECK_RESULT $? 1
    ocamldebug --help | grep "help"
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    rm -rf a.out log ./example* ocamltest
    LOG_INFO "End to restore the test environment."
}

main "$@"
