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
    my_print_defaults --help | grep -A2 -B2 my.cnf
    CHECK_RESULT $?
    my_print_defaults mysqld server mysql_server mysql.server | grep mysql
    CHECK_RESULT $?
    mysql -e "CREATE DATABASE test45;use test45;CREATE TABLE mytexttable (id INT NOT NULL,txt TEXT NOT NULL,PRIMARY KEY (id),FULLTEXT (txt)) ENGINE=MyISAM;"
    CHECK_RESULT $?
    myisam_ftdump mytexttable 1
    CHECK_RESULT $?
    myisam_ftdump -c mytexttable 1 | sort -r
    CHECK_RESULT $?
    myisam_ftdump --help | grep "Display help and exit"
    CHECK_RESULT $?
    myisam_ftdump -d mytexttable 1
    CHECK_RESULT $?
    myisam_ftdump -l mytexttable 1
    CHECK_RESULT $?
    myisam_ftdump -s mytexttable 1
    CHECK_RESULT $?
    myisam_ftdump -? | grep "Synonym for -h"
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
