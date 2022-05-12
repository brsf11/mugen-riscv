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
#@Date          :   2020-07-21 20:20:00
#@License       :   Mulan PSL v2
#@Desc          :   OpenSSL commandline tool: file signature and signature verification
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function run_test() {
    LOG_INFO "Start to run test."
    openssl dsaparam -noout -out dsakey.pem -genkey 2048
    CHECK_RESULT $?
    grep 'BEGIN DSA PRIVATE KEY' dsakey.pem
    CHECK_RESULT $?
    echo "It is a test" >file.txt
    openssl dgst -sha1 -sign dsakey.pem -out dsasign.bin file.txt
    CHECK_RESULT $?
    test -f dsasign.bin
    CHECK_RESULT $?
    openssl dgst -sha1 -prverify dsakey.pem -signature dsasign.bin file.txt | grep 'Verified OK'
    CHECK_RESULT $?
    openssl genrsa -out rsakey.pem
    CHECK_RESULT $?
    grep 'BEGIN RSA PRIVATE KEY' rsakey.pem
    CHECK_RESULT $?
    openssl rsa -in rsakey.pem -pubout -out rsakey-pub.pem
    CHECK_RESULT $?
    grep 'BEGIN PUBLIC KEY' rsakey-pub.pem
    CHECK_RESULT $?
    openssl sha1 -sign rsakey.pem -out rsasign.bin file.txt
    CHECK_RESULT $?
    test -f rsasign.bin
    CHECK_RESULT $?
    openssl sha1 -verify rsakey-pub.pem -signature rsasign.bin file.txt | grep 'Verified OK'
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -f $(ls | grep -v "\.sh\|common")
    LOG_INFO "End to restore the test environment."
}

main "$@"
