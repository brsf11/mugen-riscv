#!/usr/bin/bash

# Copyright (c) 2023. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.
####################################
#@Author    	:   dingjiao
#@Contact   	:   15829797643@163.com
#@Date      	:   2022-07-06
#@License   	:   Mulan PSL v2
#@Desc      	:   Security test
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL aide
    sed -i '$a/home DATAONLY' /etc/aide.conf
    aide --init
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    ls -l /etc/aide.conf | awk '{print $3}' | grep "root"
    CHECK_RESULT $? 0 0 "Check aide.conf file owner failed!"
    ls -l /etc/aide.conf | awk '{print $4}' | grep "root"
    CHECK_RESULT $? 0 0 "Check aide.conf file group failed!"
    ls -l /etc/aide.conf | awk '{print $1}' | cut -b 2-10 | grep 'rw-------'
    CHECK_RESULT $? 0 0 "Check aide.conf file permission failed!"
    ls -l /var/log/aide/aide.log | awk '{print $3}' | grep "root"
    CHECK_RESULT $? 0 0 "Check aide.log file owner failed!"
    ls -l /var/log/aide/aide.log | awk '{print $4}' | grep "root"
    CHECK_RESULT $? 0 0 "Check aide.log file group failed!"
    ls -l /var/log/aide/aide.log | awk '{print $1}' | cut -b 2-10 | grep 'rw-------'
    CHECK_RESULT $? 0 0 "Check aide.log file permission failed!"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    rm -rf /var/log/aide/
    LOG_INFO "End to restore the test environment."
}

main "$@"
