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
# @Author    :   liujuan
# @Contact   :   lchutian@163.com
# @Date      :   2020/12/23
# @License   :   Mulan PSL v2
# @Desc      :   verify the uasge of tpm_restrictsrk,tpm_revokeek,tpm_selftest,tpm_setpresence and tpm_setoperatorauth command
# ############################################

source "../common/common_tpm-tools.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    deploy_env
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    expect <<EOF
        spawn tpm_takeownership
        expect "Enter owner password:" {send "123@Test\r"}
        expect "Confirm password:" { send "123@Test\r"}
        expect "Enter SRK password:" {send "123@Come\r"}
        expect "Confirm password:" { send "123@Come\r"}
        expect eof
EOF
    tpm_restrictsrk --help | grep -E "Usage: tpm_restrictsrk|-"
    CHECK_RESULT $?
    tpm_restrictsrk --version | grep -E "tpm_restrictsrk version:|[0-9]"
    CHECK_RESULT $?
    expect <<EOF
        log_file log_restrictsrk1
        spawn tpm_restrictsrk --log debug 
        expect "Enter owner password:" {send "123@Test\r"}
        expect eof
EOF
    grep -E "success|tpm_restrictsrk succeeded" log_restrictsrk1
    CHECK_RESULT $?
    expect <<EOF
        log_file log_restrictsrk2
        spawn tpm_restrictsrk --log debug -a
        expect "Enter owner password:" {send "123@Test\r"}
        expect eof
EOF
    grep -E "success|tpm_restrictsrk succeeded" log_restrictsrk2
    CHECK_RESULT $?
    expect <<EOF
        log_file log_restrictsrk3
        spawn tpm_restrictsrk -s
        expect "Enter owner password:" {send "123@Test\r"}
        expect eof
EOF
    grep -E "Storage Root Key readable with: SRK auth" log_restrictsrk3
    CHECK_RESULT $?
    expect <<EOF
        log_file log_restrictsrk4
        spawn tpm_restrictsrk --log debug -r
        expect "Enter owner password:" {send "123@Test\r"}
        expect eof
EOF
    grep -E "success|tpm_restrictsrk succeeded" log_restrictsrk4
    CHECK_RESULT $?

    tpm_revokeek --help | grep -E "Usage: tpm_revokeek|-"
    CHECK_RESULT $?
    tpm_revokeek --version | grep -E "tpm_revokeek version:|[0-9]"
    CHECK_RESULT $?

    tpm_selftest --help | grep -E "Usage: tpm_selftest|-"
    CHECK_RESULT $?
    tpm_selftest --version | grep -E "tpm_selftest version:|[0-9]"
    CHECK_RESULT $?
    tpm_selftest -l debug | grep -E "success|tpm_selftest succeeded"
    CHECK_RESULT $?
    tpm_selftest -r | grep "TPM Test Results:"
    CHECK_RESULT $?

    tpm_setpresence --help | grep -E "Usage: tpm_setpresence|-"
    CHECK_RESULT $?
    tpm_setpresence --version | grep -E "tpm_setpresence version:|[0-9]"
    CHECK_RESULT $?
    expect <<EOF
        log_file log_setpresence1
        spawn tpm_setpresence --log debug
        expect "Enter owner password:" {send "123@Test\r"}
        expect eof
EOF
    grep -E "success|tpm_setpresence succeeded" log_setpresence1
    CHECK_RESULT $?
    expect <<EOF
        log_file log_setpresence2
        spawn tpm_setpresence -s
        expect "Enter owner password:" {send "123@Test\r"}
        expect eof
EOF
    grep -E "Physical Presence Status|:" log_setpresence2
    CHECK_RESULT $?

    tpm_setoperatorauth --help | grep -E "Usage: tpm_setoperatorauth|-"
    CHECK_RESULT $?
    tpm_setoperatorauth --version | grep -E "tpm_setoperatorauth version:|[0-9]"
    CHECK_RESULT $?
    expect <<EOF
        log_file log_setoperatorauth1
        spawn tpm_setoperatorauth -l debug 
        expect "Enter operator password:" {send "123456\r"}
        expect "Confirm password:" {send "123456\r"}
        expect eof
EOF
    grep "success" log_setoperatorauth1
    CHECK_RESULT $?
    expect <<EOF
        log_file log_setoperatorauth2
        spawn tpm_setoperatorauth -u 
        expect "Enter operator password:" {send "123456\r"}
        expect "Confirm password:" {send "123456\r"}
        expect eof
EOF
    grep -E "Enter operator password|Confirm password" log_setoperatorauth2
    CHECK_RESULT $?
    tpm_setoperatorauth -z
    CHECK_RESULT $?
    tpm_setoperatorauth -l debug -z >runlog
    CHECK_RESULT $?
    grep "success" runlog
    CHECK_RESULT $?
    expect <<EOF
        log_file log_setoperatorauth3
        spawn tpm_setoperatorauth -p 
        expect "Enter operator password:" {send "123456\r"}
        expect "Confirm password:" {send "123456\r"}
        expect eof
EOF
    grep -E "Enter operator password|Confirm password" log_setoperatorauth3
    CHECK_RESULT $?
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    clear_env
    LOG_INFO "Finish restoring the test environment."
}

main $@
