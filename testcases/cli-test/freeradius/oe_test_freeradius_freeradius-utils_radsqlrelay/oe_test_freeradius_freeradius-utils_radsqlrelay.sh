#!/usr/bin/bash

# Copyright (c) 2021. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

####################################
#@Author        :   wangjingfeng
#@Contact       :   1136232498@qq.com
#@Date          :   2020/12/24
#@License       :   Mulan PSL v2
#@Desc          :   freeradius-utils command parameter automation use case
####################################
source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."

    DNF_INSTALL "freeradius freeradius-utils perl-DBD-MySQL mysql5 mysql5-server freeradius-mysql"
    systemctl start mysqld
    SLEEP_WAIT 2
    mysqladmin -uroot password Test123
    mysql -uroot -pTest123 -e "create database radius;
                               use radius;
                               source /etc/raddb/mods-config/sql/main/mysql/schema.sql;                       
    "
    sed -i 's/driver = "rlm_sql_null"/driver = "rlm_sql_mysql"/g' /etc/raddb/mods-available/sql
    sed -i 's/dialect = "sqlite"/dialect = "mysql"/g' /etc/raddb/mods-available/sql
    sed -i '/server = "localhost"/a server = "localhost"' /etc/raddb/mods-available/sql
    sed -i '/port = 3306/a port = 3306' /etc/raddb/mods-available/sql
    sed -i '/login = "radius"/a login = "root"' /etc/raddb/mods-available/sql
    sed -i '/password = "radpass"/a password = "Test123"' /etc/raddb/mods-available/sql
    ln -s /etc/raddb/mods-available/sql /etc/raddb/mods-enabled/
    echo "insert into radcheck (username,attribute,op,value) values ('wjf','Cleartext-Password',':=','wjf123');" >/tmp/radius.sql

    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."

    radsqlrelay -? 2>&1 | grep "usage"
    CHECK_RESULT $? 0 0 "radsqlrelay -? execution failed."
    radsqlrelay -1 -d mysql -b radius -h localhost -p Test123 -u root /tmp/radius.sql
    mysql -uroot -pTest123 -e "use radius;
                               select * from radcheck where username='wjf';
    " | grep "wjf" && [ ! -e /tmp/radius.sql ]
    CHECK_RESULT $? 0 0 "radsqlrelay -1 -d -b -h -p -u execution failed."
    echo "Test123" >/tmp/passwdfile.txt
    mysql -uroot -pTest123 -e "use radius;
                               delete from radcheck where username='wjf';
    "
    echo "insert into radcheck (username,attribute,op,value) values ('wjf','Cleartext-Password',':=','wjf123');" >/tmp/radius.sql
    radsqlrelay -1 -d mysql -b radius -h localhost -f /tmp/passwdfile.txt -u root /tmp/radius.sql
    mysql -uroot -pTest123 -e "use radius;
                               select * from radcheck where username='wjf';
    " | grep "wjf" && [ ! -e /tmp/radius.sql ]
    CHECK_RESULT $? 0 0 "radsqlrelay -f execution failed."
    mysql -uroot -pTest123 -e "use radius;
                               delete from radcheck where username='wjf';
    "
    echo "insert into radcheck (username,attribute,op,value) values ('wjf','Cleartext-Password',':=','wjf123');" >/tmp/radius.sql
    radsqlrelay -1 -d mysql -b radius -h 127.0.0.1 -p Test123 -u root -P 3306 /tmp/radius.sql
    mysql -uroot -pTest123 -e "use radius;
                               select * from radcheck where username='wjf';
    " | grep "wjf" && [ ! -e /tmp/radius.sql ]
    CHECK_RESULT $? 0 0 "radsqlrelay -P execution failed."
    mysql -uroot -pTest123 -e "use radius;
                               delete from radcheck where username='wjf';
    "
    echo "insert into radcheck (username,attribute,op,value) values ('wjf','Cleartext-Password',':=','wjf123');" >/tmp/radius.sql
    radsqlrelay -1 -d mysql -b radius -h localhost -p Test123 -u root -x /tmp/radius.sql | grep "Connecting to DBI"
    CHECK_RESULT $? 0 0 "radsqlrelay -x execution failed."

    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."

    systemctl stop mysqld
    SLEEP_WAIT 2
    DNF_REMOVE
    rm -rf /var/lib/mysql
    rm -rf /etc/raddb
    rm -rf /var/log/radius
    rm -rf /tmp/passwdfile.txt

    LOG_INFO "End to restore the test environment."
}

main "$@"
