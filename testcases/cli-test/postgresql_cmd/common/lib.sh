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
# @Author    :   wangshan
# @Contact   :   wangshan@163.com
# @Date      :   2020/10/10
# @License   :   Mulan PSL v2
# @Desc      :   Public class, environment construction
# #############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function postgresql_install() {
    DNF_INSTALL "postgresql postgresql-server postgresql-devel postgresql-contrib"
    /usr/bin/postgresql-setup --initdb
    sed -i 's/ident/trust/g' /var/lib/pgsql/data/pg_hba.conf
    systemctl start postgresql
    expect <<-END
    spawn su - postgres
    expect "postgres"
    send "createdb testdb\n"
    expect "postgres"
    send "psql testdb\n"
    expect "postgres"
    send "create table test (id int, val numeric);\n"
    expect "CREATE TABLE"
    send "create index on test(id);\n"
    expect "CREATE INDEX"
    send "create index on test(val);\n"
    expect "CREATE INDEX"
    send "insert into test select generate_series(1,10000),random();\n"
    expect "INSERT 0 10000"
    send "create table tab_big(vname text,souroid oid);\n"
    expect "CREATE TABLE"
    send "insert into tab_big values('passwd list',lo_import('/etc/passwd'));\n"
    expect "INSERT 0 1"
    send "CREATE SCHEMA myschema;\n"
    expect "CREATE SCHEMA"
    send "create table myschema.test (id int, val numeric) with oids;\n"
    expect "CREATE TABLE"
    send "insert into myschema.test select generate_series(1,100),random();\n"
    expect "INSERT 0 100"
    send "create user testuder;\n"
    expect "CREATE ROLE"
    send "GRANT ALL ON test TO testuder;\n"
    expect "GRANT"
    send "\\\q\n"
    expect eof
END
    export LANG="en_US.UTF-8"
}
