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
#@Desc      	:   rule conflict strategy
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test(){
    LOG_INFO "Start to prepare the test environment."
    useradd Jevons
    uid=$(id -u Jevons)
    LOG_INFO "End to prepare the environment"
}

function run_test()
{
    LOG_INFO "Start to run test."
    service auditd restart
    auditctl -D
    CHECK_RESULT $? 0 0 "delete failed"
    auditctl -a always,exit -S all -F uid="${uid}" -k syscall
    CHECK_RESULT $? 0 0 "add failed"
    auditctl -l | grep -e "-a always,exit -S all -F uid=${uid}"
    CHECK_RESULT $? 0 0 "grep failed"
    auditctl -A never,task
    CHECK_RESULT $? 0 0 "add second failed"
    auditctl -l | grep -e "-a never,task"
    CHECK_RESULT $? 0 0 "grep second failed"
    starttime=$(date +%T)
    su - Jevons -c "pwd"
    CHECK_RESULT $? 0 0 "failed"
    endtime=$(date +%T)
    ausearch -k syscall -ts ${starttime} -te ${endtime} -x pwd
    CHECK_RESULT $? 1 0 "ausearch failed"
    LOG_INFO "End to run test."
}

function post_test()
{
    LOG_INFO "Start to restore the test environment."
    userdel -rf Jevons
    auditctl -D
    LOG_INFO "End to restore the test environment."
}

main "$@"
