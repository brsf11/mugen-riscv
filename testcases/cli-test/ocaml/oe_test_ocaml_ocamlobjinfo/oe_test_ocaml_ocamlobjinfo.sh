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
# @Desc      :   The usage of ocamllex, ocamlobjinfo and other commands in ocaml package
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL ocaml
    ocaml_version=$(rpm -qa ocaml | awk -F '-' '{print $2}')
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    ocamlobjinfo -no-approx example.cmi | grep -iE "file|unit|interfaces"
    CHECK_RESULT $?
    ocamlobjinfo -no-code example.cmi | grep -iE "file|unit|interfaces|57c"
    CHECK_RESULT $?
    ocamlobjinfo -null-crc example.cmi | grep -iE "file|unit|interfaces|000"
    CHECK_RESULT $?
    echo "example.cmi" >tmp
    ocamlobjinfo -args tmp | grep -iE "file|unit|interfaces|57c"
    CHECK_RESULT $?
    ocamlobjinfo -help | grep "ocamlobjinfo"
    CHECK_RESULT $?
    ocamlobjinfo.opt -no-approx example.cmi | grep -iE "file|unit|interfaces"
    CHECK_RESULT $?
    ocamlobjinfo.opt -no-code example.cmi | grep -iE "file|unit|interfaces|57c"
    CHECK_RESULT $?
    ocamlobjinfo.opt -null-crc example.cmi | grep -iE "file|unit|interfaces|000"
    CHECK_RESULT $?
    echo "example.cmi" >tmp
    ocamlobjinfo.opt -args tmp | grep -iE "file|unit|interfaces|57c"
    CHECK_RESULT $?
    ocamlobjinfo.opt -help | grep "ocamlobjinfo"
    CHECK_RESULT $?
    ocamlobjinfo.byte -no-approx example.cmi | grep -iE "file|unit|interfaces"
    CHECK_RESULT $?
    ocamlobjinfo.byte -no-code example.cmi | grep -iE "file|unit|interfaces|57c"
    CHECK_RESULT $?
    ocamlobjinfo.byte -null-crc example.cmi | grep -iE "file|unit|interfaces|000"
    CHECK_RESULT $?
    echo "example.cmi" >tmp
    ocamlobjinfo.byte -args tmp | grep -iE "file|unit|interfaces|57c"
    CHECK_RESULT $?
    ocamlobjinfo.byte -help | grep "ocamlobjinfo"
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    rm -rf $(ls | grep -vE ".sh")
    LOG_INFO "End to restore the test environment."
}

main "$@"
