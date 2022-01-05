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
# @Date      :   2020.4.27
# @License   :   Mulan PSL v2
# @Desc      :   mysql restarts repeatedly
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh
source ../common/mysql_pre.sh
function pre_test() {
    LOG_INFO "Start environment preparation."
    dnf list | grep mysql-server
    if [ $? -eq 0 ]; then
        rm -rf /var/lib/mysql/*
        DNF_INSTALL mysql-server
        systemctl start mysqld
        servername=mysqld
    else
        flag=1
        mysql_pre
        servername=mysql
    fi
    LOG_INFO "Environmental preparation is over."
}

function run_test() {
    LOG_INFO "Start executing testcase."
    for mysql_count in $(seq 1 10); do
        systemctl start ${servername}
        CHECK_RESULT $?
        systemctl status ${servername} | grep -wE 'running|active'
        CHECK_RESULT $?

        systemctl restart ${servername}
        CHECK_RESULT $?

        systemctl stop ${servername}
        CHECK_RESULT $?
        systemctl disable ${servername}
        CHECK_RESULT $?
        SLEEP_WAIT 2
    done
    LOG_INFO "End of testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    test -z ${flag} || {
        sql_pid=$(ps -ef | grep -w mysql | grep -v grep | awk '{print$2}')
        kill -9 ${sql_pid}
        rm -rf /data/mysql
        userdel -r mysql
        rm -rf /tmp/mysql.sock
    }
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup."
}

main $@
