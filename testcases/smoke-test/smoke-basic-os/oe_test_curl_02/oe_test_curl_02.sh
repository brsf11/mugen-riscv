#!/usr/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
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
# @Date      :   2022/07/05
# @License   :   Mulan PSL v2
# @Desc      :   Test strace curl
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL "httpd strace mod_ssl"
    expect <<EOF
        spawn openssl genrsa -des3 -out server.key 2048
        expect "pass" { send "${NODE1_PASSWORD}\r" }
        expect "pass" { send "${NODE1_PASSWORD}\r" }
        expect eof
EOF
    expect <<EOF
        spawn openssl rsa -in server.key -out server.key
        expect "pass" { send "${NODE1_PASSWORD}\r" }
        expect eof
EOF
    echo -e '\n\n\n\n\n\n\n\n\n\n\n' | openssl req -new -key server.key -out server.csr
    echo -e '\n\n\n\n\n\n\n\n\n\n\n' | openssl req -new -x509 -key server.key -out ca.crt -days 3650
    openssl x509 -req -days 3650 -in server.csr -CA ca.crt -CAkey server.key -CAcreateserial -out server.crt
    chmod 400 server.*
    cp server.crt /etc/pki/tls/certs/
    cp server.key /etc/pki/tls/certs/
    chmod 644 /etc/pki/tls/certs/server.key
    chmod 644 /etc/pki/tls/certs/server.crt
    cp server.key /etc/pki/tls/private/
    chmod 644 /etc/pki/tls/private/server.key
    cp /etc/httpd/conf.d/ssl.conf /etc/httpd/conf.d/ssl.conf.bak
    sed -i 's/SSLCertificateFile \/etc\/pki\/tls\/certs\/localhost.crt/SSLCertificateFile \/etc\/pki\/tls\/certs\/server.crt/' /etc/httpd/conf.d/ssl.conf
    sed -i 's/SSLCertificateKeyFile.*/SSLCertificateKeyFile \/etc\/pki\/tls\/private\/server.key/' /etc/httpd/conf.d/ssl.conf
    echo '#DocumentRoot "/var/www/html"' >>/etc/httpd/conf.d/ssl.conf
    getenforce | grep Enforcing && setenforce 0
    systemctl status firewalld | grep running && systemctl stop firewalld
    systemctl restart httpd
    touch /var/www/html/example
    SLEEP_WAIT 5
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    strace curl -i --insecure -X GET https://${NODE1_IPV4}/notexist 2>&1 | grep -i "404 not found"
    CHECK_RESULT $? 0 0 "Failed to execute curl"
    strace curl -i --insecure -X GET https://${NODE1_IPV4}/example 2>&1 | grep -i "200 ok"
    CHECK_RESULT $? 0 0 "Failed to execute curl"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    mv -f /etc/httpd/conf.d/ssl.conf.bak /etc/httpd/conf.d/ssl.conf
    rm -rf /etc/pki/tls/private/server.key /etc/pki/tls/certs/server.* ./server* ./ca* /var/www/html/example
    getenforce | grep Permissive && setenforce 1
    systemctl status firewalld | grep dead && systemctl start firewalld
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}

main "$@"
