#!/usr/bin/bash

# Copyright (c) 2022 Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   duanxuemin
# @Contact   :   duanxuemin_job@163.com
# @Date      :   2022-04-09
# @License   :   Mulan PSL v2
# @Desc      :   mysql-server command test
# ############################################
source ${OET_PATH}/libs/locallibs/common_lib.sh
function pre_test() {
    LOG_INFO "Start to prepare the test environment!"
    rm -rf /var/lib/mysql/*
    DNF_INSTALL mysql-server
    systemctl start mysqld
    LOG_INFO "End to prepare the test environment!"
}

function run_test() {
    LOG_INFO "Start executing testcase!"
    systemctl status mysqld | grep running
    CHECK_RESULT $?
    mysql -e "DROP DATABASE db"
    mysql -e "create database db;use db;create table my (id int)"
    CHECK_RESULT $?
    mysqlshow --print-defaults db my id | grep "db my id"
    CHECK_RESULT $?
    mysqlshow --no-defaults db my id | grep "Database: db  Table: my  Wildcard: id"
    CHECK_RESULT $?
    mysqlshow --defaults-file=/etc/my.cnf >dbfile
    CHECK_RESULT $?
    grep "db" dbfile
    CHECK_RESULT $?
    mysqlshow --defaults-extra-file=/etc/my.cnf >dbfile1
    grep "db" dbfile1
    CHECK_RESULT $?
    mysqlshow --count db 2>&1 | grep "1 row in set"
    CHECK_RESULT $?
    mysqlshow --debug-info 2>&1 | grep "Maximum resident set size"
    CHECK_RESULT $?
    mysqlshow --default-auth=test >dbfile2
    CHECK_RESULT $?
    grep "db" dbfile2
    CHECK_RESULT $?
    mysqlshow --help | grep "Usage:"
    CHECK_RESULT $?
    mysqlshow -i -k db | grep "Database: db"
    CHECK_RESULT $?
    mysqlshow --verbose db | grep "1 row in set"
    CHECK_RESULT $?
    mysqlshow --show-table-type db | grep my
    CHECK_RESULT $?
    mysqlshow --get-server-public-key db my | grep "Database: db  Table: my"
    CHECK_RESULT $?
    version=$(rpm -qa | grep mysql-server | cut -d "-" -f 3)
    mysqlshow -V | grep "${version}"
    CHECK_RESULT $?
    mysqlshow --ssl-fips-mode=OFF --compression-algorithms=zstd | grep "db"
    CHECK_RESULT $?
    LOG_INFO "End of testcase execution!"
}

function post_test() {
    LOG_INFO "Start environment cleanup."
    rm -rf dbfile*
    mysql -e "use db;DROP TABLE my;DROP DATABASE db"
    systemctl stop mysqld
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup."
}

main $@
