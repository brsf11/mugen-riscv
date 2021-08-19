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
# @Date      :   2020/12/22
# @License   :   Mulan PSL v2
# @Desc      :   verify the uasge of tpm_changeownerauth,tpm_clear,tpm_nvinfo,tpm_resetdalock and tpm_restrictpubek command
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
    tpm_changeownerauth --help | grep -E "Usage: tpm_changeownerauth|-"
    CHECK_RESULT $?
    tpm_changeownerauth --version | grep -E "tpm_changeownerauth version:|[0-9]"
    CHECK_RESULT $?
    expect <<EOF
        log_file log_changeowner
        spawn tpm_changeownerauth -l debug -o
        expect "Enter owner password:" {send "123@Test\r"}
        expect "Enter new owner password:" {send "123@Why\r"}
        expect "Confirm password:" {send "123@Why\r"}
        expect eof
EOF
    grep -iE "success|Change of owner password successful" log_changeowner
    CHECK_RESULT $?
    expect <<EOF
        log_file log_changeSRK
        spawn tpm_changeownerauth -l debug -s
        expect "Enter owner password:" {send "123@Why\r"}
        expect "Enter new SRK password:" {send "123@What\r"}
        expect "Confirm password:" {send "123@What\r"}
        expect eof
EOF
    grep -iE "success|Change of SRK password successful" log_changeSRK
    CHECK_RESULT $?

    tpm_nvinfo --help | grep -E "Usage: tpm_nvinfo|-"
    CHECK_RESULT $?
    tpm_nvinfo --version | grep -E "tpm_nvinfo version:|[0-9]"
    CHECK_RESULT $?
    tpm_nvinfo --log debug | grep -E "success|PCR"
    CHECK_RESULT $?
    tpm_nvinfo -i 0x100
    CHECK_RESULT $?
    tpm_nvinfo --list-only | grep -E "The following NVRAM areas have been defined:|0x100"
    CHECK_RESULT $?

    tpm_resetdalock --help | grep -E "Usage: tpm_resetdalock|-"
    CHECK_RESULT $?
    tpm_resetdalock --version | grep -E "tpm_resetdalock version:|[0-9]"
    CHECK_RESULT $?
    expect <<EOF
        log_file log_resetdalock
        spawn tpm_resetdalock --log debug
        expect "Enter owner password:" {send "123@Why\r"}
        expect eof
EOF
    grep -iE "success|tpm_resetdalock succeeded" log_resetdalock
    CHECK_RESULT $?

    tpm_restrictpubek --help | grep -E "Usage: tpm_restrictpubek|-"
    CHECK_RESULT $?
    tpm_restrictpubek --version | grep -E "tpm_restrictpubek version:|[0-9]"
    CHECK_RESULT $?
    expect <<EOF
        log_file log_restrictpubek1
        spawn tpm_restrictpubek --log debug 
        expect "Enter owner password:" {send "123@Why\r"}
        expect eof
EOF
    grep -iE "success|tpm_restrictpubek succeeded|Public Endorsement Key readable by: owner" log_restrictpubek1
    CHECK_RESULT $?
    expect <<EOF
        log_file log_restrictpubek2
        spawn tpm_restrictpubek -s
        expect "Enter owner password:" {send "123@Why\r"}
        expect eof
EOF
    grep "Public Endorsement Key readable by: owner" log_restrictpubek2
    CHECK_RESULT $?
    expect <<EOF
        log_file log_restrictpubek3
        spawn tpm_restrictpubek -r
        expect "Enter owner password:" {send "123@Why\r"}
        expect eof
EOF
    grep "Enter owner password:" log_restrictpubek3
    CHECK_RESULT $?

    tpm_clear --help | grep -E "Usage: tpm_clear|-"
    CHECK_RESULT $?
    tpm_clear --version | grep -E "tpm_clear version:|[0-9]"
    CHECK_RESULT $?
    tpm_clear --log debug -f >log_tpmclear
    CHECK_RESULT $?
    grep -iE "success|tpm_clear succeeded" log_tpmclear
    CHECK_RESULT $?
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    clear_env
    LOG_INFO "Finish restoring the test environment."
}

main $@
