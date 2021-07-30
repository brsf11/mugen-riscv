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
# @Date      :   2020/10/16
# @License   :   Mulan PSL v2
# @Desc      :   The usage of commands in tcllib package
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL "tcllib xinetd"
    sed -i '6s/yes/no/g' /etc/xinetd.d/echo-stream
    systemctl restart xinetd
    tcldir=$(rpm -ql tcllib | grep plugins | head -n 1)
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    page -V 2>&1 | grep page
    CHECK_RESULT $?
    page -r ${tcldir}/reader_peg.tcl -w ${tcldir}/writer_tree.tcl -P calculator.peg calculator 2>&1 | grep "Read 562 characters"
    CHECK_RESULT $?
    grep "node" calculator
    CHECK_RESULT $?
    page -r ${tcldir}/reader_peg.tcl -w ${tcldir}/writer_tree.tcl -v calculator.peg calculator | grep info
    CHECK_RESULT $?
    page -r ${tcldir}/reader_peg.tcl -w ${tcldir}/writer_tree.tcl -p calculator.peg calculator 2>&1 | grep -E "calculator.peg|calculator"
    CHECK_RESULT $?
    page -r ${tcldir}/reader_peg.tcl -w ${tcldir}/writer_tree.tcl -q calculator.peg calculator | grep info
    CHECK_RESULT $? 1
    page -r ${tcldir}/reader_peg.tcl -w ${tcldir}/writer_tree.tcl -T calculator.peg calculator 2>&1 | grep "Statistics"
    CHECK_RESULT $?
    page -rd ${tcldir}/reader_peg.tcl -wr ${tcldir}/writer_tree.tcl calculator.peg calculator 2>&1 | grep "PEG Normalization"
    CHECK_RESULT $?
    page -r ${tcldir}/reader_peg.tcl -w ${tcldir}/writer_tree.tcl -a calculator.peg calculator
    CHECK_RESULT $?
    grep "Expression" calculator
    CHECK_RESULT $?
    page -r ${tcldir}/reader_peg.tcl -w ${tcldir}/writer_tree.tcl --reset calculator.peg calculator
    CHECK_RESULT $?
    grep "list" calculator
    CHECK_RESULT $? 1
    page --configuration ${tcldir}/config_peg.tcl -r ${tcldir}/reader_peg.tcl -w ${tcldir}/writer_tree.tcl calculator.peg calculator
    CHECK_RESULT $?
    grep "Digit" calculator
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    rm -rf calculator
    LOG_INFO "End to restore the test environment."
}

main "$@"
