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
# @Author    :   yangchenguang
# @Contact   :   yangchenguang@uniontech.com
# @Date      :   2022/08/12
# @License   :   Mulan PSL v2
# @Desc      :   mariadb common function
# #############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function mariadb_init() {
    DNF_INSTALL "mariadb mariadb-server"
    systemctl start mariadb
    mysqladmin -u root password '123456'
    mysql -uroot -hlocalhost -p123456 <<EOF
create database mariadb;
use mariadb;
create table testtable(id int(3), name char(8));
insert into testtable values('01','zhang');
quit
EOF
}

function mariadb_clear() {
    systemctl stop mariadb
    rm -f /var/lib/mysql/*
    DNF_REMOVE
}
