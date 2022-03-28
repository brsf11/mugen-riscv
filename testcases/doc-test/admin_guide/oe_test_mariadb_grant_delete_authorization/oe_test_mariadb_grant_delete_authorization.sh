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
# @Desc      :   User authorization / delete user permissions
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

    test -d /data/mariadb || mkdir -p /data/mariadb
    cd /data/mariadb || exit
    mkdir data tmp run log
    chown -R mysql:mysql /data
    cd - || exit
    DNF_INSTALL mariadb-server
    rm -rf /var/lib/mysql/*
    systemctl start mariadb
    mysqladmin -uroot password ${NODE1_PASSWORD}
    expect -c "
    set timeout 10
    log_file testlog
    spawn mysql -u root -p 
    expect {
        \"Enter*\" { send \"${NODE1_PASSWORD}\r\";
        expect \"Maria*\" { send \"CREATE USER 'userexample'@'localhost' IDENTIFIED BY '123456';\r\"}
        expect \"Maria*\" { send \"SELECT USER,HOST,PASSWORD FROM mysql.user;\r\"}
        expect \"Maria*\" { send \"exit\r\"}
}
}
expect eof
"
    cat testlog | grep "SELECT USER" -A 10 | grep -w userexample | grep localhost
    rm -rf testlog
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
        expect \"Maria*\" { send \"GRANT SELECT,INSERT ON *.* TO 'userexample'@'localhost';\r\"}
        expect \"Maria*\" { send \"SHOW GRANTS FOR 'userexample'@'localhost';\r\"}
        expect \"Maria*\" { send \"exit\r\"}
}
}
expect eof
"
    cat testlog | grep "SHOW GRANTS FOR" -A 10 | grep -w userexample | grep localhost | grep SELECT | grep INSERT
    CHECK_RESULT $?
    rm -rf testlog
    expect -c "
    set timeout 10
    log_file testlog
    spawn mysql -u root -p 
    expect {
        \"Enter*\" { send \"${NODE1_PASSWORD}\r\";
	    expect \"Maria*\" { send \"REVOKE INSERT ON *.* FROM 'userexample'@'localhost';\r\"}
        expect \"Maria*\" { send \"SHOW GRANTS FOR 'userexample'@'localhost';\r\"}
        expect \"Maria*\" { send \"exit\r\"}
}
}
expect eof
"
    CHECK_RESULT $?
    cat testlog | grep "SHOW GRANTS FOR" -A 10 | grep -w userexample | grep localhost | grep SELECT
    CHECK_RESULT $?
    cat testlog | grep "SHOW GRANTS FOR" -A 10 | grep -w userexample | grep localhost | grep SELECT | grep INSERT
    CHECK_RESULT $? 1
    LOG_INFO "End of testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    expect -c "
    set timeout 10
    spawn mysql -u root -p 
    expect {
        \"Enter*\" { send \"${NODE1_PASSWORD}\r\";
        expect \"Maria*\" { send \"DROP USER 'userexample'@'localhost';\r\"}
        expect \"Maria*\" { send \"exit\r\"}
}
}
expect eof
"
    setenforce 1
    DNF_REMOVE
    userdel -r mysql
    groupdel mysql
    rm -rf testlog
    LOG_INFO "Finish environment cleanup."
}

main $@
