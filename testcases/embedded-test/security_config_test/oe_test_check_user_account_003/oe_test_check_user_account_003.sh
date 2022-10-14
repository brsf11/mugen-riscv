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
# @Desc      :   check deny and unlock time fail
# #############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test()
{
    LOG_INFO "Start to prepare the test environment."
    
    useradd tester1
    useradd tester2
    passwd tester2 <<EOF
openEuler@123
openEuler@123
EOF
    
    LOG_INFO "End to prepare the test environment."
}

function run_test()
{
    LOG_INFO "Start to run test."

    cat /etc/pam.d/common-auth | grep "deny" | grep "unlock_time"
    CHECK_RESULT $? 0 0 "check deny and unlock time fail"

    expect -v
    if [ $? -eq 0 ]; then

    expect ./check_passwd_three_times_fail.exp
    CHECK_RESULT $? 0 0 "check login fail 3 time lock fail"

    else

    su tester1 -c "su tester2" <<EOF
openEuler@456
EOF
    su tester1 -c "su tester2" <<EOF
openEuler@456
EOF
    su tester1 -c "su tester2" <<EOF
openEuler@456
EOF

    getValue=$(su tester1 -c "su tester2" <<EOF
openEuler@456
EOF
)

    echo $getValue | grep "The account is locked due to "
    CHECK_RESULT $? 0 0 "check login fail 3 time lock fail"
fi

    LOG_INFO "End to run test."
}

function post_test()
{
    LOG_INFO "Start to restore the test environment."
    
    userdel -rf tester1
    userdel -rf tester2
    
    LOG_INFO "End to restore the test environment."
}

main "$@"
