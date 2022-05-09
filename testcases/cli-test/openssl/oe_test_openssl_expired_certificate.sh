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
#@Date          :   2020-07-29
#@License       :   Mulan PSL v2
#@Desc          :   the certificate has expired
#####################################

source "common/common_openssl.sh"

function config_params() {
    LOG_INFO "Start to config params of the case."
    OLD_LANG=$LANG
    export LANG=en_US.UTF-8
    deploy_env
    LOG_INFO "End to config params of the case."
}

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL "httpd mod_ssl"
    createCA_and_Self_signed_certificate
    generate_PrivateKey_and_Certificate_Signing_Request
    ssl_Path=/etc/httpd/ssl
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    expect <<-END
    log_file $ssl_Path/testlog3
    spawn openssl ca -in $ssl_Path/httpd.csr -out $ssl_Path/httpd.crt -enddate 20200729000000Z
    expect "Sign the certificate"
    send "y\\n"
    expect "1 out of 1 certificate requests certified"
    send "y\\n"
    expect eof
    exit
END
    grep 'Certificate Details' $ssl_Path/testlog3
    CHECK_RESULT $?
    grep 'BEGIN CERTIFICATE' $ssl_Path/httpd.crt
    CHECK_RESULT $?
    Modify_application_configuration
    systemctl restart httpd 
    CHECK_RESULT $? 0 0 "error:OPENSSL and HTTPD configuration failed."
    systemctl status httpd | grep "active (running)"
    CHECK_RESULT $?
    curl --cacert /etc/pki/CA/cacert.pem https://www.openeuler.org/index.html -I 2>&1 | grep 'certificate has expired'
    CHECK_RESULT $? 0 0 "Certificate not expired"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    export LANG=${OLD_LANG}
    mv -f /etc/pki/tls/openssl.cnf.bak /etc/pki/tls/openssl.cnf
    clean_httpd_openssl
    systemctl stop httpd
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}

main "$@"
