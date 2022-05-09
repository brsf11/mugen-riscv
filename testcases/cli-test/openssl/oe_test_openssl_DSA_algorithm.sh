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
#@Desc          :   Application scenarios: method of generating the private key,public key,and self-shared key(signature certificate) of the DSA algorithm
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function run_test() {
    LOG_INFO "Start to run test."
    openssl dsaparam -noout -out dsakey.pem -genkey 2048
    CHECK_RESULT $?
    grep 'BEGIN DSA PRIVATE KEY' dsakey.pem
    CHECK_RESULT $?
    openssl dsa -in dsakey.pem -pubout -out dsakey-pub.pem
    CHECK_RESULT $?
    grep 'BEGIN PUBLIC KEY' dsakey-pub.pem
    CHECK_RESULT $?
    expect <<-END
    log_file testlog
    spawn openssl req -x509 -key dsakey.pem -days 365 -out mycert-dsa.pem -new
    expect "Country Name"
    send "CH\\n"
    expect "State or Province Name (full name)"
    send "shanxi\\n"
    expect "Locality Name (eg, city)"
    send "xian\\n"
    expect "Organization Name (eg, company)"
    send "openEuler\\n"
    expect "Organizational Unit Name (eg, section)"
    send "develop\\n"
    expect "Common Name (e.g. server FQDN or YOUR name)"
    send "www.openeuler.org\\n"
    expect "Email Address"
    send "public@openeuler.io\\n"
    expect eof
    exit
END
    grep 'certificate request' testlog
    CHECK_RESULT $?
    grep 'BEGIN CERTIFICATE' mycert-dsa.pem
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -f dsakey.pem dsakey-pub.pem mycert-dsa.pem testlog
    LOG_INFO "End to restore the test environment."
}

main "$@"
