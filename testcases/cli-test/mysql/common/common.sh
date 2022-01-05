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
# @Author    :   huangrong 
# @Contact   :   1820463064@qq.com
# @Date      :   2020.4.27
# @License   :   Mulan PSL v2
# @Desc      :   mysql prepare
# ############################################

source "../common/common_lib.sh"

function mysql_pre() {
    systemctl stop firewalld
    systemctl disable firewalld
    flag=false
    if [ $(getenforce | grep Enforcing) ]; then
        setenforce 0
        flag=true
    fi
    groupadd mysql
    useradd -g mysql mysql
    echo ${NODE1_PASSWORD} | passwd --stdin mysql
    mkdir -p /data/mysql
    cd /data/mysql || exit 1
    mkdir data tmp run log
    touch {/data/mysql/log/mysql.log,/data/mysql/run/mysqld.pid}
    chown -R mysql:mysql /data
    cd - || exit 1
    DNF_INSTALL mysql
    rpm -qa | grep mysql || exit 1
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
    echo export PATH=${PATH}:/usr/local/mysql/bin >>/etc/profile
    source /etc/profile > /dev/null 2>&1
    rm -rf /data/mysql/data
    mysqld --initialize --basedir=/usr/local/mysql/ --datadir=/data/mysql/data --user=mysql 2>&1
    chkconfig mysql on
    systemctl daemon-reload
    systemctl start mysql
}


function mysql_post() {
    userdel -r mysql
    rm -rf /data /etc/my.cnf
    if [ ${flag} = 'true' ]; then
        setenforce 1
    fi
    systemctl start firewalld
    systemctl enable firewalld
}
