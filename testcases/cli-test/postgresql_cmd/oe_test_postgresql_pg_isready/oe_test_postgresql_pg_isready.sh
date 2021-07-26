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
# @Desc      :   pg_isready pg_dumpall
# ############################################

source ../common/lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    postgresql_install
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    su - postgres -c "pg_dumpall -x > /var/lib/pgsql/test.sql"
    CHECK_RESULT $?
    grep "Grant" /var/lib/pgsql/test.sql
    CHECK_RESULT $? 1
    su - postgres -c "pg_dumpall -f testf"
    CHECK_RESULT $?
    test -f /var/lib/pgsql/testf && rm -rf /var/lib/pgsql/testf
    CHECK_RESULT $?
    su - postgres -c "pg_dumpall -f testf -v" 2>&1 | grep "pg_dump"
    CHECK_RESULT $?
    test -f /var/lib/pgsql/testf && rm -rf /var/lib/pgsql/testf
    CHECK_RESULT $?
    pg_dumpall -V | grep "(PostgreSQL)"
    CHECK_RESULT $?
    su - postgres -c "pg_dumpall --lock-wait-timeout=5 -f test"
    CHECK_RESULT $?
    pg_dumpall -? | grep "Usage:"
    CHECK_RESULT $?

    su - postgres -c "pg_isready -d testdb" | grep "accepting connections"
    CHECK_RESULT $?
    su - postgres -c "pg_isready -q"
    CHECK_RESULT $?
    pg_isready -V | grep "(PostgreSQL)"
    CHECK_RESULT $?
    pg_isready -? | grep "Usage:"
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    systemctl stop postgresql
    DNF_REMOVE "postgresql postgresql-server postgresql-devel postgresql-contrib"
    rm -rf /var/lib/pgsql/*
    LOG_INFO "End to restore the test environment."
}
main "$@"
