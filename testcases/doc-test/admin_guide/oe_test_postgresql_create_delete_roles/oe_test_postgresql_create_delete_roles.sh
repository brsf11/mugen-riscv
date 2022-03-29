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
# @Desc      :   Postgresql create / delete roles
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
    test -d /tmp/data || mkdir -p  /tmp/data
    chown -R postgres:postgres /tmp/data/
    DNF_INSTALL postgresql-server
    su - postgres -c "/usr/bin/initdb -D /tmp/data/"
    su - postgres -c "/usr/bin/pg_ctl -D /tmp/data/ -l /tmp/data/logfile start"
    LOG_INFO "Environmental preparation is over."
}

function run_test() {
    LOG_INFO "Start executing testcase."
    /usr/bin/psql -U postgres >log <<EOF
CREATE ROLE roleexample1 LOGIN;
CREATE ROLE roleexample2 WITH LOGIN PASSWORD '123456';
\du
\q
EOF
    role_count=$(grep -iE "roleexample1|roleexample2" log | wc -l)
    test 2 -eq $role_count
    CHECK_RESULT $?
    su - postgres -c "createuser roleexample3"
    CHECK_RESULT $?
    /usr/bin/psql -U postgres >log <<EOF
\du
\q
EOF
    grep roleexample3 log
    CHECK_RESULT $?
    rm -rf log
    /usr/bin/psql -U postgres >log <<EOF
SELECT * from pg_roles where rolname='roleexample1';
DROP ROLE roleexample1;
\q
EOF
    grep -iE 'error|fail' log
    CHECK_RESULT $? 1
    grep roleexample1 log
    CHECK_RESULT $?
    rm -rf log
    /usr/bin/psql -U postgres >log <<EOF
ROP ROLE roleexample1;
\du
\q
EOF
    grep -iE 'error|fail' log
    CHECK_RESULT $? 1
    grep roleexample1 log
    CHECK_RESULT $? 1
    rm -rf log
    su - postgres -c "dropuser roleexample2"
    /usr/bin/psql -U postgres >log <<EOF
\du
\q
EOF
    grep -iE 'error|fail' log
    CHECK_RESULT $? 1
    grep roleexample2 log
    CHECK_RESULT $? 1
    LOG_INFO "End of testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    su - postgres -c "dropuser roleexample3"
    su - postgres -c "/usr/bin/pg_ctl -D /tmp/data/ -l /tmp/data/logfile stop"
    setenforce 1
    DNF_REMOVE
    userdel -r postgres
    groupdel postgres
    rm -rf /tmp/data log
    LOG_INFO "Finish environment cleanup."
}

main $@
