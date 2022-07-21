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
# @Date      :   2020/11/4
# @License   :   Mulan PSL v2
# @Desc      :   The usage of ocamlmktop under ocaml package
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    OLD_LANG=$LANG
    export LANG=en_US.UTF-8
    DNF_INSTALL ocaml
    cp ../a.c ../example.ml ../hello.ml ./
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    ocamlmktop -output-obj example.ml -o exampleobj.o
    CHECK_RESULT $?
    objdump -x exampleobj.o | grep "obj"
    CHECK_RESULT $?
    ocamlmktop -output-complete-obj example.ml -o examplecom.o
    CHECK_RESULT $?
    objdump -x examplecom.o | grep "obj_counter"
    CHECK_RESULT $?
    ocamlmktop -make-runtime -opaque a.c
    CHECK_RESULT $?
    objdump -x a.o | grep "start address"
    CHECK_RESULT $?
    ocamlmktop -warn-help hello.ml | grep "warning"
    CHECK_RESULT $?
    ocaml_version=$(rpm -qa ocaml | awk -F '-' '{print $2}')
    ocamlmktop -vnum example.ml | grep $ocaml_version
    CHECK_RESULT $?
    ocamlmktop -version example.ml | grep $ocaml_version
    CHECK_RESULT $?
    ocamlmktop -v a.c | grep -E "version|Standard library directory"
    CHECK_RESULT $?
    ocamlmktop -verbose a.c 2>&1 | grep "gcc"
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    export LANG=${OLD_LANG}
    DNF_REMOVE
    rm -rf ./a* ./example* ./hello*
    LOG_INFO "End to restore the test environment."
}

main "$@"
