#!/usr/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.
####################################
#@Author        :   zhujinlong
#@Contact       :   zhujinlong@163.com
#@Date          :   2020-07-23
#@License       :   Mulan PSL v2
#@Desc          :   Application scenarios: use RSA certificates to encrypte and decrypte emails
#####################################

source "common/common_openssl.sh"

function run_test() {
    LOG_INFO "Start to run test."
    cat >test.txt <<EOF
    This is a file created by shell.
    We want to make a good world.   
    Byebye!
EOF
    openssl genrsa -out rsakey.pem
    CHECK_RESULT $?
    grep 'BEGIN RSA PRIVATE KEY' rsakey.pem
    CHECK_RESULT $?
    generate_PublicKey
    openssl smime -encrypt -in test.txt -out etest.txt mycert-rsa.pem
    CHECK_RESULT $?
    test -f etest.txt
    CHECK_RESULT $?
    openssl smime -decrypt -in etest.txt -inkey rsakey.pem -out dtest.txt
    CHECK_RESULT $?
    test -f dtest.txt
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    roc=$(ls | grep -v "\.sh\|common")
    rm -f $roc
    LOG_INFO "End to restore the test environment."
}

main "$@"
