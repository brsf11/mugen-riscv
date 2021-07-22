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
    su - postgres -c "pg_dump -n 'my*' testdb >testfile"
    CHECK_RESULT $?
    grep "myschema" /var/lib/pgsql/testfile
    CHECK_RESULT $?
    su - postgres -c "pg_dump -N 'my*' testdb >testfile"
    CHECK_RESULT $?
    grep "myschema" /var/lib/pgsql/testfile
    CHECK_RESULT $? 1
    su - postgres -c "pg_dump -o testdb >testfile"
    CHECK_RESULT $?
    grep "COPY myschema.test (id, val) WITH OIDS FROM stdin;" /var/lib/pgsql/testfile
    CHECK_RESULT $?
    su - postgres -c "pg_dump -O testdb >testfile"
    CHECK_RESULT $?
    grep "Owner: -" /var/lib/pgsql/testfile
    CHECK_RESULT $?
    su - postgres -c "pg_dump -s testdb >testfile"
    CHECK_RESULT $?
    grep "COPY myschema.test (id, val) FROM stdin;" /var/lib/pgsql/testfile
    CHECK_RESULT $? 1
    su - postgres -c "pg_dump -t myschema.test testdb >testfile"
    CHECK_RESULT $?
    grep "myschema.test" /var/lib/pgsql/testfile
    CHECK_RESULT $?
    su - postgres -c "pg_dump -T myschema.test >testfile"
    CHECK_RESULT $?
    grep "myschema.test" /var/lib/pgsql/testfile
    CHECK_RESULT $? 1
    su - postgres -c "pg_dump -v testdb -f tempv" 2>&1 | grep "pg_dump: creating"
    CHECK_RESULT $?
    pg_dump -V | grep "(PostgreSQL)"
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
