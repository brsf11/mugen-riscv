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
#@Desc      	:   ACL
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test()
{
    LOG_INFO "Start to prepare the test environment."
    
    useradd acl_user
    echo "123" > acl_file && chmod o-r acl_file
    
    LOG_INFO "End to prepare the test environment."
}

function run_test()
{
    LOG_INFO "Start to run test."
    
    getfacl -a acl_file 
    CHECK_RESULT $? 0 0 "show failed"
    a=$(getfacl -a acl_file | grep -e "::" | awk -F ':' '{print $3}' |sed ':a;N;s/\n//;t a;')
    ls -l  acl_file | grep $a
    CHECK_RESULT $? 0 0 "grep failed"
    setfacl -m u:acl_user:r acl_file
    CHECK_RESULT $? 0 0 "set failed"
    getfacl -a acl_file | grep -e "user:acl_user:r--"
    CHECK_RESULT $? 0 0 "grep new user failed"
    mv acl_file /home/acl_user
    CHECK_RESULT $? 0 0 "mv failed"
    su - acl_user -c "cat acl_file |grep -e "123""
    CHECK_RESULT $? 0 0 "cat file failed"
    setfacl -b /home/acl_user/acl_file
    CHECK_RESULT $? 0 0 "setb failed"
    getfacl /home/acl_user/acl_file | grep -e "user:acl_user:r--"
    CHECK_RESULT $? 1 0 "grep group failed"
    su - acl_user -c "cat acl_file" | grep -e "123"
    CHECK_RESULT $? 1 0 "visit failed"
    setfacl -m g:acl_user:rx /home/acl_user/acl_file
    CHECK_RESULT $? 0 0 "set home failed"
    getfacl /home/acl_user/acl_file | grep -e "group:acl_user:r-x"
    CHECK_RESULT $? 0 0 "grep failed"
    su - acl_user -c "cat acl_file" | grep -e "123"
    CHECK_RESULT $? 0 0 "cat failed"
    
    LOG_INFO "End to run test."
}

function post_test()
{
    LOG_INFO "Start to restore the test environment."
    
    userdel -rf acl_user
    rm -rf acl_file 
    
    LOG_INFO "End to restore the test environment."
}

main "$@"
