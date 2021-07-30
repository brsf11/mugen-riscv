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
# @Desc      :   initdb
# ############################################

source ../common/lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    postgresql_install
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    su - postgres -c "initdb -A ident -D data1"
    CHECK_RESULT $?
    test -d /var/lib/pgsql/data1 && rm -rf /var/lib/pgsql/data1
    su - postgres -c "initdb -D data1"
    CHECK_RESULT $?
    test -d /var/lib/pgsql/data1 && rm -rf /var/lib/pgsql/data1
    su - postgres -c "initdb -E EUC_CN -D data1 --locale=zh_CN"
    CHECK_RESULT $?
    test -d /var/lib/pgsql/data1 && rm -rf /var/lib/pgsql/data1
    su - postgres -c "initdb -E EUC_CN -D data1 --locale=zh_CN --lc-monetary=en_US --lc-collate=C"
    CHECK_RESULT $?
    test -d /var/lib/pgsql/data1 && rm -rf /var/lib/pgsql/data1
    su - postgres -c "initdb -D data1 --no-locale"
    CHECK_RESULT $?
    test -d /var/lib/pgsql/data1 && rm -rf /var/lib/pgsql/data1
    su - postgres -c 'echo "databasin" >/var/lib/pgsql/temp1'
    su - postgres -c "initdb -D data1 -U sstest --pwfile=temp1"
    CHECK_RESULT $?
    test -d /var/lib/pgsql/data1 && rm -rf /var/lib/pgsql/data1 /var/lib/pgsql/temp1
    su - postgres -c 'initdb -D data1 -T gin_fuzzy_search_limit="5000"'
    CHECK_RESULT $?
    test -d /var/lib/pgsql/data1 && rm -rf /var/lib/pgsql/data1
    expect <<-END
    spawn su - postgres -c "initdb -D data1 -U sstest -W"
    expect "Enter new superuser password:"
    send "123456\n"
    expect "Enter it again:"
    send "123456\n"
    expect eof
    exit
END
    CHECK_RESULT $?
    test -d /var/lib/pgsql/data1 && rm -rf /var/lib/pgsql/data1
    su - postgres -c "initdb -D data1 -X /var/lib/pgsql/data1/log/"
    CHECK_RESULT $?
    initdb -V | grep "(PostgreSQL)"
    CHECK_RESULT $?
    initdb -? | grep "Usage:"
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
