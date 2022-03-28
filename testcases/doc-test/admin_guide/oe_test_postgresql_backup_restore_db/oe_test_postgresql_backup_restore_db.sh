#!/usr/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
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
# @Date      :   2020.4.27
# @License   :   Mulan PSL v2
# @Desc      :   Backup / restore database
# ############################################
source ${OET_PATH}/libs/locallibs/common_lib.sh
function pre_test() {
    LOG_INFO "Start environment preparation."
    systemctl stop firewalld
    systemctl disable firewalld

    setenforce 0
    groupadd postgres
    useradd -g postgres postgres
    echo ${NODE1_PASSWORD} | passwd --stdin postgres
    test -d /tmp/data || mkdir /tmp/data
    rm -rf /tmp/data/*
    chown -R postgres:postgres /tmp/data/

    DNF_INSTALL postgresql-server
    su - postgres -c "/usr/bin/initdb -D /tmp/data/"
    su - postgres -c "/usr/bin/pg_ctl -D /tmp/data/ -l /tmp/data/logfile start"
    LOG_INFO "Environmental preparation is over."
}

function run_test() {
    LOG_INFO "Start executing testcase."
    /usr/bin/psql -U postgres >log <<EOF
CREATE DATABASE database1;
CREATE DATABASE newdb;
\l
\q
EOF
    grep "^\ database1" log
    CHECK_RESULT $?
    pg_dump -h localhost -U postgres -w database1 >db1.sql
    CHECK_RESULT $?
    find db1.sql
    CHECK_RESULT $?

    mv db1.sql db2.sql
    psql -h localhost -U postgres -w -d newdb <db2.sql
    CHECK_RESULT $?
    LOG_INFO "End of testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    su - postgres -c "/usr/bin/pg_ctl -D /tmp/data/ -l /tmp/data/logfile stop"
    setenforce 1
    DNF_REMOVE
    rm -rf log /tmp/data db2.sql
    userdel -r postgres
    groupdel postgres
    LOG_INFO "Finish environment cleanup."
}

main $@
