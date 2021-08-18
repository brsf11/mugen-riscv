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
#@Desc      	:   least length of passwd
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test()
{
    LOG_INFO "Start to prepare the test environment."
    sed 's/password    required      pam_deny.so/password    required      pam_deny.so minlen=8 enforce_for_root try_first_pass local_users_only retry=3/g' /etc/pam.d/system-auth
    useradd test
    LOG_INFO "End to prepare the test environment."
}

function run_test()
{
    LOG_INFO "Start to run test."
    echo 123 | passwd test 
    CHECK_RESULT $? 1 0 "set passwd failed"
    expect <<EOF1
	log_file testlog
	spawn passwd test
	expect "*assword:" { send "Administrator12#$\\r" }
        expect "*assword:" { send "Administrator12#$\\r" }
        expect eof
EOF1
    grep -e "passwd: all authentication tokens updated successfully" testlog
    CHECK_RESULT $? 0 0 "grep failed" 
    LOG_INFO "End to run test."
}

function post_test()
{
    LOG_INFO "Start to restore the test environment."
    sed 's/password    required      pam_deny.so minlen=8 enforce_for_root try_first_pass local_users_only retry=3/password    required      pam_deny.so/g' /etc/pam.d/system-auth
    userdel -rf test
    LOG_INFO "End to restore the test environment."
}

main "$@"
