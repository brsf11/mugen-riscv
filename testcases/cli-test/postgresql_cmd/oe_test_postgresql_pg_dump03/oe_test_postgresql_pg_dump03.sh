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
    su - postgres -c "pg_dump -Z 1 -Ft -Fd testdb -f tmpdir >testfile"
    CHECK_RESULT $?
    grep "grant" /var/lib/pgsql/testfile && rm -rf /var/lib/pgsql/tmpdir
    CHECK_RESULT $? 1
    su - postgres -c "pg_dump testdb -Z 0" | grep "database dump complete"
    CHECK_RESULT $?
    pg_dump -? | grep "Usage:"
    CHECK_RESULT $?
    su - postgres -c "pg_dump testdb --column-inserts >testfile"
    CHECK_RESULT $?
    grep "INSERT INTO public.test (id, val) VALUES (10000" /var/lib/pgsql/testfile
    CHECK_RESULT $?
    su - postgres -c "pg_dump testdb --enable-row-security >testfile"
    CHECK_RESULT $?
    grep "SET row_security = on" /var/lib/pgsql/testfile
    CHECK_RESULT $?
    su - postgres -c "pg_dump testdb --exclude-table-data=tab_big >testfile"
    CHECK_RESULT $?
    grep "Data for Name: test; Type: TABLE DATA; Schema: " /var/lib/pgsql/testfile
    CHECK_RESULT $?
    su - postgres -c "pg_dump testdb --inserts >testfile"
    CHECK_RESULT $?
    grep "INSERT INTO public.test VALUES (1000" /var/lib/pgsql/testfile
    CHECK_RESULT $?
    su - postgres -c "pg_dump testdb -h 127.0.0.1 -U postgres -w -p 5432"
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
