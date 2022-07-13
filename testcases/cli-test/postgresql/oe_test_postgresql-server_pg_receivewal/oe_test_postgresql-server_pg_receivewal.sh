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
# @Desc      :   pg_receivewal
# ############################################

source ../common/lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    postgresql_install
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    su - postgres -c "mkdir -p /var/lib/pgsql/pg_receivewal"
    CHECK_RESULT $?
    su - postgres -c "pg_receivewal -D /var/lib/pgsql/pg_receivewal --if-not-exists &"
    CHECK_RESULT $?
    kill -9 $(pgrep -f 'pg_receivewal -D /var/lib/pgsql/pg_receivewal --if-not-exists')
    CHECK_RESULT $?
    su - postgres -c "pg_receivewal -n -D /var/lib/pgsql/pg_receivewal &"
    CHECK_RESULT $?
    su - postgres -c "pg_receivewal -s 5 -D /var/lib/pgsql/pg_receivewal &"
    CHECK_RESULT $?
    kill -9 $(pgrep -f 'pg_receivewal -s 5 -D /var/lib/pgsql/pg_receivewal')
    CHECK_RESULT $?
    psql -U postgres -h 127.0.0.1 -c "SELECT * FROM pg_create_physical_replication_slot('node_a_slot');"
    CHECK_RESULT $?
    su - postgres -c "pg_receivewal -D /var/lib/pgsql/pg_receivewal -S node_a_slot &"
    CHECK_RESULT $?
    kill -9 $(pgrep -f 'pg_receivewal -D /var/lib/pgsql/pg_receivewal -S node_a_slot')
    CHECK_RESULT $?
    su - postgres -c "pg_receivewal -D /var/lib/pgsql/pg_receivewal --synchronous &"
    CHECK_RESULT $?
    kill -9 $(pgrep -f 'pg_receivewal -D /var/lib/pgsql/pg_receivewal --synchronous')
    CHECK_RESULT $?
    su - postgres -c "pg_receivewal -D /var/lib/pgsql/pg_receivewal -v &"
    CHECK_RESULT $?
    kill -9 $(pgrep -f 'pg_receivewal -D /var/lib/pgsql/pg_receivewal -v')
    CHECK_RESULT $?
    pg_receivewal -V | grep "PostgreSQL"
    CHECK_RESULT $?
    su - postgres -c "pg_receivewal -D /var/lib/pgsql/pg_receivewal -Z 3 &"
    CHECK_RESULT $?
    kill -9 $(pgrep -f 'pg_receivewal -D /var/lib/pgsql/pg_receivewal -Z 3')
    CHECK_RESULT $?
    pg_receivewal -? | grep "Usage:"
    CHECK_RESULT $?
    su - postgres -c "pg_receivewal -D /var/lib/pgsql/pg_receivewal -h 192.168.122.149 -U sstest -w -p 5432 &"
    CHECK_RESULT $?
    kill -9 $(pgrep -f 'pg_receivewal -D /var/lib/pgsql/pg_receivewal -h 192.168.122.149 -U sstest -w -p 5432')
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf /var/lib/pgsql/*
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}
main "$@"
