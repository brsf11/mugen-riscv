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
# @Desc      :   clusterdb
# ############################################

source ../common/lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    postgresql_install
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    su - postgres -c "pgbench -i"
    su - postgres -c "pgbench -r" 2>&1 | grep "starting vacuum...end"
    CHECK_RESULT $?
    su - postgres -c "pgbench -R 1" 2>&1 | grep "starting vacuum...end"
    CHECK_RESULT $?
    su - postgres -c "pgbench -s 1" 2>&1 | grep "starting vacuum...end"
    CHECK_RESULT $?
    su - postgres -c "pgbench -t 2" 2>&1 | grep "starting vacuum...end"
    CHECK_RESULT $?
    su - postgres -c "pgbench -T 10" 2>&1 | grep "starting vacuum...end"
    CHECK_RESULT $?
    su - postgres -c "pgbench -v" 2>&1 | grep "starting vacuum...end"
    CHECK_RESULT $?
    su - postgres -c "pgbench --sampling-rate=0.01 -l" 2>&1 | grep "starting vacuum...end"
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
