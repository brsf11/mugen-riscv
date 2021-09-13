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
#@Date      	:   2021-08-09
#@License   	:   Mulan PSL v2
#@Desc      	:   Start ipsec servier by systemctl
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the database config."

    DNF_INSTALL libreswan

    LOG_INFO "End to prepare the database config."
}

function run_test() {
    LOG_INFO "Start to run test."

    SLEEP_WAIT 2 "systemctl start ipsec.service"
    CHECK_RESULT $? 0 0 "Start ipsec.service failed."
    systemctl status ipsec.service | grep "active"
    CHECK_RESULT $? 0 0 "Check ipsec.service start status failed."
    SLEEP_WAIT 2 "systemctl stop ipsec.service"
    CHECK_RESULT $? 0 0 "Stop ipsec.service failed."
    systemctl status ipsec.service | grep "inactive"
    CHECK_RESULT $? 0 0 "Check ipsec.service stop status failed."
    SLEEP_WAIT 2 "systemctl restart ipsec.service"
    CHECK_RESULT $? 0 0 "Restart ipsec.service failed."
    systemctl status ipsec.service | grep "active"
    CHECK_RESULT $? 0 0 "Check ipsec.service restart status failed."

    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."

    DNF_REMOVE

    LOG_INFO "End to restore the test environment."
}

main "$@"

