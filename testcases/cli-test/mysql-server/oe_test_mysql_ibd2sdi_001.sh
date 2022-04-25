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
    mysql -e "CREATE DATABASE test45;use test45;CREATE TABLE mytable (id INT);use test45;INSERT INTO mytable VALUES(1)"
    CHECK_RESULT $?
    test -f /var/lib/mysql/test45/mytable.ibd
    CHECK_RESULT $?
    SLEEP_WAIT 10
    ibd2sdi --dump-file=test.txt /var/lib/mysql/test45/mytable.ibd
    CHECK_RESULT $?
    grep "mytable" test.txt
    CHECK_RESULT $?
    version=$(rpm -qa | grep mysql-server | cut -d "-" -f 3)
    CHECK_RESULT $?
    ibd2sdi -v | grep "${version}"
    CHECK_RESULT $?
    ibd2sdi -h | grep -i "Usage: ibd2sdi"
    CHECK_RESULT $?
    ibd2sdi --skip-data /var/lib/mysql/test45/mytable.ibd | grep "type"
    CHECK_RESULT $?
    ibd2sdi --id=10 /var/lib/mysql/test45/mytable.ibd | grep 'ibd2sdi'
    CHECK_RESULT $?
    ibd2sdi --type=1 /var/lib/mysql/test45/mytable.ibd | grep '"type": 1'
    CHECK_RESULT $?
    ibd2sdi --strict-check=innodb /var/lib/mysql/test45/mytable.ibd | grep "mytable"
    CHECK_RESULT $?
    ibd2sdi -c crc32 /var/lib/mysql/test45/mytable.ibd | grep "./test45/mytable.ibd"
    CHECK_RESULT $?
    ibd2sdi --no-check /var/lib/mysql/test45/mytable.ibd | grep "InnoDB"
    CHECK_RESULT $?
    LOG_INFO "End of testcase execution!"
}

function post_test() {
    LOG_INFO "Start environment cleanup."
    systemctl stop mysqld
    rm -rf test.txt ib_sdipGMuTI
    mysql -e "use test45;DROP TABLE mytexttable;DROP DATABASE test45"
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup."
}

main $@
