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
# @Desc      :   check mount options of /tmp /var and 
#                check /dev/shm and stickbit and 
#                check LD_LIBRARY_PATH and PATH value
# #############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test()
{
    LOG_INFO "Start to prepare the test environment."
    
    useradd tester1
    
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start executing testcase."

    # check mount options of /tmp /var and /dev/shm
    mount | grep /var | grep "(rw,nosuid,nodev,relatime,mode=755)"
    CHECK_RESULT $? 0 0 "check /var mount options fail"

    mount | grep /tmp | grep "(rw,nosuid,nodev,noexec,relatime)"
    CHECK_RESULT $? 0 0 "check /tmp mount options fail"

    mount | grep /dev/shm | grep "(rw,nosuid,nodev,noexec,relatime)"
    CHECK_RESULT $? 0 0 "check /dev/shm mount options fail"

    # check stickbit
    find / -xdev -type d \( -perm -0002 -a ! -perm -1000 \) 2>/dev/null  | sort | grep '[^\n]'
    CHECK_RESULT $? 0 1 "check stickybit fail"

    # check LD_LIBRARY_PATH and PATH value
    grep "LD_LIBRARY_PATH" /etc/profile
    CHECK_RESULT $? 0 1 "check LD_LIBRARY_PATH set in /etc/profile fail"

    echo $LD_LIBRARY_PATH | grep '[^\n]'
    CHECK_RESULT $? 0 1 "check root LD_LIBRARY_PATH value fail"

    su - tester1 -c "echo $LD_LIBRARY_PATH | grep '[^\n]'"
    CHECK_RESULT $? 0 1 "check tester1 LD_LIBRARY_PATH value fail"

    echo $PATH | grep -E "\.|\.\.|/tmp"
    CHECK_RESULT $? 0 1 "check PATH value fail"

    LOG_INFO "Finish testcase execution."
}

function post_test()
{
    LOG_INFO "Start to restore the test environment."
    
    userdel -rf tester1
    
    LOG_INFO "End to restore the test environment."
}

main "$@"