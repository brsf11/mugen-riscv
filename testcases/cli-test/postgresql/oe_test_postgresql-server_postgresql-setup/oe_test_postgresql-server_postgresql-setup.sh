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
# @Desc      :   postgresql-setup pg_controldata pg_rewind
# ############################################

source ../common/lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL "postgresql postgresql-server"
    export LANG="en_US.UTF-8"
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    su - postgres -c "postgresql-setup --initdb"
    CHECK_RESULT $?
    postgresql-setup --help | grep "Usage:"
    CHECK_RESULT $?
    postgresql-setup --version | grep "postgresql-setup"
    CHECK_RESULT $?
    rm -rf /var/lib/pgsql/data
    su - postgres -c "postgresql-setup --debug  --initdb"
    CHECK_RESULT $?

    pg_rewind -V | grep "(PostgreSQL)"
    CHECK_RESULT $?
    pg_rewind --help | grep "Usage:"
    CHECK_RESULT $?

    su - postgres -c "pg_controldata -D /var/lib/pgsql/data"
    CHECK_RESULT $?
    pg_controldata -V | grep "(PostgreSQL)"
    CHECK_RESULT $?
    pg_controldata --help | grep "Usage:"
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
