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
# @Desc      :   createuser
# ############################################

source ../common/lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    postgresql_install
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    expect <<-END
    spawn   su - postgres -c "createuser testuser11 -P"
    expect "Enter password for new role:"
    send "123456\n"
    expect "Enter it again:"
    send "123456\n"
    expect eof
    exit
END
    CHECK_RESULT $?
    su - postgres -c "psql postgres -tAc  \"select * from pg_roles;\"" | grep testuser11
    su - postgres -c "createuser testuser12 -r"
    CHECK_RESULT $?
    su - postgres -c "psql postgres -tAc  \"select * from pg_roles;\" | grep \"testuser12|f|t|t\""
    CHECK_RESULT $?
    su - postgres -c "createuser testuser13 -R"
    CHECK_RESULT $?
    su - postgres -c "psql postgres -tAc \"select * from pg_roles;\" | grep \"testuser13|f|t|f\""
    CHECK_RESULT $?
    su - postgres -c "createuser testuser14 -s"
    CHECK_RESULT $?
    su - postgres -c "psql postgres -tAc \"select * from pg_roles;\" | grep \"testuser14|t\""
    CHECK_RESULT $?
    su - postgres -c "createuser testuser15 -S"
    CHECK_RESULT $?
    su - postgres -c "psql postgres -tAc \"select * from pg_roles;\" | grep \"testuser15|f\""
    CHECK_RESULT $?
    createuser -V | grep "(PostgreSQL)"
    CHECK_RESULT $?
    expect <<-END
    spawn su - postgres -c "createuser testuser17 --interactive"
    expect "Shall the new role be a superuser? (y/n)"
    send "y\n"
    expect eof
    exit
END
    CHECK_RESULT $?
    su - postgres -c "psql postgres -tAc \"select * from pg_roles;\" | grep \"testuser17\""
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
