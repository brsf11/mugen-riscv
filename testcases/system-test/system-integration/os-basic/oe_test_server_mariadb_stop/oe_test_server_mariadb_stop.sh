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
# @Author    :   Classicriver_jia
# @Contact   :   classicriver_jia@foxmail.com
# @Date      :   2020-4-9
# @License   :   Mulan PSL v2
# @Desc      :   Repeatedly starting and stopping the MARIADB database
# #############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh
function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL "mariadb-server mariadb"
    rm -rf /var/lib/mysql/*
    systemctl start mariadb.service
    systemctl status mariadb.service | grep running || exit 1
    mysqladmin -uroot password ${NODE1_PASSWORD}
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    for count_sql in $(seq 1 10); do
        systemctl enable mariadb.service
        systemctl start mariadb.service
        CHECK_RESULT $?
        systemctl restart mariadb.service
        CHECK_RESULT $?
        systemctl stop mariadb.service
        systemctl disable mariadb.service
        CHECK_RESULT $?
        SLEEP_WAIT 2
    done
    systemctl enable mariadb.service
    systemctl start mariadb.service
    CHECK_RESULT $?
    expect -c "
            log_file testlog
            set timeout 30
            spawn mysql -u root -p
            expect {
                \"Enter password*\" {send \"${NODE1_PASSWORD}\r\";
                expect \"MariaDB*\" {send \"CREATE DATABASE databaseexample;\r\"}
                expect \"MariaDB*\" {send \"show databases;\r\"}
                expect \"MariaDB*\" {send \"exit\r\"}}
            }
    	expect eof
    "
    grep -w "show databases" -A 12 testlog | grep databaseexample
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf testlog
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}

main $@
