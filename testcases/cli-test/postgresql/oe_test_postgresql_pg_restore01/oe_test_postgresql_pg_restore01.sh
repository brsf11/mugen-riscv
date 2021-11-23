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
    su - postgres -c "pg_restore -c testdb.dump -v" 2>&1 | grep "Completed"
    CHECK_RESULT $?
    su - postgres -c "pg_restore -v -a testdb.dump" 2>&1 | grep "Completed"
    CHECK_RESULT $?
    su - postgres -c "dropdb testdb"
    su - postgres -c "pg_restore -C testdb.dump  -d postgres -v" 2>&1 | grep "pg_restore"
    CHECK_RESULT $?
    su - postgres -c "dropdb postgres" && su - postgres -c "createdb postgres"
    su - postgres -c "pg_restore -e testdb.dump  -d postgres -v" 2>&1 | grep "pg_restore"
    CHECK_RESULT $?
    su - postgres -c "dropdb postgres" && su - postgres -c "createdb postgres"
    su - postgres -c "pg_restore -I id testdb.dump  -d postgres -v" 2>&1 | grep "pg_restore"
    CHECK_RESULT $?
    su - postgres -c "dropdb postgres" && su - postgres -c "createdb postgres"
    su - postgres -c "pg_restore -j 2 testdb.dump  -d postgres -v" 2>&1 | grep "pg_restore"
    CHECK_RESULT $?
    su - postgres -c "dropdb postgres" && su - postgres -c "createdb postgres"
    su - postgres -c "pg_restore -l testdb.dump > testfile"
    sed -i '3d' /var/lib/pgsql/testfile
    su - postgres -c "pg_restore -L testfile testdb.dump  -d postgres -v" 2>&1 | grep "pg_restore"
    CHECK_RESULT $?
    su - postgres -c "pg_restore -n myschema -t test testdb.dump -v" 2>&1 | grep "pg_restore"
    CHECK_RESULT $?
    su - postgres -c "dropdb postgres" && su - postgres -c "createdb postgres"
    su - postgres -c "pg_restore -N myschema testdb.dump -d postgres -v" 2>&1 | grep "pg_restore"
    CHECK_RESULT $?
    su - postgres -c "dropdb postgres" && su - postgres -c "createdb postgres"
    su - postgres -c "pg_restore -O testdb.dump -v" 2>&1 | grep "pg_restore"
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
