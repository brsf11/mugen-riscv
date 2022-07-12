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
#@Date          :   2020-07-28
#@License       :   Mulan PSL v2
#@Desc          :   Public class
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function deploy_env() {
    CA_Path=/etc/pki/CA
    if [ ! -d ${CA_Path} ]; then
        mkdir -p ${CA_Path}/private ${CA_Path}/newcerts
    fi
    cp /etc/pki/tls/openssl.cnf /etc/pki/tls/openssl.cnf.bak
    sed -i '0,/^dir/s/\.\/demoCA/\/etc\/pki\/CA/' /etc/pki/tls/openssl.cnf
}

function createCA_and_Self_signed_certificate() {
    touch $CA_Path/index.txt
    echo 01 >$CA_Path/serial
    openssl genrsa -out $CA_Path/private/cakey.pem 2048
    CHECK_RESULT $?
    grep 'BEGIN RSA PRIVATE KEY' $CA_Path/private/cakey.pem
    CHECK_RESULT $?
    expect <<-END
    log_file $CA_Path/testlog1
    spawn openssl req -x509 -key $CA_Path/private/cakey.pem -days 365 -out $CA_Path/cacert.pem -new
    expect "Country Name"
    send "CN\\n"
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
    grep 'certificate request' $CA_Path/testlog1
    CHECK_RESULT $?
    grep 'BEGIN CERTIFICATE' $CA_Path/cacert.pem
    CHECK_RESULT $?
}

function generate_PrivateKey_and_Certificate_Signing_Request() {
    applying=${1-httpd}
    build_path=${2-/etc/${applying}/ssl}
    mkdir $build_path
    openssl genrsa -out $build_path/${applying}.key 2048
    CHECK_RESULT $?
    grep 'BEGIN RSA PRIVATE KEY' $build_path/${applying}.key
    CHECK_RESULT $?
    expect <<-END
    log_file $build_path/testlog2
    spawn openssl req -key $build_path/${applying}.key -out $build_path/${applying}.csr -new
    expect "Country Name"
    send "CN\\n"
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
    expect "A challenge password"
    send "openeuler12#$\\n"
    expect "An optional company name"
    send "jiangfengjituan\\n"
    expect eof
    exit
END
    grep 'certificate request' $build_path/testlog2
    CHECK_RESULT $?
    grep 'BEGIN CERTIFICATE REQUEST' $build_path/${applying}.csr
    CHECK_RESULT $?
}

function CA_Signature_Authentication() {
    applying=${1-httpd}
    build_path=${2-/etc/${applying}/ssl}
    expect <<-END
    log_file $build_path/testlog3
    spawn openssl ca -in $build_path/${applying}.csr -out $build_path/${applying}.crt -days 365
    expect "Sign the certificate"
    send "y\\n"
    expect "1 out of 1 certificate requests certified"
    send "y\\n"
    expect eof
    exit
END
    grep 'Certificate Details' $build_path/testlog3
    CHECK_RESULT $?
    grep 'BEGIN CERTIFICATE' $build_path/${applying}.crt
    CHECK_RESULT $?
}

function Modify_application_configuration() {
    file=/etc/httpd/conf.d/ssl.conf
    sed -i '/DocumentRoot/s/^#//' $file
    sed -i 's/\#ServerName www.example.com:443/ServerName www.linuxpanda.com:443/' $file
    sed -i 's#SSLCertificateFile /etc/pki/tls/certs/localhost.crt#SSLCertificateFile /etc/httpd/ssl/httpd.crt#' $file
    sed -i 's#SSLCertificateKeyFile /etc/pki/tls/private/localhost.key#SSLCertificateKeyFile /etc/httpd/ssl/httpd.key#' $file
    file2=/etc/httpd/conf/httpd.conf
    sed -i 's/\#ServerName www.example.com:80/ServerName www.openeuler.org:80/' $file2
    sed -i 's/Require all denied/Require all granted/' $file2
    cp /etc/hosts /etc/hosts.bak
    echo "127.0.0.1   www.openeuler.org" >/etc/hosts
    cp /usr/share/httpd/noindex/index.html /var/www/html/ && chmod 755 /var/www/html/index.html
    setenforce 0
}

function clean_httpd_openssl() {
    rm -f $CA_Path/index* $CA_Path/serial* $CA_Path/private/cakey.pem $CA_Path/cacert.pem $CA_Path/testlog1
    rm -rf /etc/httpd/ssl
    mv -f /etc/pki/tls/openssl.cnf.bak /etc/pki/tls/openssl.cnf
    mv -f /etc/hosts.bak /etc/hosts
}

function generate_PublicKey() {
    expect <<-END
    log_file testlog
    spawn openssl req -x509 -key rsakey.pem -days 365 -out mycert-rsa.pem -new
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
    grep 'BEGIN CERTIFICATE' mycert-rsa.pem
    CHECK_RESULT $?
}
