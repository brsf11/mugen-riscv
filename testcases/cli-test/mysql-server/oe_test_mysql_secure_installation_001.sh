#!/usr/bin/bash

# Copyright (c) 2022 Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   duanxuemin
# @Contact   :   duanxuemin_job@163.com
# @Date      :   2022-04-09
# @License   :   Mulan PSL v2
# @Desc      :   mysql-server command test
# ############################################
source ${OET_PATH}/libs/locallibs/common_lib.sh
function pre_test() {
    LOG_INFO "Start to prepare the test environment!"
    rm -rf /var/lib/mysql/*
    DNF_INSTALL mysql-server
    systemctl start mysqld
    LOG_INFO "End to prepare the test environment!"
}

function run_test() {
    LOG_INFO "Start executing testcase!"
    systemctl status mysqld | grep running
    CHECK_RESULT $?
    mysqladmin -u root password ${NODE1_PASSWORD}
    CHECK_RESULT $?
    expect -c "
    set timeout 60
    log_file testlog
    spawn mysql_secure_installation --host=localhost --port=3307
    expect {
        \"Enter password for user root*\" { send \"${NODE1_PASSWORD}\n\"; 
        expect \"*Press y|Y for Yes, any other key for No*\" { send \"No\n\"}
        expect \"*Press y|Y for Yes, any other key for No*\" { send \"No\n\"}
        expect \"*Press y|Y for Yes, any other key for No*\" { send \"No\n\"}
        expect \"*Press y|Y for Yes, any other key for No*\" { send \"No\n\"}
        expect \"*Press y|Y for Yes, any other key for No*\" { send \"No\n\"}
	expect \"*Press y|Y for Yes, any other key for No*\" { send \"No\n\"}
}
}
expect eof
"
    grep -i "all done" testlog
    CHECK_RESULT $?
    rm -rf testlog

    expect -c "
    set timeout 60
    log_file testlog
    spawn mysql_secure_installation
    expect {
        \"Enter password for user root*\" { send \"${NODE1_PASSWORD}\n\";
        expect \"*Press y|Y for Yes, any other key for No*\" { send \"No\n\"}
        expect \"*Press y|Y for Yes, any other key for No*\" { send \"No\n\"}
        expect \"*Press y|Y for Yes, any other key for No*\" { send \"No\n\"}
        expect \"*Press y|Y for Yes, any other key for No*\" { send \"No\n\"}
        expect \"*Press y|Y for Yes, any other key for No*\" { send \"No\n\"}
	expect \"*Press y|Y for Yes, any other key for No*\" { send \"No\n\"}
}
}
expect eof
"
    grep -i "all done" testlog
    CHECK_RESULT $?
    rm -rf testlog

    expect -c "
    set timeout 30
    log_file testlog
    spawn mysql_secure_installation --no-defaults
    expect {
        \"Enter password for user root*\" { send \"${NODE1_PASSWORD}\r\";
        expect \"*Press y|Y for Yes, any other key for No*\" { send \"No\r\"}
        expect \"*Press y|Y for Yes, any other key for No*\" { send \"No\r\"}
        expect \"*Press y|Y for Yes, any other key for No*\" { send \"No\r\"}
        expect \"*Press y|Y for Yes, any other key for No*\" { send \"No\r\"}
        expect \"*Press y|Y for Yes, any other key for No*\" { send \"No\r\"}
	expect \"*Press y|Y for Yes, any other key for No*\" { send \"No\n\"}
}
}
expect eof
"
    grep -i "all done" testlog
    CHECK_RESULT $?
    rm -rf testlog

    expect -c "
    set timeout 30
    log_file testlog
    spawn mysql_secure_installation mysql_secure_installation --defaults-file=/etc/my.cnf
    expect {
        \"Enter password for user root*\" { send \"${NODE1_PASSWORD}\r\";
        expect \"*Press y|Y for Yes, any other key for No*\" { send \"No\r\"}
        expect \"*Press y|Y for Yes, any other key for No*\" { send \"No\r\"}
        expect \"*Press y|Y for Yes, any other key for No*\" { send \"No\r\"}
        expect \"*Press y|Y for Yes, any other key for No*\" { send \"No\r\"}
        expect \"*Press y|Y for Yes, any other key for No*\" { send \"No\r\"}
	expect \"*Press y|Y for Yes, any other key for No*\" { send \"No\n\"}
}
}
expect eof
"
    grep -i "all done" testlog
    CHECK_RESULT $?
    rm -rf testlog

    expect -c "
    set timeout 30
    log_file testlog
    spawn mysql_secure_installation --defaults-extra-file=/etc/my.cnf
    expect {
        \"Enter password for user root*\" { send \"${NODE1_PASSWORD}\r\";
        expect \"*Press y|Y for Yes, any other key for No*\" { send \"No\r\"}
        expect \"*Press y|Y for Yes, any other key for No*\" { send \"No\r\"}
        expect \"*Press y|Y for Yes, any other key for No*\" { send \"No\r\"}
        expect \"*Press y|Y for Yes, any other key for No*\" { send \"No\r\"}
        expect \"*Press y|Y for Yes, any other key for No*\" { send \"No\r\"}
	expect \"*Press y|Y for Yes, any other key for No*\" { send \"No\n\"}
}
}
expect eof
"
    grep -i "all done" testlog
    CHECK_RESULT $?
    rm -rf testlog

    expect -c "
    set timeout 30
    log_file testlog
    spawn mysql_secure_installation --defaults-group-suffix=group
    expect {
        \"Enter password for user root*\" { send \"${NODE1_PASSWORD}\r\";
        expect \"*Press y|Y for Yes, any other key for No*\" { send \"No\r\"}
        expect \"*Press y|Y for Yes, any other key for No*\" { send \"No\r\"}
        expect \"*Press y|Y for Yes, any other key for No*\" { send \"No\r\"}
        expect \"*Press y|Y for Yes, any other key for No*\" { send \"No\r\"}
        expect \"*Press y|Y for Yes, any other key for No*\" { send \"No\r\"}
	expect \"*Press y|Y for Yes, any other key for No*\" { send \"No\n\"}
}
}
expect eof
"
    grep -i "all done" testlog
    CHECK_RESULT $?
    rm -rf testlog

    expect -c "
    set timeout 30
    log_file testlog
    spawn mysql_secure_installation --ssl-ca=/var/lib/mysql/ca.pem
    expect {
        \"Enter password for user root*\" { send \"${NODE1_PASSWORD}\r\";
        expect \"*Press y|Y for Yes, any other key for No*\" { send \"No\r\"}
        expect \"*Press y|Y for Yes, any other key for No*\" { send \"No\r\"}
        expect \"*Press y|Y for Yes, any other key for No*\" { send \"No\r\"}
        expect \"*Press y|Y for Yes, any other key for No*\" { send \"No\r\"}
        expect \"*Press y|Y for Yes, any other key for No*\" { send \"No\r\"}
	expect \"*Press y|Y for Yes, any other key for No*\" { send \"No\n\"}
}
}
expect eof
"
    grep -i "all done" testlog
    CHECK_RESULT $?
    rm -rf testlog

    expect -c "
    set timeout 30
    log_file testlog
    spawn mysql_secure_installation --ssl-key=/var/lib/mysql/ca-key.pem
    expect {
        \"Enter password for user root*\" { send \"${NODE1_PASSWORD}\r\";
        expect \"*Press y|Y for Yes, any other key for No*\" { send \"No\r\"}
        expect \"*Press y|Y for Yes, any other key for No*\" { send \"No\r\"}
        expect \"*Press y|Y for Yes, any other key for No*\" { send \"No\r\"}
        expect \"*Press y|Y for Yes, any other key for No*\" { send \"No\r\"}
        expect \"*Press y|Y for Yes, any other key for No*\" { send \"No\r\"}
	expect \"*Press y|Y for Yes, any other key for No*\" { send \"No\n\"}
}
}
expect eof
"
    grep -i "all done" testlog
    CHECK_RESULT $?
    rm -rf testlog

    expect -c "
    set timeout 30
    log_file testlog
    spawn mysql_secure_installation ----ssl-cert=server-cert.pem
    expect {
        \"Enter password for user root*\" { send \"${NODE1_PASSWORD}\n\";
        expect \"*Press y|Y for Yes, any other key for No*\" { send \"No\n\"}
        expect \"*Press y|Y for Yes, any other key for No*\" { send \"No\n\"}
        expect \"*Press y|Y for Yes, any other key for No*\" { send \"No\n\"}
        expect \"*Press y|Y for Yes, any other key for No*\" { send \"No\n\"}
        expect \"*Press y|Y for Yes, any other key for No*\" { send \"No\n\"}
	expect \"*Press y|Y for Yes, any other key for No*\" { send \"No\n\"}
}
}
expect eof
"
    grep -i "all done" testlog
    CHECK_RESULT $?
    rm -rf testlog
    mysql_secure_installation --print-defaults | grep "started"
    CHECK_RESULT $?
    mysql_secure_installation --help | grep "Display this help and exit"
    CHECK_RESULT $?
    LOG_INFO "End of testcase execution!"
}

function post_test() {
    LOG_INFO "Start environment cleanup."
    systemctl stop mysqld
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup."
}

main $@
