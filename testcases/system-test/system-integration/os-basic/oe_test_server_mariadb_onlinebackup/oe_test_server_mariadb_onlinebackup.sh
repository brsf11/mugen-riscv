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
# @Author    :   Classicriver_jia
# @Contact   :   classicriver_jia@foxmail.com
# @Date      :   2020-4-9
# @License   :   Mulan PSL v2
# @Desc      :   Perform a physical online backup using the Maria backup tool
# #############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh
function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL "mariadb-server mariadb-backup"
    rm -rf /var/lib/mysql/*
    systemctl start mariadb.service
    systemctl status mariadb.service | grep running || exit 1
    mysqladmin -uroot password ${NODE1_PASSWORD}
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    echo "[xtrabackup]" >/etc/my.cnf.d/mariabackup.cnf
    echo "user=myuser" >>/etc/my.cnf.d/mariabackup.cnf
    echo "password=mypassword" >>/etc/my.cnf.d/mariabackup.cnf
    mkdir /home/backup
    mariabackup --backup --target-dir /home/backup --user root --password ${NODE1_PASSWORD}
    CHECK_RESULT $?
    ls -l /home/backup/* >/dev/null
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf /etc/my.cnf.d/mariabackup.cnf /home/backup  /var/lib/mysql
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}

main $@
