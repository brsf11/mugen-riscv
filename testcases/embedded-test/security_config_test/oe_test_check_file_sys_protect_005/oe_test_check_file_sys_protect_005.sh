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
# @Desc      :   check umask default value
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

    source /etc/profile

    umaskValue=$(umask)
    test "$umaskValue" == "0077"
    CHECK_RESULT $? 0 0  "check umask default value fail"

    grep -iE "^\s*umask\s+" /etc/login.defs | grep "UMASK[[:space:]]\+077"
    CHECK_RESULT $? 0 0 "check /etc/login.defs set umask value fail"

    grep -iE "^\s*umask\s+" /etc/profile | grep "[umaskUMASK][[:space:]]\+077" 
    CHECK_RESULT $? 0 0 "check /etc/profile set umask value fail"

    bashrcFile="/etc/bashrc"
    if [ ! -e ${bashrcFile} ]; then 
        bashrcFile="/etc/skel/.bashrc"
    fi

    grep -iE "^\s*umask\s+" ${bashrcFile} | grep "[umaskUMASK][[:space:]]\+077"
    CHECK_RESULT $? 0 0 "check /etc/bashrc set umask value fail"

    touch test
    CHECK_RESULT $? 0 0 "touch failed"
    ls -l | grep -e "-rw-------"
    CHECK_RESULT $? 0 0 "check root new file right faild"
    rm -rf test

    mkdir testdir
    CHECK_RESULT $? 0 0 "mkdir failed"
    ls -ld testdir/ | grep -e "drwx------"
    CHECK_RESULT $? 0 0 "check root new dir right faild"
    rm -rf testdir

    su - tester1 -c "touch test"
    CHECK_RESULT $? 0 0 "touch failed"
    su - tester1 -c "ls -l" | grep -e "-rw-------"
    CHECK_RESULT $? 0 0 "check tester1 new file right faild"
    su - tester1 -c "rm -rf test"

    su - tester1 -c "mkdir testdir"
    CHECK_RESULT $? 0 0 "mkdir failed"
    su - tester1 -c "ls -ld testdir/" | grep -e "drwx------"
    CHECK_RESULT $? 0 0 "check tester1 new dir right faild"
    su - tester1 -c "rm -rf testdir"
    
    LOG_INFO "End to run test."
}

function post_test()
{
    LOG_INFO "Start to restore the test environment."
    
    userdel -rf tester1
    
    LOG_INFO "End to restore the test environment."
}

main "$@"
