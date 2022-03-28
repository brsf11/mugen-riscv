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
# @Desc      :   Install, run and uninstall
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

    test -d /data && rm -rf /data
    mkdir /data

    test -d /data/mariadb || mkdir -p /data/mariadb
    cd /data/mariadb || exit
    mkdir data tmp run log
    chown -R mysql:mysql /data
    cd - || exit
    LOG_INFO "Environmental preparation is over."
}

function run_test() {
    LOG_INFO "Start executing testcase."
    rm -rf /var/lib/mysql/*
    DNF_INSTALL mariadb-server
    CHECK_RESULT $?
    systemctl start mariadb
    mysqladmin -uroot password $NODE1_PASSWORD
    CHECK_RESULT $?
    expect -c "
    log_file testlog
    spawn  mysql_secure_installation
    expect {
        \"*enter for none\)\" {send \"$NODE1_PASSWORD\r\"
        expect \"*\[Y\/n\]\" {send \"N\r\"}
        expect \"*\[Y\/n\]\" {send \"Y\r\"}
        expect \"*\[Y\/n\]\" {send \"Y\r\"}
        expect \"*\[Y\/n\]\" {send \"Y\r\"}
        expect \"*\[Y\/n\]\" {send \"Y\r\"}
}
}
expect eof
"
    grep -i "error" testlog
    CHECK_RESULT $? 1
    expect -c "
    set timeout 30
    log_file testlog
    spawn mysql -u root -p
    expect {
        \"Enter*\" {send \"${NODE1_PASSWORD}\r\"
        expect \"Maria*\" {send \"create database target_db;\r\"}
	    expect \"Maria*\" {send \"drop database target_db;\r\"}
        expect \"Maria*\" {send \"exit;\r\"}
}
}
expect eof
"
    grep -iE "fail|error" testlog
    CHECK_RESULT $? 1
    sql_pid=$(ps -ef | grep mysql | grep -v grep | grep -v test | awk '{print $2}')
    kill -9 ${sql_pid}
    CHECK_RESULT $?
    LOG_INFO "End of testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    setenforce 1
    userdel -r mysql
    groupdel mysql
    rm -rf testlog
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup."
}

main $@
