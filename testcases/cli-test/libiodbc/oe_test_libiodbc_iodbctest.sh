#!/usr/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more detaitest -f.

# ###########################################################
# @Author    :   zhanglu626
# @Contact   :   m18409319968@163.com
# @Date      :   2022/01/18
# @License   :   Mulan PSL v2
# @Desc      :   Responsible for handling ODBC function calls
# ###########################################################
source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment!"
    DNF_INSTALL "libiodbc mariadb mariadb-server mariadb-connector-odbc"
    systemctl start mariadb
    /usr/bin/expect <<-EOF
    spawn mysql -u root -p
    expect "password:"
    send "openEuler@123"
    expect "MariaDB [(none)]>"
    send "create user tim identified by 'openEuler@123';\n"
    expect "MariaDB [(none)]>"
    send "create database tim;\n"
    expect "MariaDB [(none)]>"
    send "\\q\n"
    expect eof
EOF
    A=$(cat ../../../conf/env.json | grep "IPV4" | awk -F '"' '{print $4}')
    echo "[MariaDB-server]
Description=MariaDB server
Driver=/usr/lib64/libmaodbc.so
SERVER=$A
USER=tim
PASSWORD=openEuler@123
DATABASE=tim
PORT=5432" >>/etc/odbc.ini
    LOG_INFO "End to prepare the test environment!"
}

function run_test() {
    LOG_INFO "Start executing testcase!"
    iodbctest "DSN=MariaDB-server;UID=tim;PWD=openEuler@123" 2>&1 | grep "SQLDriverConnect"
    CHECK_RESULT $? 0 0 "Driver connection failure"
    iodbctestw "DSN=MariaDB-server;UID=tim;PWD=openEuler@123" 2>&1 | grep "SQLDriverConnect"
    CHECK_RESULT $? 0 0 "Driver connection failure"
    iodbctest -h 2>&1 | grep "Usage:"
    CHECK_RESULT $? 0 0 "iodbctest help message is misprinted"
    iodbctestw -h 2>&1 | grep "Usage:"
    CHECK_RESULT $? 0 0 "iodbctestw help message is misprinted"
    LOG_INFO "End of testcase execution!"
}

function post_test() {
    LOG_INFO "Start environment cleanup."
    DNF_REMOVE
    rm -rf /etc/odbc.ini
    LOG_INFO "Finish environment cleanup."
}

main $@
