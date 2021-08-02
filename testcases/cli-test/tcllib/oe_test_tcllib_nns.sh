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
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    nns bind -host localhost -port 9 NAME DATA &
    SLEEP_WAIT 20
    nnsd -localonly true -port 9 &
    SLEEP_WAIT 20
    nns search -host localhost -port 9 | grep "Searching"
    CHECK_RESULT $?
    SLEEP_WAIT 60
    nnslog -host localhost -port 9 &
    CHECK_RESULT $?
    nns search -host localhost -port 9 -continuous PATTERN &
    CHECK_RESULT $?
    nns ident -host localhost -port 9 | grep -E "Server localhost|Protocol|Features"
    CHECK_RESULT $?
    nns who | grep "nns"
    CHECK_RESULT $?
    kill -9 $(jobs -l | grep "nns" | awk '{print $2}')
    CHECK_RESULT $?
    tcldocstrip -guards example.doc
    CHECK_RESULT $?
    tcldocstrip outputfile example.doc guards
    CHECK_RESULT $?
    grep -E "manpage|tcldocstrip utility" outputfile
    CHECK_RESULT $?
    pt generate snit calculator.tcl peg calculator.peg | grep "OK"
    CHECK_RESULT $?
    grep -iE "tcl|calculator.peg" calculator.tcl
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    rm -rf outputfile calculator.tcl
    LOG_INFO "End to restore the test environment."
}

main "$@"
