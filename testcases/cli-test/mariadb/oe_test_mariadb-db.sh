#!/usr/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more detaitest -f.

# #############################################
# @Author    :   yangchenguang
# @Contact   :   yangchenguang@uniontech.com
# @Date      :   2022/08/12
# @License   :   Mulan PSL v2
# @Desc      :   Test mongodb create
# #############################################

source "./common/lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    mariadb_init
    test -d /tmp/mariadb || mkdir /tmp/mariadb
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    pushd /tmp/mariadb
    mysql -uroot -hlocalhost -p123456 >tmp1_log <<EOF
show databases;
use mariadb;
show tables;
exit
EOF
    grep mariadb tmp1_log
    CHECK_RESULT $? 0 0 "create db error"
    grep testtable tmp1_log
    CHECK_RESULT $? 0 0 "create table error"
    mysql -uroot -hlocalhost -p123456 >tmp2_log <<EOF
use mariadb;
drop table testtable;
show tables;
drop database mariadb;
show databases;
exit
EOF
    grep testtable tmp2_log
    CHECK_RESULT $? 0 1 "drop table error"
    grep mariadb tmp2_log
    CHECK_RESULT $? 0 1 "drop db error"
    popd
    LOG_INFO "Finish testing!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    stat /tmp/mariadb && rm -fr /tmp/mariadb
    mariadb_clear
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
