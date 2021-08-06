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
# @Desc      :   verify the uasge of tpm_setownable,tpm_setenable,tpm_setactive and tpm_setclearable command
# ############################################

source "../common/common_tpm-tools.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    deploy_env
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    tpm_setownable -p
    CHECK_RESULT $?
    expect <<EOF
        log_file runlog1
        spawn tpm_takeownership
        expect "Enter owner password:" {send "123@Test\r"}
        expect "Confirm password:" { send "123@Test\r"}
        expect "Enter SRK password:" {send "123@Come\r"}
        expect "Confirm password:" { send "123@Come\r"}
        expect eof
EOF
    grep "Owner install disabled" runlog1
    CHECK_RESULT $?
    tpm_setownable -a
    CHECK_RESULT $?
    expect <<EOF
        log_file runlog2
        spawn tpm_takeownership
        expect "Enter owner password:" {send "123@Test\r"}
        expect "Confirm password:" { send "123@Test\r"}
        expect "Enter SRK password:" {send "123@Come\r"}
        expect "Confirm password:" { send "123@Come\r"}
        expect eof
EOF
    grep -E "Enter|Confirm|password" runlog2
    CHECK_RESULT $?
    tpm_setownable --help | grep -E "Usage: tpm_setownable|-"
    CHECK_RESULT $?
    tpm_setownable --version | grep -E "tpm_setownable version:|[0-9]"
    CHECK_RESULT $?
    expect <<EOF
        log_file log_setownable1
        spawn tpm_setownable -l debug
        expect "Enter owner password:" {send "123@Test\r"}
        expect eof
EOF
    grep -E "success|Ownable status: true|tpm_setownable succeeded" log_setownable1
    CHECK_RESULT $?
    expect <<EOF
        log_file log_setownable2
        spawn tpm_setownable -s
        expect "Enter owner password:" {send "123@Test\r"}
        expect eof
EOF
    grep "Ownable status: true" log_setownable2
    CHECK_RESULT $?

    tpm_setclearable --help | grep -E "Usage: tpm_setclearable|-"
    CHECK_RESULT $?
    tpm_setclearable --version | grep -E "tpm_setclearable version:|[0-9]"
    CHECK_RESULT $?
    expect <<EOF
        log_file log_setclearable1
        spawn tpm_setclearable -l debug 
        expect "Enter owner password:" {send "123@Test\r"}
        expect eof
EOF
    grep -iE "success|Checking current status:|tpm_setclearable succeeded|:" log_setclearable1
    CHECK_RESULT $?
    expect <<EOF
        log_file log_setclearable2
        spawn tpm_setclearable -s 
        expect "Enter owner password:" {send "123@Test\r"}
        expect eof
EOF
    grep -iE "Owner Clear Disabled: false|Force Clear Disabled: false" log_setclearable2
    CHECK_RESULT $?
    expect <<EOF
        log_file log_setclearable3
        spawn tpm_setclearable -o
        expect "Enter owner password:" {send "123@Test\r"}
        expect eof
EOF
    grep "Enter owner password:" log_setclearable3
    CHECK_RESULT $?
    tpm_setclearable -f
    CHECK_RESULT $?

    tpm_setenable --help | grep -E "Usage: tpm_setenable|-"
    CHECK_RESULT $?
    tpm_setenable --version | grep -E "tpm_setenable version:|[0-9]"
    CHECK_RESULT $?
    expect <<EOF
        log_file log_setenable1
        spawn tpm_setenable -l debug
        expect "Enter owner password:" {send "123@Test\r"}
        expect eof
EOF
    grep -E "success|Checking current status:|tpm_setenable succeeded" log_setenable1
    CHECK_RESULT $?
    expect <<EOF
        log_file log_setenable2
        spawn tpm_setenable -d -l debug
        expect "Enter owner password:" {send "123@Test\r"}
        expect eof
EOF
    grep -E "tpm_setenable succeeded|success" log_setenable2
    CHECK_RESULT $?
    expect <<EOF
        log_file log_setenable3
        spawn tpm_setenable -s
        expect "Enter owner password:" {send "123@Test\r"}
        expect eof
EOF
    grep "TPM is disabled" log_setenable3
    CHECK_RESULT $?
    expect <<EOF
        log_file log_setenable4
        spawn tpm_setenable -e -l debug
        expect "Enter owner password:" {send "123@Test\r"}
        expect eof
EOF
    grep -E "tpm_setenable succeeded|success" log_setenable4
    CHECK_RESULT $?
    expect <<EOF
        log_file log_setenable5
        spawn tpm_setenable -s
        expect "Enter owner password:" {send "123@Test\r"}
        expect eof
EOF
    grep "Disabled status: false" log_setenable5
    CHECK_RESULT $?
    expect <<EOF
        log_file log_setenable6
        spawn tpm_setenable -f
        expect "Enter owner password:" {send "123@Test\r"}
        expect eof
EOF
    grep "Disabled status: false" log_setenable6
    CHECK_RESULT $?

    tpm_setactive --help | grep -E "Usage: tpm_setactive|-"
    CHECK_RESULT $?
    tpm_setactive --version | grep -E "tpm_setactive version:|[0-9]"
    CHECK_RESULT $?
    expect <<EOF
        log_file log_setactive1
        spawn tpm_setactive -l debug 
        expect "Enter owner password:" {send "123@Test\r"}
        expect eof
EOF
    grep -iE "success|Checking status:|status" log_setactive1
    CHECK_RESULT $?
    tpm_setactive -i
    CHECK_RESULT $?
    expect <<EOF
        log_file log_setactive2
        spawn tpm_setactive -s 
        expect "Enter owner password:" {send "123@Test\r"}
        expect eof
EOF
    grep "TPM is deactivated" log_setactive2
    CHECK_RESULT $?
    tpm_setactive -a
    CHECK_RESULT $?
    expect <<EOF
        log_file log_setactive3
        spawn tpm_setactive -s
        expect "Enter owner password:" {send "123@Test\r"}
        expect eof
EOF
    grep -E "Persistent Deactivated Status: false|Volatile Deactivated Status: false" log_setactive3
    CHECK_RESULT $?
    tpm_setactive -t
    CHECK_RESULT $?
    expect <<EOF
        log_file log_setactive4
        spawn tpm_setactive -s 
        expect "Enter owner password:" {send "123@Test\r"}
        expect eof
EOF
    grep "TPM is deactivated" log_setactive4
    CHECK_RESULT $?
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    clear_env
    LOG_INFO "Finish restoring the test environment."
}

main $@
