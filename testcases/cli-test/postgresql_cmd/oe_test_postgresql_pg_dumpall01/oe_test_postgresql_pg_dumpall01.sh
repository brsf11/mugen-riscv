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
# @Date      :   2020-10-15
# @License   :   Mulan PSL v2
# @Desc      :   pg_dumpall
# ############################################

source ../common/lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    postgresql_install
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    su - postgres -c "pg_dumpall -a > /var/lib/pgsql/test.sql"
    CHECK_RESULT $?
    grep "CREATE ROLE postgres;" /var/lib/pgsql/test.sql
    CHECK_RESULT $? 1
    su - postgres -c "pg_dumpall -c > /var/lib/pgsql/test.sql"
    CHECK_RESULT $?
    grep "Drop databases" /var/lib/pgsql/test.sql
    CHECK_RESULT $?
    su - postgres -c "pg_dumpall -g >/var/lib/pgsql/test.sql"
    CHECK_RESULT $?
    cat /var/lib/pgsql/test.sql | grep "Roles" | grep "connect testdb"
    CHECK_RESULT $? 1
    su - postgres -c "pg_dumpall -o > /var/lib/pgsql/test.sql"
    grep "OID" /var/lib/pgsql/test.sql
    CHECK_RESULT $?
    su - postgres -c "pg_dumpall -O >/var/lib/pgsql/test.sql"
    CHECK_RESULT $?
    grep "Owner: -" /var/lib/pgsql/test.sql
    CHECK_RESULT $?
    su - postgres -c "pg_dumpall -r > /var/lib/pgsql/test.sql"
    CHECK_RESULT $?
    cat /var/lib/pgsql/test.sql | grep "Roles" | grep "Tablespaces"
    CHECK_RESULT $? 1
    su - postgres -c "pg_dumpall -s >/var/lib/pgsql/test.sql"
    CHECK_RESULT $?
    grep "Data for Name: test;" /var/lib/pgsql/test.sql
    CHECK_RESULT $? 1
    su - postgres -c "pg_dumpall -S testuser > /var/lib/pgsql/test.sql"
    CHECK_RESULT $?
    su - postgres -c "pg_dumpall -t >/var/lib/pgsql/test.sql"
    CHECK_RESULT $?
    cat /var/lib/pgsql/test.sql | grep "Roles" | grep "Tablespaces"
    CHECK_RESULT $? 1
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    systemctl stop postgresql
    DNF_REMOVE
    rm -rf /var/lib/pgsql/*
    LOG_INFO "End to restore the test environment."
}
main "$@"
