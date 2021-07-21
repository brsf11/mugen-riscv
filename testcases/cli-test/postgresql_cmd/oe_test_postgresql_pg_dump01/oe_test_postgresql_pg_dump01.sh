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
# @Date      :   2021-10-15
# @License   :   Mulan PSL v2
# @Desc      :   pg_dump
# ############################################

source ../common/lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    postgresql_install
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    su - postgres -c "pg_dump -a testdb >testfile"
    CHECK_RESULT $?
    su - postgres -c "pg_dump -b testdb >testfile"
    CHECK_RESULT $?
    grep "SELECT pg_catalog.lo_open" /var/lib/pgsql/testfile
    CHECK_RESULT $?
    su - postgres -c "pg_dump -B testdb >testfile"
    CHECK_RESULT $?
    grep "SELECT pg_catalog.lo_open" /var/lib/pgsql/testfile
    CHECK_RESULT $? 1
    su - postgres -c "pg_dump -c testdb >testfile"
    CHECK_RESULT $?
    grep "DROP TABLE" /var/lib/pgsql/testfile
    CHECK_RESULT $?
    su - postgres -c "pg_dump -C testdb >testfile"
    CHECK_RESULT $?
    grep "CREATE DATABASE" /var/lib/pgsql/testfile
    CHECK_RESULT $?
    su - postgres -c "pg_dump testdb -E EUC_CN >testfile"
    CHECK_RESULT $?
    grep "client_encoding = 'EUC_CN'" /var/lib/pgsql/testfile
    CHECK_RESULT $?
    su - postgres -c "pg_dump testdb -f test"
    CHECK_RESULT $?
    test -f /var/lib/pgsql/test && rm -rf /var/lib/pgsql/test
    CHECK_RESULT $?
    rm -rf /var/lib/pgsql/tmpdir
    su - postgres -c "pg_dump -Fd testdb -f tmpdir"
    CHECK_RESULT $?
    test -d /var/lib/pgsql/tmpdir && rm -rf /var/lib/pgsql/tmpdir
    CHECK_RESULT $?
    su - postgres -c "pg_dump -Fd testdb -f tmpdir2 -j 3"
    CHECK_RESULT $?
    test -d /var/lib/pgsql/tmpdir2 && rm -rf /var/lib/pgsql/tmpdir2
    CHECK_RESULT $?
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
