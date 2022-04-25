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
    mysql -e "CREATE DATABASE test45;use test45;CREATE TABLE mytexttable (id INT NOT NULL,txt TEXT NOT NULL,PRIMARY KEY (id),FULLTEXT (txt)) ENGINE=MyISAM;"
    CHECK_RESULT $?
    myisamchk -im /var/lib/mysql/test45/mytexttable
    CHECK_RESULT $?
    myisamchk -iFm /var/lib/mysql/test45/mytexttable
    CHECK_RESULT $?
    myisamchk -eis /var/lib/mysql/test45/mytexttable
    CHECK_RESULT $?
    myisamchk -rq /var/lib/mysql/test45/mytexttable | grep "recovering"
    CHECK_RESULT $?
    myisamchk -iBfqr /var/lib/mysql/test45/mytexttable | grep "Fixing index"
    CHECK_RESULT $?
    myisamchk --sort_buffer_size=16M --key_buffer_size=16M --read_buffer_size=1M --write_buffer_size=1M | grep "read-buffer-size" | grep "1048576"
    CHECK_RESULT $?
    myisamchk --description --verbose /var/lib/mysql/test45/mytexttable | grep "MyISAM file" | grep "/var/lib/mysql/test45/mytexttable"
    CHECK_RESULT $?
    myisamchk -Br /var/lib/mysql/test45/mytexttable | grep "recovering"
    CHECK_RESULT $?
    myisamchk -o /var/lib/mysql/test45/mytexttable | grep "recovering"
    CHECK_RESULT $?
    myisamchk -r /var/lib/mysql/test45/mytexttable | grep "recovering"
    CHECK_RESULT $?
    myisamchk -R 1 /var/lib/mysql/test45/mytexttable | grep "recovering"
    CHECK_RESULT $?
    LOG_INFO "End of testcase execution!"
}

function post_test() {
    LOG_INFO "Start environment cleanup."
    mysql -e "use test45;DROP TABLE mytexttable;DROP DATABASE test45"
    systemctl stop mysqld
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup."
}

main $@
