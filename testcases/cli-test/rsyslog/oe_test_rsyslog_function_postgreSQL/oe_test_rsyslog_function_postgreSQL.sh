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
# @Author    :   wangshan
# @Contact   :   wangshan@163.com
# @Date      :   2020-08-03
# @License   :   Mulan PSL v2
# @Desc      :   Support for log writing to PostgreSQL
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL "postgresql postgresql-server rsyslog-pgsql"
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    expect <<-END
    spawn su - postgres
    expect "postgres"
    send "initdb\n"
    expect "postgres"
    send "pg_ctl -D /var/lib/pgsql/data -l logfile start\n"
    expect "postgres"
    send "psql\n"
    expect "postgres"
    send "create user rsyslog with password 'rsyslog';\n"
    expect "postgres"
    send "create database \"Syslog\" owner=rsyslog;\n"
    expect "postgres"
    send "grant all on database \"Syslog\" to rsyslog;\n"
    expect "postgres"
    send "\\\q\n"
    expect eof
    exit
END
    psql -U rsyslog -d Syslog </usr/share/doc/rsyslog/pgsql-createDB.sql
    CHECK_RESULT $?
    cat >/etc/rsyslog.d/test.conf <<EOF
    \$ModLoad ompgsql
    *.*        :ompgsql:127.0.0.1,Syslog,rsyslog,rsyslog 
EOF
    systemctl restart rsyslog
    CHECK_RESULT $?
    SLEEP_WAIT 5
    expect <<-END
    spawn psql -U rsyslog -d Syslog
    expect "Syslog"
    send "\\\COPY (select * from systemevents) TO '/opt/test.csv' WITH csv;\n"
    expect "Syslog"
    send "\\\q\n"
    expect eof
    exit
END
    CHECK_RESULT $?
    number=$(cat /opt/test.csv | wc -l)
    [ $number -gt 0 ]
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf /etc/rsyslog.d/test.conf /opt/test.csv /var/lib/pgsql/*
    DNF_REMOVE
    systemctl restart rsyslog
    LOG_INFO "End to restore the test environment."
}
main "$@"
