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
# @Desc      :   pg_rewind
# ############################################

source ../common/lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    postgresql_install
    install_env
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    su - postgres -c "pg_rewind -D /var/lib/pgsql/data --source-server='host=${NODE2_USER} port=5432 user=postgres'"
    CHECK_RESULT $?
    su - postgres -c "pg_rewind -D /var/lib/pgsql/data1 --source-pgdata /var/lib/pgsql/data -P"
    CHECK_RESULT $?
    su - postgres -c "pg_rewind -D /var/lib/pgsql/data1 --source-pgdata /var/lib/pgsql/data -n"
    CHECK_RESULT $?
    su - postgres -c "pg_rewind -D /var/lib/pgsql/data --source-server='host=${NODE2_USER} port=5432 user=postgres dbname=postgres' -P"
    CHECK_RESULT $?
    su - postgres -c "pg_rewind -D /var/lib/pgsql/data --source-server='host=${NODE2_USER} port=5432 user=postgres dbname=postgres' --debug"
    CHECK_RESULT $?
    su - postgres -c "pg_rewind -V" | grep "(PostgreSQL)"
    CHECK_RESULT $?
    su - postgres -c "pg_rewind -?" | grep "Usage:"
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf /var/lib/pgsql/*
    DNF_REMOVE
    SSH_CMD "rm -rf /var/lib/pgsql/* && dnf -y remove postgresql postgresql-server postgresql-devel postgresql-contrib" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    LOG_INFO "End to restore the test environment."
}
main "$@"
