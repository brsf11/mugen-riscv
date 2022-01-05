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
# @Desc      :   pg_restore
# ############################################

source ../common/lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    postgresql_install
    su - postgres -c "pg_dump -Fc testdb  -f testdb.dump"
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    su - postgres -c "dropdb postgres" && su - postgres -c "createdb postgres"
    su - postgres -c "pg_restore -P generate_series testdb.dump -d postgres -v" 2>&1 | grep "pg_restore"
    CHECK_RESULT $?
    su - postgres -c "dropdb postgres" && su - postgres -c "createdb postgres"
    su - postgres -c "pg_restore -s testdb.dump -d postgres -v" 2>&1 | grep "pg_restore"
    CHECK_RESULT $?
    su - postgres -c "dropdb postgres" && su - postgres -c "createdb postgres"
    su - postgres -c "pg_restore -S testuser testdb.dump -d postgres -v" 2>&1 | grep "pg_restore"
    CHECK_RESULT $?
    su - postgres -c "dropdb postgres" && su - postgres -c "createdb postgres"
    psql -U postgres -h 127.0.0.1 -c "create SCHEMA myschema;"
    su - postgres -c "pg_restore -t test testdb.dump -d postgres -v" 2>&1 | grep "pg_restore"
    CHECK_RESULT $?
    pg_restore -? | grep "Usage:"
    CHECK_RESULT $?
    su - postgres -c "dropdb postgres" && su - postgres -c "createdb postgres"
    su - postgres -c "pg_restore -x testdb.dump -v" 2>&1 | grep "pg_restore"
    CHECK_RESULT $?
    su - postgres -c "dropdb postgres" && su - postgres -c "createdb postgres"
    su - postgres -c "pg_restore  -1 testdb.dump -d postgres -v" 2>&1 | grep "pg_restore"
    CHECK_RESULT $?
    su - postgres -c "dropdb postgres" && su - postgres -c "createdb postgres"
    su - postgres -c "pg_restore -C testdb.dump  -f testfile -v" 2>&1 | grep "pg_restore"
    CHECK_RESULT $?
    su - postgres -c "dropdb postgres" && su - postgres -c "dropdb testdb" && su - postgres -c "createdb postgres"
    su - postgres -c "pg_restore -C -F c testdb.dump  -d postgres"
    CHECK_RESULT $?
    pg_restore -V | grep "(PostgreSQL)"
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
