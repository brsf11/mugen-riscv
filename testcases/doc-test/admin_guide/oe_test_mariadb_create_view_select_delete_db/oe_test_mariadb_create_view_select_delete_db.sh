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
# @Desc      :   Create, view, select, delete database
# ############################################
source ${OET_PATH}/libs/locallibs/common_lib.sh
function pre_test() {
    LOG_INFO "Start environment preparation."
    systemctl stop firewalld
    systemctl disable firewalld

    setenforce 0
    groupadd mysql
    useradd -g mysql mysql
    echo ${NODE1_PASSWORD} | passwd --stdin mysql
    test -d /data || mkdir data
    test -d /data/mariadb || mkdir -p /data/mariadb
    cd /data/mariadb || exit
    mkdir data tmp run log
    chown -R mysql:mysql /data
    cd - || exit
    DNF_INSTALL mariadb-server
    CHECK_RESULT $?
    rm -rf /var/lib/mysql/*
    systemctl start mariadb
    mysqladmin -uroot password ${NODE1_PASSWORD}
    LOG_INFO "Environmental preparation is over."
}

function run_test() {
    LOG_INFO "Start executing testcase."
    expect -c "
    set timeout 10
    log_file testlog
    spawn mysql -u root -p 
    expect {
        \"Enter*\" { send \"${NODE1_PASSWORD}\r\";
        expect \"Maria*\" { send \"CREATE DATABASE databaseexample;\r\"}
        expect \"Maria*\" { send \"SHOW DATABASES;\r\"}
        expect \"Maria*\" { send \"USE databaseexample;\r\"}
        expect \"Maria*\" { send \"DROP DATABASE databaseexample;\r\"}
        expect \"Maria*\" { send \"SHOW DATABASES;\r\"}
        expect \"Maria*\" { send \"exit\r\"}
}
}
expect eof
"
    cat testlog | grep -v changed | grep -w "Database" -A 5 | grep -w databaseexample
    CHECK_RESULT $?
    cat testlog | grep "USE databaseexample" -A 2 | grep "Database changed"
    CHECK_RESULT $?
    CHECK_RESULT $(cat testlog | grep -v changed | grep -w "Database" -A 5 | grep -w databaseexample | wc -l) 1
    LOG_INFO "End of testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    setenforce 1
    DNF_REMOVE
    userdel -r mysql
    groupdel mysql
    rm -rf testlog
    LOG_INFO "Finish environment cleanup."
}

main $@
