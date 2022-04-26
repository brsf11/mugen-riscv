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
    version=$(rpm -qa | grep mysql-server | cut -d "-" -f 3)
    innochecksum --version | grep "${version}"
    CHECK_RESULT $?
    innochecksum --help | grep -i "usage"
    CHECK_RESULT $?
    innochecksum -I | grep -i "usage"
    CHECK_RESULT $?
    innochecksum --info | grep -i "usage"
    CHECK_RESULT $?
    innochecksum --verbose | grep verbose | grep TRUE
    CHECK_RESULT $?
    innochecksum --verbose=FALSE | grep verbose | grep FALSE
    CHECK_RESULT $?
    innochecksum --verbose --log=/var/lib/mysql/test/logtest.txt | grep log | grep "/var/lib/mysql/test/logtest.txt"
    CHECK_RESULT $?
    mysql -e "DROP DATABASE test45"
    mysql -e "CREATE DATABASE test45;use test45;CREATE TABLE mytable (id INT)"
    CHECK_RESULT $?
    mysql -e "use test45;INSERT INTO mytable VALUES(1)"
    CHECK_RESULT $?
    test -f /var/lib/mysql/test45/mytable.ibd
    CHECK_RESULT $?
    cp -f /var/lib/mysql/test45/mytable.ibd /var/lib/mysql/test45/mytable2.ibd
    innochecksum --count /var/lib/mysql/test45/mytable2.ibd | grep "Number of pages"
    CHECK_RESULT $?
    innochecksum --start-page=600 /var/lib/mysql/test45/mytable2.ibd
    CHECK_RESULT $?
    innochecksum -s 600 /var/lib/mysql/test45/mytable2.ibd
    CHECK_RESULT $?
    innochecksum --end-page=700 /var/lib/mysql/test45/mytable2.ibd
    CHECK_RESULT $?
    innochecksum -p 700 | grep "start-page" | grep 700
    CHECK_RESULT $?
    innochecksum --page=701 | grep "page" | grep 701
    CHECK_RESULT $?
    innochecksum --strict-check=innodb | grep "strict-check" | grep "innodb"
    CHECK_RESULT $?
    innochecksum -C crc32 /var/lib/mysql/test45/mytable2.ibd
    CHECK_RESULT $?
    innochecksum --no-check --write innodb | grep "write" | grep "innodb"
    CHECK_RESULT $?
    innochecksum --page-type-summary=FALSE | grep "page-type-summary" | grep "FALSE"
    CHECK_RESULT $?
    mysqlpump --compress-output=ZLIB >dump.zlib
    CHECK_RESULT $?
    zlib_decompress dump.zlib dump.txt
    CHECK_RESULT $?
    test -f dump.txt
    CHECK_RESULT $?
    LOG_INFO "End of testcase execution!"
}

function post_test() {
    LOG_INFO "Start environment cleanup."
    systemctl stop mysqld
    rm -rf dump.* /var/lib/mysql/test45/mytable2.ibd
    mysql -e "DROP DATEBASE test45"
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup."
}

main $@
