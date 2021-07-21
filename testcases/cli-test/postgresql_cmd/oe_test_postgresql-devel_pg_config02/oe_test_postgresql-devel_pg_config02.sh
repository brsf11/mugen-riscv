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
# @Desc      :   pg_config
# ############################################

source ../common/lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    postgresql_install
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    pg_config --sharedir | grep "/usr/share/pgsql"
    CHECK_RESULT $?
    pg_config --sysconfdir | grep "/etc"
    CHECK_RESULT $?
    pg_config --pgxs | grep "pgxs.mk"
    CHECK_RESULT $?
    pg_config --configure | grep "build"
    CHECK_RESULT $?
    pg_config --cc | grep "gcc"
    CHECK_RESULT $?
    pg_config --cppflags | grep "D_GNU_SOURCE"
    CHECK_RESULT $?
    pg_config --cflags | grep "Wall"
    CHECK_RESULT $?
    pg_config --cflags_sl | grep "fPIC"
    CHECK_RESULT $?
    pg_config --ldflags | grep "Wl"
    CHECK_RESULT $?
    pg_config --ldflags_ex
    CHECK_RESULT $?
    pg_config --ldflags_sl
    CHECK_RESULT $?
    pg_config --libs | grep "lpgcommon"
    CHECK_RESULT $?
    pg_config --version | grep "PostgreSQL"
    CHECK_RESULT $?
    pg_config -? | grep "Usage:"
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
