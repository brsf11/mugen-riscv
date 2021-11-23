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
# @Desc      :   pg_resetwal
# ############################################

source ../common/lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    postgresql_install
    lxind=$(psql testdb -U postgres -h 127.0.0.1 -c "select xmin ,* from test;" -t -A | sed -n '$p' | awk -F '|' '{printf $1}')
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    su - postgres -c "pg_ctl -D data stop"
    su - postgres -c "pg_resetwal -D data -x $lxind"
    CHECK_RESULT $?
    su - postgres -c "pg_resetwal -D data -n "
    CHECK_RESULT $?
    su - postgres -c "pg_resetwal -D data -o 333 -f"
    CHECK_RESULT $?
    su - postgres -c 'pg_resetwal -D data -n | grep -E "NextOID|333"'
    CHECK_RESULT $?
    su - postgres -c "pg_resetwal -D data -m 2,2"
    CHECK_RESULT $?
    su - postgres -c 'pg_resetwal -D data -n | grep "2" | grep -E "oldestMultiXid|oldestMultiXid"'
    CHECK_RESULT $?
    su - postgres -c "pg_resetwal -D data -c 2,2"
    CHECK_RESULT $?
    su - postgres -c 'pg_resetwal -D data -n | grep "2" | grep -E "oldestCommitTsXid|newestCommitTsXid"'
    CHECK_RESULT $?
    su - postgres -c "pg_resetwal -D data -e 44"
    CHECK_RESULT $?
    su - postgres -c 'pg_resetwal -D data -n | grep "44" | grep "NextXID"'
    CHECK_RESULT $?
    su - postgres -c "pg_resetwal -D data -O 1"
    CHECK_RESULT $?
    su - postgres -c 'pg_resetwal -D data -n | grep "1"| grep "NextMultiOffset"'
    CHECK_RESULT $?
    su - postgres -c "pg_resetwal -V" | grep "(PostgreSQL)"
    CHECK_RESULT $?
    su - postgres -c "pg_resetwal -?" | grep "Usage:"
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
