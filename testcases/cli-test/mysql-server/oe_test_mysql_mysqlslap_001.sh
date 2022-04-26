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
    mysql -e "DROP DATABASE test45"
    mysql -e "CREATE DATABASE test45;use test45;CREATE TABLE mytable (id INT)"
    CHECK_RESULT $?
    mysql -e "use test45;INSERT INTO mytable VALUES(1)"
    CHECK_RESULT $?
    mysqldump test45 mytable >query.sql
    CHECK_RESULT $?
    test -f query.sql
    CHECK_RESULT $?
    mysqldump --add-drop-table test45 >create.sql
    CHECK_RESULT $?
    test -f create.sql
    CHECK_RESULT $?
    mysqlslap --concurrency=5 --iterations=5 --query=query.sql --create=create.sql --delimiter=";" | grep "running"
    CHECK_RESULT $?
    mysql -e "CREATE DATABASE mysqlslap"
    CHECK_RESULT $?
    mysqlslap --delimiter=";" --create="CREATE TABLE mytable1 (b int);INSERT INTO mytable1 VALUES (23)" --query="SELECT * FROM mytable1" --concurrency=50 --iterations=200 | grep "Benchmark"
    CHECK_RESULT $?
    mysqlslap --concurrency=5 --iterations=20 --number-int-cols=2 --number-char-cols=3 --auto-generate-sql 
    CHECK_RESULT $?
    mysqlslap -a -c 100 2>&1 | grep "Number of clients running queries: 100"
    CHECK_RESULT $?
    mysqlslap -a --auto-generate-sql-secondary-indexes=5 2>&1 | grep "Number of clients running queries: 1"
    CHECK_RESULT $?
    mysqlslap --auto-generate-sql-write-number=100 | grep "Benchmark"
    CHECK_RESULT $?
    mysqlslap --auto-generate-sql-write-number=100 --only-print
    CHECK_RESULT $?
    mysqlslap --create-schema=mysql --csv=use
    CHECK_RESULT $?
    grep "mixed" use
    CHECK_RESULT $?
    LOG_INFO "End of testcase execution!"
}

function post_test() {
    LOG_INFO "Start environment cleanup."
    rm -rf use *.sql test.txt
    mysql -e "DROP database mysqlslap;use test45;DROP TABLE mytexttable;DROP DATABASE test45"
    systemctl stop mysqld
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup."
}

main $@
