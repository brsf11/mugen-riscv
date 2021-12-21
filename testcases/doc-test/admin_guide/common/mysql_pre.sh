#!/usr/bin/bash

# Copyright (c) 2021. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   Classicriver
# @Contact   :   classicriver_jia@foxmail.com
# @Date      :   2020.4.27
# @License   :   Mulan PSL v2
# @Desc      :   mysql prepare
# ############################################

function mysql_pre() {
    grep -w mysql /etc/passwd && userdel mysql
    groupadd mysql
    useradd -g mysql mysql
    echo ${sql_password} | passwd --stdin mysql
    dir="/data/mysql"
    test -d ${dir} || mkdir -p ${dir}
    CHECK_RESULT $?
    rm -rf ${dir}/*
    mkdir -p ${dir}/data ${dir}/tmp ${dir}/run ${dir}/log
    chown -R mysql:mysql /data
    cd - || exit
    rm -rf /var/lib/mysql/*
    DNF_INSTALL mysql
    CHECK_RESULT $?
    rpm -qa | grep mysql
    CHECK_RESULT $?
    touch /etc/my.cnf
    echo "[mysqld_safe]
log-error=/data/mysql/log/mysql.log
pid-file=/data/mysql/run/mysqld.pid
[mysqldump]
quick
[mysql]
no-auto-rehash
[client]
default-character-set=utf8
[mysqld]
basedir=/usr/local/mysql
socket=/data/mysql/run/mysql.sock
tmpdir=/data/mysql/tmp
datadir=/data/mysql/data
default_authentication_plugin=mysql_native_password
port=3306
user=mysql" >/etc/my.cnf
    chown mysql:mysql /etc/my.cnf

    export PATH=${PATH}:/usr/local/mysql/bin
    mysqld --defaults-file=/etc/my.cnf --initialize >log 2>&1
    grep -iE "fail|error" log
    CHECK_RESULT $? 1
    mysql_passwd=$(grep root log | awk '{print $NF}')
    chmod 777 /usr/local/mysql/support-files/mysql.server
    \cp /usr/local/mysql/support-files/mysql.server /etc/init.d/mysql
    rm -rf /tmp/mysql.sock
    ln -s /data/mysql/run/mysql.sock /tmp/mysql.sock
    chkconfig mysql on
    [ -n ${mysql_passwd} ] || exit 1

    su - mysql -c "service mysql start" | grep "SUCCESS"
    CHECK_RESULT $?
    systemctl start mysql
    CHECK_RESULT $?
    systemctl status mysql | grep -wE 'running|active'
    CHECK_RESULT $?
    rm -rf log
}

function clean_mysql() {
    sql_pid=$(ps -ef | grep -w mysql | grep -v grep | awk '{print$2}')
    kill -9 ${sql_pid}
    rm -rf /data/mysql
    userdel -r mysql
    rm -rf /tmp/mysql.sock
}
