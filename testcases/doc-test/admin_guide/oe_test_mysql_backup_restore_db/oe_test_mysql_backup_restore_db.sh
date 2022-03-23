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
source ../common/mysql_pre.sh
function pre_test() {
    LOG_INFO "Start environment preparation."
    yum list | grep mysql.*-server
    if [ $? -eq 0 ]; then
        rm -rf /var/lib/mysql/*
	pck=`yum list | grep mysql.*-server | awk -F ' ' '{print $1}'`
        DNF_INSTALL ${pck}
        systemctl start mysqld
    else
        mysql_flag=1
        mysql_pre
    fi
    LOG_INFO "Environmental preparation is over."
}

function run_test() {
    LOG_INFO "Start executing testcase."
    expect -c "
    set timeout 10
    log_file testlog
    spawn mysql -u root -p
    expect {
        \"Enter*\" { send \"${mysql_passwd}\r\"; 
	expect \"mysql>\" { send \"alter user 'root'@'localhost' identified by '${NODE1_PASSWORD}';\r\"}
        expect \"mysql>\" { send \"CREATE DATABASE db1;\r\"}
        expect \"mysql>\" { send \"CREATE DATABASE db2;\r\"}
        expect \"mysql>\" { send \"use db1;\r\"}
        expect \"mysql>\" { send \"create table tb1(id int(3), num int(3));\r\"}
        expect \"mysql\" { send \"INSERT INTO tb1(id, num) VALUES (123, 123);\r\"}
        expect \"mysql>\" { send \"CREATE DATABASE db3;\r\"}
        expect \"mysql>\" { send \"use db3;\r\"}
        expect \"mysql>\" { send \"create table tb1(id int(3), name char(8));\r\"}
        expect \"mysql>\" { send \"SHOW DATABASES;\r\"}
        expect \"mysql>\" { send \"exit\r\"}
}
}
expect eof
"
    grep -iE "error|fail" testlog
    CHECK_RESULT $? 1
    grep '\|' testlog | grep "Database" -A 5 | grep -cwE 'db1|db2|db3'
    CHECK_RESULT $?
    rm -rf testlog

    expect -c "
    set timeout 10
    log_file testlog
    spawn mysql -u root -p
    expect {
        \"Enter*\" { send \"${NODE1_PASSWORD}\r\";
        expect \"mysql>\" { send \"create user 'root'@'%' identified by '${NODE1_PASSWORD}';\r\"}
        expect \"mysql>\" { send \"grant all privileges on *.* to 'root'@'%';\r\"}
        expect \"mysql>\" { send \"flush privileges;\r\"}
        expect \"mysql>\" { send \"exit\r\"}
}
}
expect eof
"
    grep -iE "error|fail" testlog
    CHECK_RESULT $? 1
    mysqldump -h ${NODE1_IPV4} -P 3306 -uroot -p${NODE1_PASSWORD} --all-databases >alldb.sql
    CHECK_RESULT $?
    grep "CREATE DATABASE .* `db1`" alldb.sql
    CHECK_RESULT $?
    grep "CREATE TABLE `tb1`" alldb.sql
    CHECK_RESULT $?
    grep "CREATE DATABASE .* `db2`" alldb.sql
    CHECK_RESULT $?
    grep "CREATE DATABASE .* `db3`" alldb.sql
    CHECK_RESULT $?

    mysqldump -h ${NODE1_IPV4} -P 3306 -uroot -p${NODE1_PASSWORD} --databases db1 >db1.sql
    CHECK_RESULT $?
    grep "CREATE TABLE `tb1`" db1.sql
    CHECK_RESULT $?
    grep "CREATE DATABASE .* `db1`" db1.sql
    CHECK_RESULT $?

    mysqldump -h ${NODE1_IPV4} -P 3306 -uroot -p${NODE1_PASSWORD} db1 tb1 >db1tb1.sql
    CHECK_RESULT $?
    grep "CREATE TABLE `tb1`" db1tb1.sql
    CHECK_RESULT $?

    rm -rf db1.sql
    mysqldump -h ${NODE1_IPV4} -P 3306 -uroot -p${NODE1_PASSWORD} -d db1 >db1.sql
    CHECK_RESULT $?
    grep "CREATE TABLE `tb1`" db1.sql
    CHECK_RESULT $?

    rm -rf db1.sql
    mysqldump -h ${NODE1_IPV4} -P 3306 -uroot -p${NODE1_PASSWORD} -t db1 >db1.sql
    CHECK_RESULT $?
    grep "INSERT INTO `tb1`" db1.sql
    CHECK_RESULT $?

    mysql -h ${NODE1_IPV4} -P 3306 -uroot -p${NODE1_PASSWORD} -t db3 <db1.sql
    CHECK_RESULT $?
    expect -c "
    log_file testlogm
    set timeout 10
    spawn mysql -u root -p
    expect {
        \"Enter*\" { send \"${NODE1_PASSWORD}\r\";
        expect \"mysql*\" { send \"use db3;\r\"}
        expect \"mysql*\" { send \"show tables;\r\"}
        expect \"mysql*\" { send \"exit\r\"}
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
        expect \"mysql>\" { send \"DROP DATABASE db1;\r\"}
        expect \"mysql>\" { send \"DROP DATABASE db2;\r\"}
	expect \"mysql>\" { send \"DROP DATABASE db3;\r\"}
	expect \"mysql>\" { send \"DROP USER 'root'@'%';\r\"}
        expect \"mysql>\" { send \"exit\r\"}
}
}
expect eof
"
    test -z ${mysql_flag} || clean_mysql
    rm -rf log testlog* db1.sql db1tb1.sql alldb.sql
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup."
}

main $@
