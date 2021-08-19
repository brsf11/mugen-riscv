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
# @Date      :   2020/12/21
# @License   :   Mulan PSL v2
# @Desc      :   verify the uasge of tpm_version,tpm_takeownership,tpm_getpubek,tpm_sealdata and tpm_unsealdata command
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
    tpm_version --help | grep -iE "Usage: tpm_version|[0-9a-z]"
    CHECK_RESULT $?
    tpm_version -v | grep -E "tpm_version version|[0-9]"
    CHECK_RESULT $?
    tpm_version -l debug | grep "success"
    CHECK_RESULT $?
    tpm_takeownership --help | grep -iE "Usage: tpm_takeownership|[a-z]"
    CHECK_RESULT $?
    tpm_takeownership --version | grep -i "[0-9a-z]"
    CHECK_RESULT $?
    expect <<EOF
        log_file log_getpubek1
        spawn tpm_getpubek
        expect "Enter owner password:" {send "123@Test\r"}
        expect eof
EOF
    grep -i "[0-9a-z]" log_getpubek1
    CHECK_RESULT $?
    tpm_getpubek --help | grep -E "\-|Usage: tpm_getpubek"
    CHECK_RESULT $?
    tpm_getpubek --version | grep -E "tpm_getpubek version:|[0-9]"
    CHECK_RESULT $?
    expect <<EOF

        log_file log_getpubek2
        spawn tpm_getpubek -l debug
        expect "Enter owner password:" {send "123@Test\r"}
        expect eof
EOF
    grep -iE "[0-9a-z]|success" log_getpubek2
    CHECK_RESULT $?
    tpm_sealdata --help | grep -E "\-|Usage: tpm_sealdata"
    CHECK_RESULT $?
    tpm_sealdata --version | grep -E "tpm_sealdata version:|[0-9]"
    CHECK_RESULT $?
    expect <<EOF
        log_file log_sealdata1
        spawn tpm_sealdata -l debug
        expect "Enter SRK password:" {send "123@Come\r"}
        expect " " {send "\03"}
        expect eof
EOF
    grep -E "success|KEY|ENC" log_sealdata1
    CHECK_RESULT $?
    echo "hello,world!" >>testfile
    expect <<EOF
        log_file log_sealdata2
        spawn tpm_sealdata -i testfile
        expect "Enter SRK password:" {send "123@Come\r"}
        expect eof
EOF
    grep -iE "ENC|KEY|TSS|[0-9a-z]" log_sealdata2
    CHECK_RESULT $?
    expect <<EOF
        spawn tpm_sealdata -i testfile -o result
        expect "Enter SRK password:" {send "123@Come\r"}
        expect eof
EOF
    grep -i "[0-9a-z\+/=:-]" result
    CHECK_RESULT $?
    expect <<EOF
        log_file log_sealdata3
        spawn tpm_sealdata --pcr 16
        expect "Enter SRK password: " {send "123@Come\r"}
        expect " " {send "\03"}
        expect eof
EOF
    grep -i "[0-9a-z\+/=:-]" log_sealdata3
    CHECK_RESULT $?
    expect <<EOF
        log_file log_sealdata4
        spawn tpm_sealdata -u
        expect "Enter SRK password:" {send "123@Come\r"}
        expect " " {send "\03"}
        expect eof
EOF
    grep -i "[0-9a-z\+/=:-]" log_sealdata4
    CHECK_RESULT $?
    tpm_unsealdata --help | grep -E "\-|Usage: tpm_unsealdata"
    CHECK_RESULT $?
    tpm_unsealdata --version | grep -E "tpm_unsealdata version:|[0-9]"
    CHECK_RESULT $?
    echo "hello shell" >>infile
    expect <<EOF
        spawn tpm_sealdata -i infile -p 4 -p 8 -p 9 -p 12 -p 14 -o outresult
        expect "Enter SRK password:" {send "123@Come\r"}
        expect eof
EOF
    grep -i "[0-9a-z\+/=:-]" outresult
    CHECK_RESULT $?
    expect <<EOF
        spawn tpm_unsealdata -i outresult -o outfile
        expect "Enter SRK password:" {send "123@Come\r"}
        expect eof
EOF
    grep "hello shell" outfile
    CHECK_RESULT $?
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    clear_env
    LOG_INFO "Finish restoring the test environment."
}

main $@
