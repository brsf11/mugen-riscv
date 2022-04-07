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

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    sed -i 's/password    requisite     pam_pwquality.so try_first_pass local_users_only/password    requisite     pam_pwquality.so minlen=8 minclass=3 enforce_for_root try_first_pass local_users_only retry=3 dcredit=0 ucredit=0 lcredit=0 ocredit=0\npassword    required      pam_pwhistory.so use_authtok remember=5 enforce_for_root/g' /etc/pam.d/system-auth
    # sed -i 's/password    required      pam_deny.so/password    required      pam_deny.so minlen=8 enforce_for_root try_first_pass local_users_only retry=3/g' /etc/pam.d/system-auth
    useradd test
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    expect <<EOF1
    log_file testlog
    spawn passwd test
    expect "*assword:" { send "123\\r" }
    expect "*assword:" { send "Administrator12#$\\r" }
    expect "*assword:" { send "Administrator12#$\\r" }
    expect eof
EOF1
    grep -e "passwd: all authentication tokens updated successfully" testlog
    CHECK_RESULT $? 0 0 "grep failed"
    grep -e "BAD PASSWORD" testlog
    CHECK_RESULT $? 0 0 "grep bad failed"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    # sed 's/password    required      pam_deny.so minlen=8 enforce_for_root try_first_pass local_users_only retry=3/password    required      pam_deny.so/g' /etc/pam.d/system-auth
    sed -i 's/password    requisite     pam_pwquality.so minlen=8 minclass=3 enforce_for_root try_first_pass local_users_only retry=3 dcredit=0 ucredit=0 lcredit=0 ocredit=0/password    requisite     pam_pwquality.so try_first_pass local_users_only/g' /etc/pam.d/system-auth
    sed -i '/password    required      pam_pwhistory.so use_authtok remember=5 enforce_for_root/d' /etc/pam.d/system-auth
    rm -rf testlog
    userdel -rf test
    LOG_INFO "End to restore the test environment."
}

main "$@"
