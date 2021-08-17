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
#@Date      	:   2021-05-19 09:39:43
#@License   	:   Mulan PSL v2
#@Desc      	:   only root can read and write
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test()
{
    LOG_INFO "Start to prepare the test environment."
    
    a=$(umask)
    umask 0022
    useradd tester1
    useradd tester2
    cp /etc/sudoers /etc/sudoers1
    
    LOG_INFO "End to prepare the test environment."
}

function run_test()
{
    LOG_INFO "Start to run test."
    
    su - tester1 -c "touch test1.txt"
    CHECK_RESULT $? 0 0 "touch failed"
    su - tester1 -c "ls -l" | grep -e "-rw-r--r--"
    CHECK_RESULT $? 0 0 "grep faild"
    su - tester2 -c "echo \"I LOVE YOU\" >> /home/tester1/test.txt"
    CHECK_RESULT $? 1 0 "success"
    echo "I LOVE YOU" >> /home/tester1/test.txt
    CHECK_RESULT $? 0 0 "write failed"
    grep -e "I LOVE YOU" /home/tester1/test.txt
    CHECK_RESULT $? 0 0 "grep failed"
    su - tester2 -c "echo \"blinux ALL=(ALL) NOPASSWD:ALL\" >> /etc/sudoers"
    CHECK_RESULT $? 1 0 "success"
    echo "blinux ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers 
    CHECK_RESULT $? 0 0 "echo failed"
    
    LOG_INFO "End to run test."
}

function post_test()
{
    LOG_INFO "Start to restore the test environment."
    
    userdel -rf tester1
    userdel -rf tester2
    rm -rf /etc/sudoers
    cp /etc/sudoers1 /etc/sudoers
    rm -rf /etc/sudoers1
    umask $a
    
    LOG_INFO "End to restore the test environment."
}

main "$@"
