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
# @Desc      :   clusterdb
# ############################################

source ../common/lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    postgresql_install
    su - postgres -c "createuser pgbench"
    su - postgres -c "mkdir -p /var/lib/pgsql/tbs"
    psql -U postgres -h 127.0.0.1 -c "CREATE TABLESPACE tbs2 OWNER pgbench LOCATION '/var/lib/pgsql/tbs';"
    psql -U postgres -h 127.0.0.1 -c "CREATE DATABASE pgbenchdb WITH OWNER = pgbench ENCODING = 'UTF8' TABLESPACE = tbs2;"
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    su - postgres -c "pgbench -i pgbenchdb" 2>&1 | grep "done"
    CHECK_RESULT $?
    su - postgres -c "pgbench -i pgbenchdb -F 100" 2>&1 | grep "done"
    CHECK_RESULT $?
    su - postgres -c "pgbench -i pgbenchdb -n" 2>&1 | grep "done"
    CHECK_RESULT $?
    su - postgres -c "pgbench -i pgbenchdb -s 20 -q" 2>&1 | grep "done"
    CHECK_RESULT $?
    su - postgres -c "pgbench -i pgbenchdb -s 10" 2>&1 | grep "done"
    CHECK_RESULT $?
    su - postgres -c "pgbench -i pgbenchdb --foreign-keys" 2>&1 | grep "done"
    CHECK_RESULT $?
    su - postgres -c "pgbench -i pgbenchdb --index-tablespace=tbs2" 2>&1 | grep "done"
    CHECK_RESULT $?
    su - postgres -c "pgbench -i pgbenchdb --tablespace=tbs2" 2>&1 | grep "done"
    CHECK_RESULT $?
    su - postgres -c "pgbench -i pgbenchdb --unlogged-tables" 2>&1 | grep "done"
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
