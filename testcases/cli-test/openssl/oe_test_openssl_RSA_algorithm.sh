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
#@Desc          :   Application scenarios: method of generating the private key,public key,and self-shared key(signature certificate) of the RSA algorithm
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function run_test() {
    LOG_INFO "Start to run test."
    openssl genrsa -out rsakey.pem
    CHECK_RESULT $?
    grep 'BEGIN RSA PRIVATE KEY' rsakey.pem
    CHECK_RESULT $?
    openssl rsa -in rsakey.pem -pubout -out rsakey-pub.pem
    CHECK_RESULT $?
    grep 'BEGIN PUBLIC KEY' rsakey-pub.pem
    CHECK_RESULT $?
    generate_PublicKey
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -f rsakey.pem rsakey-pub.pem mycert-rsa.pem testlog
    LOG_INFO "End to restore the test environment."
}

main "$@"
