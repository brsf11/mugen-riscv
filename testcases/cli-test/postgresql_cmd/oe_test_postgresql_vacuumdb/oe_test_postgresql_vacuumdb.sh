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
# @Desc      :   vacuumdb
# ############################################

source ../common/lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    postgresql_install
    oid=$(psql -U postgres -h 127.0.0.1 -c "select oid from pg_database where datname='testdb'" -t -0 -A)
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    psql testdb -U postgres -h 127.0.0.1 -c "insert into test select generate_series(1,100000),random();"
    psql testdb -U postgres -h 127.0.0.1 -c "delete from test"
    temp1=$(du /var/lib/pgsql/data/base/$oid | awk '{printf $1}')
    su - postgres -c "vacuumdb -a"
    CHECK_RESULT $?
    temp2=$(du /var/lib/pgsql/data/base/$oid | awk '{printf $1}')
    [ $temp1 -gt $temp2 ]
    CHECK_RESULT $?
    psql testdb -U postgres -h 127.0.0.1 -c "insert into test select generate_series(1,100000),random();"
    psql testdb -U postgres -h 127.0.0.1 -c "delete from test"
    temp1=$(du /var/lib/pgsql/data/base/$oid | awk '{printf $1}')
    su - postgres -c "vacuumdb -d testdb"
    CHECK_RESULT $?
    temp2=$(du /var/lib/pgsql/data/base/$oid | awk '{printf $1}')
    [ $temp1 -gt $temp2 ]
    CHECK_RESULT $?
    su - postgres -c "vacuumdb -e"
    CHECK_RESULT $?
    temp2=$(du /var/lib/pgsql/data/base/$oid | awk '{printf $1}')
    su - postgres -c "vacuumdb -d testdb -f"
    CHECK_RESULT $?
    temp3=$(du /var/lib/pgsql/data/base/$oid | awk '{printf $1}')
    [ $temp2 -gt $temp3 ]
    CHECK_RESULT $?
    su - postgres -c "vacuumdb -F -e"
    CHECK_RESULT $?
    su - postgres -c "vacuumdb -j 2 -a -e"
    CHECK_RESULT $?
    su - postgres -c "vacuumdb -q"
    CHECK_RESULT $?
    psql testdb -U postgres -h 127.0.0.1 -c "create table test2 (id int, val numeric);"
    psql testdb -U postgres -h 127.0.0.1 -c "insert into test2 select generate_series(1,1000),random();"
    psql testdb -U postgres -h 127.0.0.1 -c "delete from test2"
    temp1=$(du /var/lib/pgsql/data/base/$oid | awk '{printf $1}')
    su - postgres -c "vacuumdb -d testdb -t test2"
    CHECK_RESULT $?
    temp2=$(du /var/lib/pgsql/data/base/$oid | awk '{printf $1}')
    [ $temp1 -gt $temp2 ]
    CHECK_RESULT $?
    su - postgres -c "vacuumdb -v" 2>&1 | grep "DETAIL"
    CHECK_RESULT $?
    vacuumdb -V | grep "(PostgreSQL)"
    CHECK_RESULT $?
    su - postgres -c "vacuumdb -z -e"
    CHECK_RESULT $?
    psql testdb -U postgres -h 127.0.0.1 -c "insert into test select generate_series(1,100000),random();"
    psql testdb -U postgres -h 127.0.0.1 -c "delete from test"
    temp1=$(du /var/lib/pgsql/data/base/$oid | awk '{printf $1}')
    su - postgres -c "vacuumdb -Z -e"
    CHECK_RESULT $?
    temp2=$(du /var/lib/pgsql/data/base/$oid | awk '{printf $1}')
    [ $temp1 -eq $temp2 ]
    CHECK_RESULT $?
    vacuumdb -? | grep "Usage:"
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
