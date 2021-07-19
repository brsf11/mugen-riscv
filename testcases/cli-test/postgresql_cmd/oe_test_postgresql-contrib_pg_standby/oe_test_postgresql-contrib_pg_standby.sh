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
# @Desc      :   pg_standby
# ############################################

source ../common/lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    postgresql_install
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    mkdir -p /var/lib/pgsql/standby_log
    su - postgres -c "pg_standby /var/lib/pgsql/standby_log %f %p %r -d -c &"
    CHECK_RESULT $?
    kill -9 $(pgrep -f 'pg_standby /var/lib/pgsql/standby_log %f %p %r -d -c')
    CHECK_RESULT $?
    su - postgres -c "pg_standby /var/lib/pgsql/standby_log %f %p %r -d &"
    CHECK_RESULT $?
    kill -9 $(pgrep -f 'pg_standby /var/lib/pgsql/standby_log %f %p %r -d')
    CHECK_RESULT $?
    su - postgres -c "pg_standby /var/lib/pgsql/standby_log %f %p %r -d -k 0000000200000000000000AF &"
    CHECK_RESULT $?
    kill -9 $(pgrep -f 'pg_standby /var/lib/pgsql/standby_log %f %p %r -d -k 0000000200000000000000AF')
    CHECK_RESULT $?
    su - postgres -c "pg_standby /var/lib/pgsql/standby_log %f %p %r -d -l &"
    CHECK_RESULT $?
    kill -9 $(pgrep -f 'pg_standby /var/lib/pgsql/standby_log %f %p %r -d -l')
    CHECK_RESULT $?
    su - postgres -c "pg_standby /var/lib/pgsql/standby_log %f %p %r -d -r 2 &"
    CHECK_RESULT $?
    kill -9 $(pgrep -f 'pg_standby /var/lib/pgsql/standby_log %f %p %r -d -r 2')
    CHECK_RESULT $?
    su - postgres -c "pg_standby /var/lib/pgsql/standby_log %f %p %r -d -s 3 &"
    CHECK_RESULT $?
    kill -9 $(pgrep -f 'pg_standby /var/lib/pgsql/standby_log %f %p %r -d -s 3')
    CHECK_RESULT $?
    su - postgres -c "pg_standby -t /var/lib/pgsql/data/trigger.kenyon /var/lib/pgsql/standby_log %f %p %r -d &"
    CHECK_RESULT $?
    kill -9 $(pgrep -f 'pg_standby -t /var/lib/pgsql/data/trigger.kenyon /var/lib/pgsql/standby_log %f %p %r -d')
    CHECK_RESULT $?
    pg_standby -V | grep "(PostgreSQL)"
    CHECK_RESULT $?
    pg_standby -? | grep "Usage:"
    CHECK_RESULT $?
    SLEEP_WAIT 3
    su - postgres -c "pg_standby /var/lib/pgsql/data/pg_wal %f %p %r -d -w 5 &"
    CHECK_RESULT $?
    kill -9 $(pgrep -f 'pg_standby /var/lib/pgsql/data/pg_wal %f %p %r -d -w 5')
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
