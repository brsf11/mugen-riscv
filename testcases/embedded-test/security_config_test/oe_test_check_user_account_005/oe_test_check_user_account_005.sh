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
# @Desc      :   check history password set
# #############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test()
{
    LOG_INFO "Start to prepare the test environment."
    
    useradd tester3
    passwd tester3 <<EOF
openEuler@123
openEuler@123
EOF
    
    LOG_INFO "End to prepare the test environment."
}

function run_test()
{
    LOG_INFO "Start to run test."

    cat /etc/pam.d/common-password | egrep "^\s*password\s+required\s+pam_pwhistory.so" | grep "enforce_for_root" | grep "use_authtok" | grep "remember=5"
    CHECK_RESULT $? 0 0 "check history password set fail"

    passwd tester3 <<EOF
openEuler@234
openEuler@234
EOF

    passwd tester3 <<EOF
openEuler@123
openEuler@123
EOF
    CHECK_RESULT $? 0 1 "change password success, need fail"

    passwd tester3 <<EOF
openEuler@345
openEuler@345
EOF

    passwd tester3 <<EOF
openEuler@123
openEuler@123
EOF
    CHECK_RESULT $? 0 1 "change password success, need fail"

    passwd tester3 <<EOF
openEuler@456
openEuler@456
EOF

    passwd tester3 <<EOF
openEuler@123
openEuler@123
EOF
    CHECK_RESULT $? 0 1 "change password success, need fail"

    passwd tester3 <<EOF
openEuler@567
openEuler@567
EOF

    passwd tester3 <<EOF
openEuler@123
openEuler@123
EOF
    CHECK_RESULT $? 0 1 "change password success, need fail"

    LOG_INFO "End to run test."

    passwd tester3 <<EOF
openEuler@678
openEuler@678
EOF

    passwd tester3 <<EOF
openEuler@123
openEuler@123
EOF
    CHECK_RESULT $? 0 0 "change password fail, need success"

    LOG_INFO "End to run test."
}

function post_test()
{
    LOG_INFO "Start to restore the test environment."
    
    userdel -rf tester3
    
    LOG_INFO "End to restore the test environment."
}

main "$@"
