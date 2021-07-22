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
# @Desc      :   psql
# ############################################

source ../common/lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    postgresql_install
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    su - postgres -c "psql -A -c \"select * from pg_roles;\"" | grep "rolname"
    CHECK_RESULT $?
    su - postgres -c "psql -F \"\|\" -A -c \"select * from pg_roles;\"" | grep "rolname"
    CHECK_RESULT $?
    su - postgres -c "psql -H -c \"select * from pg_roles;\"" | grep "rolname"
    CHECK_RESULT $?
    su - postgres -c "psql -P format=latex -c \"select * from pg_roles;\"" | grep "rolname"
    CHECK_RESULT $?
    su - postgres -c "psql -R / -A -c \"select * from pg_roles;\"" | grep "rolname"
    CHECK_RESULT $?
    su - postgres -c "psql -t -c \"select * from pg_roles;\"" | grep "postgres"
    CHECK_RESULT $?
    su - postgres -c "psql -T “ss” -H -c \"select * from pg_roles;\"" | grep "rolname"
    CHECK_RESULT $?
    su - postgres -c "psql -x -c \"select * from pg_roles;\"" | grep "rolname"
    CHECK_RESULT $?
    su - postgres -c "psql -z -A -c \"select * from pg_roles;\"" | grep "rolname"
    CHECK_RESULT $?
    su - postgres -c "psql -0 -A -c \"select * from pg_roles;\"" | grep "rolname"
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
