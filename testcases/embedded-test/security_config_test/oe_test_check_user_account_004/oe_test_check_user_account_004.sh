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
# @Desc      :   check check PAM set fail
# #############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test()
{
    LOG_INFO "Start to prepare the test environment."
    
    useradd tester1
    
    LOG_INFO "End to prepare the test environment."
}

function run_test()
{
    LOG_INFO "Start to run test."

    grep -E "^[[:space:]]*password[[:space:]]+(required|requisite)[[:space:]]+pam_pwquality.so[[:space:]]+" /etc/pam.d/common-password 2>/dev/null | grep "retry=3" | grep "minlen=8"| grep "minclass=3"
    CHECK_RESULT $? 0 0 "check PAM set fail"

    passwd tester1 <<EOF
openeuler123
openeuler123
openeuler123
EOF
    CHECK_RESULT $? 0 1 "change password success, need fail"

    passwd tester1 <<EOF
openeuler@
openeuler@
openeuler@
EOF
    CHECK_RESULT $? 0 1 "change password success, need fail"

    passwd tester1 <<EOF
@#$%^&*123
@#$%^&*123
@#$%^&*123
EOF
    CHECK_RESULT $? 0 1 "change password success, need fail"

    passwd tester1 <<EOF
opEn123
opEn123
opEn123
EOF
    CHECK_RESULT $? 0 1 "change password success, need fail"

        passwd tester1 <<EOF
openeuler@123
openeuler@123
EOF
    CHECK_RESULT $? 0 0 "change password fail, need success"

    LOG_INFO "End to run test."
}

function post_test()
{
    LOG_INFO "Start to restore the test environment."
    
    userdel -rf tester1
    
    LOG_INFO "End to restore the test environment."
}

main "$@"
