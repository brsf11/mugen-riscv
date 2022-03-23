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
# @Desc      :   POSTGRESQL create run delete
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
        expect \"Maria*\" { send \"CREATE DATABASE db1;\r\"}
        expect \"Maria*\" { send \"CREATE DATABASE db2;\r\"}
        expect \"Maria*\" { send \"use db1;\r\"}
	expect \"Maria*\" { send \"create table tb1(id int(3), id1 int (3));\r\"}
	expect \"Maria*\" { send \"INSERT INTO tb1(id, id1) VALUES (123,123);\r\"}
        expect \"Maria*\" { send \"CREATE DATABASE db3;\r\"}
        expect \"Maria*\" { send \"use db3;\r\"}
	expect \"Maria*\" { send \"create table tb1(id int(3), name char(8));\r\"}
        expect \"Maria*\" { send \"SHOW DATABASES;\r\"}
        expect \"Maria*\" { send \"exit\r\"}
}
}
expect eof
"
    grep '\|'  testlog | grep "Database" -A 5 | grep -cwE 'db1|db2|db3'
    CHECK_RESULT $?
    expect -c "
    set timeout 10
    log_file testlog1
    spawn mysql -u root -p 
    expect {
        \"Enter*\" { send \"${NODE1_PASSWORD}\r\";
        expect \"Maria*\" { send \"grant all privileges on *.* to 'root'@'$NODE1_IPV4' IDENTIFIED BY '$NODE1_PASSWORD' WITH GRANT OPTION;\r\"}
        expect \"Maria*\" { send \"flush privileges;\r\"}
        expect \"Maria*\" { send \"exit\r\"}
}
}
expect eof
"
    grep -iE "error|fail" testlog1
    CHECK_RESULT $? 1
    mysqldump -uroot -p${NODE1_PASSWORD} --all-databases >alldb.sql
    CHECK_RESULT $?
    grep "CREATE DATABASE .* `db1`" alldb.sql
    CHECK_RESULT $?
    grep "CREATE TABLE `tb1`" alldb.sql
    CHECK_RESULT $?
    grep "CREATE DATABASE .* `db2`" alldb.sql
    CHECK_RESULT $?
    grep "CREATE DATABASE .* `db3`" alldb.sql
    CHECK_RESULT $?

    mysqldump -uroot -p${NODE1_PASSWORD} --databases db1 >db1.sql
    grep "CREATE TABLE `tb1`" db1.sql
    CHECK_RESULT $?
    grep "CREATE DATABASE .* `db1`" db1.sql
    CHECK_RESULT $?

    mysqldump -uroot -p${NODE1_PASSWORD} db1 tb1 >db1tb1.sql
    CHECK_RESULT $?
    grep "CREATE TABLE `tb1`" db1tb1.sql
    CHECK_RESULT $?

    rm -rf db1.sql
    mysqldump -uroot -p${NODE1_PASSWORD} -d db1 >db1.sql
    grep "CREATE TABLE `tb1`" db1.sql
    CHECK_RESULT $?

    rm -rf db1.sql
    mysqldump -uroot -p${NODE1_PASSWORD} -t db1 >db1.sql
    CHECK_RESULT $?
    grep "INSERT INTO `tb1`" db1.sql
    CHECK_RESULT $?

    mysql -uroot -p${NODE1_PASSWORD} -t db3 <db1.sql
    CHECK_RESULT $?
    expect -c "
    log_file testlogm
    set timeout 10
    spawn mysql -u root -p 
    expect {
        \"Enter*\" { send \"${NODE1_PASSWORD}\r\";
        expect \"Maria*\" { send \"use db3;\r\"}
        expect \"Maria*\" { send \"show tables;\r\"}
        expect \"Maria*\" { send \"exit\r\"}
}
}
expect
"
    grep "tb1" testlogm
    CHECK_RESULT $?
    LOG_INFO "End of testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    expect -c "
    set timeout 10
    spawn mysql -u root -p 
    expect {
        \"Enter*\" { send \"${NODE1_PASSWORD}\r\";
        expect \"Maria*\" { send \"DROP DATABASE db1;\r\"}
        expect \"Maria*\" { send \"DROP DATABASE db2;\r\"}
        expect \"Maria*\" { send \"DROP DATABASE db3;\r\"}
        expect \"Maria*\" { send \"exit\r\"}
}
}
expect eof
"
    setenforce 1
    DNF_REMOVE
    userdel -r mysql
    groupdel mysql
    rm -rf db1.sql db1tb1.sql alldb.sql data tmp run testlog*
    LOG_INFO "Finish environment cleanup."
}

main $@
