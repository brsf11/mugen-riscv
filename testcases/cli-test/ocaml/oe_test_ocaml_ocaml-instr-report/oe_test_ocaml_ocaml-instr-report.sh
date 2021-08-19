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
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    ocaml-instr-report -f cal.awk score.txt >actual_result
    CHECK_RESULT $?
    diff actual_result expact_result
    CHECK_RESULT $?
    ocaml-instr-report -F ":" -f cal.awk score2.txt >actual_result
    CHECK_RESULT $?
    diff actual_result expact_result
    CHECK_RESULT $?
    ocaml-instr-report -f cal.awk -C score.txt | grep -i "copyright" -A 20
    CHECK_RESULT $?
    ocaml-instr-report -f cal.awk -d score.txt
    CHECK_RESULT $?
    grep "elements" awkvars.out
    CHECK_RESULT $?
    ocaml-instr-report -f cal.awk -D score.txt <<EOF
    q
EOF
    CHECK_RESULT $?
    ocaml-instr-report -v n=3 -f script data | grep "3"
    CHECK_RESULT $?
    ocaml-instr-report -f funclib -E script2 data2 | grep "\- ("
    CHECK_RESULT $?
    ocaml-instr-report -h | grep "help"
    CHECK_RESULT $?
    gawk_version=$(rpm -qa gawk | awk -F '-' '{print $2}')
    ocaml-instr-report -V | grep "${gawk_version}"
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    rm -rf awkvars.out actual_result
    LOG_INFO "End to restore the test environment."
}

main "$@"
