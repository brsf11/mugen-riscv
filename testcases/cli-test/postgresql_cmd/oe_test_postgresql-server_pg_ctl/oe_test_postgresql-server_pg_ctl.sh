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
# @Desc      :   pg_ctl
# ############################################

source ../common/lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    postgresql_install
    su - postgres -c "pg_ctl stop -D data"
    su - postgres -c "rm -rf /var/lib/pgsql/data1 && mkdir -p /var/lib/pgsql/data1"
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    su - postgres -c "pg_ctl init -D data1 -s"
    CHECK_RESULT $?
    su - postgres -c 'pg_ctl start -D data1 -l /tmp/pglog -t 5 -o "-p 5433" -p /usr/bin/postgres'
    su - postgres -c "pg_ctl -D data1 status" | grep "running (PID"
    CHECK_RESULT $?
    su - postgres -c "pg_ctl stop -D data1"
    CHECK_RESULT $?
    su - postgres -c "pg_ctl start -D data1 -W"
    CHECK_RESULT $?
    su - postgres -c "pg_ctl stop -D data1"
    CHECK_RESULT $?
    su - postgres -c "pg_ctl start -D data1 -s "
    CHECK_RESULT $?
    su - postgres -c "pg_ctl stop -D data1 -m smart"
    CHECK_RESULT $?
    su - postgres -c "pg_ctl start -D data1"
    CHECK_RESULT $?
    su - postgres -c "pg_ctl stop -D data1 -s -t 5"
    CHECK_RESULT $?
    su - postgres -c "pg_ctl start -D data1"
    CHECK_RESULT $?
    su - postgres -c "pg_ctl stop -D data1 -W"
    CHECK_RESULT $?
    su - postgres -c 'pg_ctl restart -D data1 -m smart -t 5 -o "-p 5435"'
    CHECK_RESULT $?
    su - postgres -c "pg_ctl restart -D data1 -s"
    CHECK_RESULT $?
    su - postgres -c "pg_ctl restart -D data1 -W"
    CHECK_RESULT $?
    su - postgres -c "pg_ctl reload -D data1 -s"
    CHECK_RESULT $?
    PID=$(su - postgres -c "pg_ctl -D data1 status" | grep "PID" | tr -cd "[0-9]")
    su - postgres -c "pg_ctl kill INT ${PID}"
    CHECK_RESULT $?
    pg_ctl -V | grep "(PostgreSQL)"
    CHECK_RESULT $?
    pg_ctl -? | grep "Usage:"
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
