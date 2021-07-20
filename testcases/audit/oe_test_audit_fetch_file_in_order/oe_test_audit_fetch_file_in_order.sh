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
#@Author    	:   Jevons
#@Contact   	:   1557927445@qq.com
#@Date      	:   2021-04-16 11:39:43
#@License   	:   Mulan PSL v2
#@Version   	:   1.0
#@Desc      	:   fetch files in order
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test(){
    LOG_INFO "Start to run test"
    DNF_INSTALL audit-help
    LOG_INFO "End to prepare the environment"
}
function run_test()
{
    LOG_INFO "Start to run test."
    systemctl start auditd
    CHECK_RESULT $? 0 0 "start failed"
    auditctl -D
    CHECK_RESULT $? 0 0 "delete failed"
    cp -raf /usr/share/doc/audit-help/rules/30-ospp-v42.rules /etc/audit/rules.d
    cp -raf /usr/share/doc/audit-help/rules/10-base-config.rules /etc/audit/rules.d
    SLEEP_WAIT 1
    augenrules --load
    CHECK_RESULT $? 0 0 "load failed"
    auditctl -l | grep -e "-a always,exit"
    CHECK_RESULT $? 0 0 "add failed"
    LOG_INFO "End to run test."
}
function post_test()
{
    LOG_INFO "Start to restore the test environment."
    auditctl -D
    DNF_REMOVE audit-help
    LOG_INFO "End to restore the test environment."
}

main "$@"
