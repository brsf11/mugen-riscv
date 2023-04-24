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
# @Date      :   2022/07/18
# @License   :   Mulan PSL v2
# @Desc      :   Test urllib.request.urlopen
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL httpd
    getenforce | grep Enforcing && setenforce 0
    systemctl status firewalld | grep running && systemctl stop firewalld
    mkdir /var/www/html/test
    chmod 777 /var/www/html -R
    systemctl restart httpd
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    expect <<EOF
        log_file testlog1
        spawn python3
        expect ">>>" {send "import urllib\r"}
        expect ">>>" {send "import urllib.request\r"}
        expect ">>>" {send "response = urllib.request.urlopen('http://${NODE1_IPV4}/test/')\r"}
        expect ">>>" {send "response.status\r"}
        expect ">>>" {send "exit()\r"}
        expect eof
EOF
    grep 200 ./testlog1
    CHECK_RESULT $? 0 0 "Status 200 code return failed"
    expect <<EOF
        log_file testlog2
        spawn python3
        expect ">>>" {send "import urllib\r"}
        expect ">>>" {send "import urllib.request\r"}
        expect ">>>" {send "headers = {'User-Agent': 'PostmanRuntime/7.29.0','Host': '1'}\r"}
        expect ">>>" {send "data = bytes(urllib.parse.urlencode({'word':'hollow'}), encoding='utf8')
\r"}
        expect ">>>" {send "request =  urllib.request.Request(url='http://${NODE1_IPV4}/test/',data=data, headers=headers, method='POST')\r"}
        expect ">>>" {send "response = urllib.request.urlopen(request)\r"}
        expect ">>>" {send "exit()\r"}
        expect eof
EOF
    grep 400 ./testlog2
    CHECK_RESULT $? 0 0 "Status 400 code return failed"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf testlog* /var/www/html/test
    getenforce | grep Permissive && setenforce 1
    systemctl status firewalld | grep dead && systemctl start firewalld
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}

main "$@"
