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
# @Desc      :   createdb
# ############################################

source ../common/lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    postgresql_install
    DNF_INSTALL "glibc-all-langpacks"
    mkdir -p /var/lib/pgsql/dbdir
    chown -R postgres /var/lib/pgsql/dbdir
    su - postgres -c "createuser testuser"
    su - postgres -c "psql -c \"CREATE TABLESPACE tbs OWNER testuser LOCATION '/var/lib/pgsql/dbdir';\""
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    su - postgres -c "createdb testdb001"
    CHECK_RESULT $?
    su - postgres -c "psql postgres -tAc \"\l testdb001;\""
    CHECK_RESULT $?
    su - postgres -c "createdb testdb002 -D tbs"
    CHECK_RESULT $?
    su - postgres -c "psql postgres -tAc \"\l testdb002;\""
    CHECK_RESULT $?
    su - postgres -c "createdb -E EUC_KR -T template0 --lc-collate=ko_KR.euckr --lc-ctype=ko_KR.euckr testdb003"
    CHECK_RESULT $?
    su - postgres -c "psql postgres -tAc \"\l testdb003;\""
    CHECK_RESULT $?
    createdb -V | grep "(PostgreSQL)"
    CHECK_RESULT $?
    createdb -? | grep "Usage:"
    CHECK_RESULT $?
    su - postgres -c "createdb testdb004 -O postgres"
    CHECK_RESULT $?
    su - postgres -c "psql postgres -tAc \"\l testdb004;\""
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
