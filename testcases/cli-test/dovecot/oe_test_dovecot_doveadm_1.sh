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
#@Author    	:   meitingli
#@Contact   	:   244349477@qq.com
#@Date      	:   2021-09-15
#@License   	:   Mulan PSL v2
#@Desc      	:   Take the test dovecot execution
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the database config."

    DNF_INSTALL dovecot
    cp /etc/dovecot/conf.d/10-ssl.conf /etc/dovecot/conf.d/10-ssl.conf.bak
    sed -i '/ssl_key = <\/etc\/pki\/dovecot\/private\/dovecot.pem/d' /etc/dovecot/conf.d/10-ssl.conf
    systemctl restart dovecot

    LOG_INFO "End to prepare the database config."
}

function run_test() {
    LOG_INFO "Start to run test."

    doveadm -D who
    CHECK_RESULT $? 0 0 "Check doveadm who detail failed."
    doveadm -v who
    CHECK_RESULT $? 0 0 "Check doveadm who verbose failed."
    doveadm who -1
    CHECK_RESULT $? 0 0 "Check doveadm who -1 failed."
    doveadm who ${NODE1_IPV4}
    CHECK_RESULT $? 0 0 "Check doveadm who ${NODE1_IPV4} failed."
    doveadm who 0022
    CHECK_RESULT $? 0 0 "Check doveadm who 0022 failed."

    doveadm pw -l
    printf 'password\npassword\n' | doveadm pw
    CHECK_RESULT $? 0 0 "Check doveadm pw failed."
    doveadm pw -p password
    CHECK_RESULT $? 0 0 "Check doveadm pw -p failed."
    printf 'password\npassword\n' | doveadm pw -r 1002 &
    ps -ef | grep "doveadm pw -r 1002" | grep -v "grep"
    CHECK_RESULT $? 0 0 "Check doveadm pw -r failed."
    printf 'password\npassword\n' | doveadm pw -u testuser
    CHECK_RESULT $? 0 0 "Check doveadm pw -u failed."
    printf 'password\npassword\n' | doveadm pw -V
    CHECK_RESULT $? 0 0 "Check doveadm pw -V failed."
    printf 'password\npassword\n' | doveadm pw -s SHA512-CRYPT
    CHECK_RESULT $? 0 0 "Check doveadm pw -s failed."

    doveadm log errors
    CHECK_RESULT $? 0 0 "Check doveadm log errors failed."
    doveadm log find
    CHECK_RESULT $? 0 0 "Check doveadm log find failed."
    doveadm log reopen
    CHECK_RESULT $? 0 0 "Check doveadm log reopen failed."
    doveadm log test
    CHECK_RESULT $? 0 0 "Check doveadm log test failed."

    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."

    systemctl stop dovecot
    rm -f a.sh* /etc/dovecot/conf.d/10-ssl.conf
    mv /etc/dovecot/conf.d/10-ssl.conf.bak /etc/dovecot/conf.d/10-ssl.conf
    kill -9 $(ps -ef | grep "doveadm" | grep -Ev "grep|.sh" | awk '{print $2}')
    DNF_REMOVE

    LOG_INFO "End to restore the test environment."
}

main "$@"

