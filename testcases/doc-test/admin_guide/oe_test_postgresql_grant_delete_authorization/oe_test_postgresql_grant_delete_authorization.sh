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
# @Desc      :   Postgresql role authorization / deletion authorization
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
    test -d /tmp/data || mkdir -p /tmp/data
    chown -R postgres:postgres /tmp/data/
    DNF_INSTALL postgresql-server
    su - postgres -c "/usr/bin/initdb -D /tmp/data/"
    su - postgres -c "/usr/bin/pg_ctl -D /tmp/data/ -l /tmp/data/logfile start"
    LOG_INFO "Environmental preparation is over."
}

function run_test() {
    LOG_INFO "Start executing testcase."
    su - postgres -c "createuser roleexample1"
    /usr/bin/psql -U postgres >log <<EOF
CREATE DATABASE database1;
CREATE TABLE table1(
   ID INT PRIMARY KEY     NOT NULL,
   NAME           TEXT    NOT NULL,
   AGE            INT     NOT NULL,
   ADDRESS        CHAR(50),
   SALARY         REAL
);
GRANT CREATE ON DATABASE database1 TO roleexample1;
GRANT ALL PRIVILEGES ON TABLE table1 TO PUBLIC;
\z table1
\du
\q
EOF
    grep -iE "fail|error" log
    CHECK_RESULT $? 1
    table1=$(grep table1 -A 1 log | grep -c "arwdDxt")
    test $table1 -eq 2
    CHECK_RESULT $?
    /usr/bin/psql -U postgres >log <<EOF
REVOKE CREATE ON DATABASE database1 FROM roleexample1;
REVOKE ALL PRIVILEGES ON TABLE table1 FROM PUBLIC;
\z table1 
\du
drop table table1;
DROP ROLE roleexample1;
\q
EOF
    grep -iE "fail|error" log
    CHECK_RESULT $? 1
    table1=$(grep table1 -A 1 log | grep "arwdDxt" | wc -l)
    test $table1 -eq 1
    CHECK_RESULT $?
    LOG_INFO "End of testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    su - postgres -c "/usr/bin/pg_ctl -D /tmp/data/ -l /tmp/data/logfile stop"
    setenforce 1
    DNF_REMOVE
    userdel -r postgres
    groupdel postgres
    rm -rf /tmp/data log
    LOG_INFO "Finish environment cleanup."
}

main $@
