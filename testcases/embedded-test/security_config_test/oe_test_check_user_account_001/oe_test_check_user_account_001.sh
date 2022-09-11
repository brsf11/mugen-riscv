#!/usr/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   saarloos
# @Contact   :   9090-90-90-9090@163.com
# @Modify    :   9090-90-90-9090@163.com
# @Date      :   2022/04/25
# @License   :   Mulan PSL v2
# @Desc      :   check system account 
#                check su permission
#                check password sha512 set
# #############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function run_test()
{
    LOG_INFO "Start to run test."
    
    # check system account
    getValue=$(cat /etc/passwd | awk -F: '($1!="root" && $3<500 && $7!="/sbin/nologin" && $7!="/bin/false" && $7!="/bin/sync") {print}')
    echo $getValue | grep '[^\n]'
    CHECK_RESULT $? 0 1 "Check system account fail"

    # check su permission
    grep pam_wheel.so /etc/pam.d/su | grep required
    CHECK_RESULT $? 0 0 "not set wheel permission in /etc/pam.d/su"

    # check password sha512 set
    grep sha512 /etc/pam.d/common-password
    CHECK_RESULT $? 0 0 "not set sha512 in /etc/pam.d/common-password"

    

    LOG_INFO "End to run test."
}

main "$@"