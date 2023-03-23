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
#@Desc      	:   Detect whether there is a problem with the configuration file
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL aide
    sed -i '$a/home DATAONLY' /etc/aide.conf
    aide --init
    mv /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    sed -i '$a/errorconf' /etc/aide.conf
    CHECK_RESULT $? 0 0 "Modify aide configuration items: failed!"
    aide --config-check 2>&1 | grep -i "Error"
    CHECK_RESULT $? 0 0 "Check aide configuration contain error: failed!"
    sed -i '$d' /etc/aide.conf
    CHECK_RESULT $? 0 0 "Delete aide configuration items: failed!"
    aide --config-check 2>&1 | grep -i "Error"
    CHECK_RESULT $? 1 0 "Check aide configuration not contain error: failed!"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    rm -rf /var/lib/aide
    LOG_INFO "End to restore the test environment."
}

main "$@"
