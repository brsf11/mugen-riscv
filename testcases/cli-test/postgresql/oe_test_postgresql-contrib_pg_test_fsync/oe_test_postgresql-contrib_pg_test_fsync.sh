#!/usr/bin/bash

# Copyright (c) 2021. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
# http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.
# #############################################
# @Author    :   wangshan
# @Contact   :   wangshan@163.com
# @Date      :   2020-10-15
# @License   :   Mulan PSL v2
# @Desc      :   pg_test_fsync pg_test_timing pg_upgrade
# ############################################

source ../common/lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    postgresql_install
    echo "EXEC SQL CREATE TABLE testecpg (a int, b varchar(50));" >testfile
    su - postgres -c "pg_test_fsync -f testfile"
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    su - postgres -c "pg_test_fsync -s 2"
    CHECK_RESULT $?
    pg_test_fsync -V | grep "(PostgreSQL)"
    CHECK_RESULT $?
    pg_test_fsync -? | grep "Usage:"
    CHECK_RESULT $?
    rm -rf testfile

    su - postgres -c "pg_test_timing -d 3" | grep "3 seconds"
    CHECK_RESULT $?
    pg_test_timing -V | grep "(PostgreSQL)"
    CHECK_RESULT $?
    pg_test_timing -? | grep "Usage:"
    CHECK_RESULT $?

    pg_upgrade -V | grep "(PostgreSQL)"
    CHECK_RESULT $?
    pg_upgrade -? | grep "Usage:"
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
