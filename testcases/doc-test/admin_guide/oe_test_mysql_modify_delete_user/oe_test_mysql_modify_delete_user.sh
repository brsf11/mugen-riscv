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
# @Desc      :   Modify user and delete user
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
        expect \"mysql>\" { send \"CREATE USER 'userexample'@'localhost' IDENTIFIED BY '123456';\r\"}
        expect \"mysql>\" { send \"CREATE USER 'userexample1'@'localhost' IDENTIFIED BY '123456';\r\"}
        expect \"mysql>\" { send \"SELECT USER,HOST FROM mysql.user;\r\"}
        expect \"mysql>\" { send \"exit\r\"}
}
}
expect eof
"
    grep -iE "error|fail|while executing" testlog
    CHECK_RESULT $? 1
    cat testlog | grep "SELECT USER" -A 10 | grep -w userexample | grep localhost
    CHECK_RESULT $?
    cat testlog | grep "SELECT USER" -A 10 | grep -w userexample1 | grep localhost
    CHECK_RESULT $?
    rm -rf testlog
    expect -c "
    set timeout 10
    log_file testlog
    spawn mysql -u root -p
    expect {
        \"Enter*\" { send \"${NODE1_PASSWORD}\r\";
	expect \"mysql>\" { send \"RENAME USER 'userexample1'@'localhost' TO 'userexample2'@'localhost';\r\"}
        expect \"mysql>\" { send \"SET PASSWORD FOR 'userexample'@'localhost' = '0123456';\r\"}
        expect \"mysql>\" { send \"DROP USER 'userexample'@'localhost';\r\"}
        expect \"mysql>\" { send \"SELECT USER,HOST FROM mysql.user;\r\"}
        expect \"mysql>\" { send \"exit\r\"}
}
}
expect eof
"
    grep -iE "error|fail|while executing" testlog
    CHECK_RESULT $? 1
    grep "SELECT USER" -A 10 testlog | grep -w userexample1 | grep localhost
    CHECK_RESULT $? 1
    grep "SELECT USER" -A 10 testlog | grep -w userexample2 | grep localhost
    CHECK_RESULT $?
    grep "SELECT USER" -A 10 testlog | grep -w userexample | grep localhost
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
        expect \"mysql>\" { send \"DROP USER 'userexample1'@'localhost';\r\"}
        expect \"mysql>\" { send \"exit\r\"}
}
}
expect eof
"
    test -z ${mysql_flag} || clean_mysql
    rm -rf testlog
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup."
}

main $@
