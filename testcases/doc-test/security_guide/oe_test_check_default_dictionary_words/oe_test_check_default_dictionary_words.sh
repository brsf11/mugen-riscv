#!/usr/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.
####################################
#@Author    	:   wangxiaorou
#@Contact   	:   wangxiaorou@uniontech.com
#@Date      	:   2022-09-07
#@License   	:   Mulan PSL v2
#@Desc      	:   check default dictionary words for weak password
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    id normal && userdel -rf normal
    useradd normal
    sed -i 's/pam_pwquality.so/pam_pwquality.so enforce_for_root/g' /etc/pam.d/system-auth
    sed -i 's/pam_pwquality.so/pam_pwquality.so enforce_for_root/g' /etc/pam.d/password-auth
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    cracklib-unpacker /usr/share/cracklib/pw_dict |grep '!!65logan'
    CHECK_RESULT $? 0 0 "Query default dictionary words failed"
    CHECK_RESULT "$(echo '!!65logan' | cracklib-check |awk '{print $NF}')" "它基于一个字典中的词" 0 "Default dictionary words check failed"
    echo '!!65logan' | passwd normal --stdin
    CHECK_RESULT $? 0 1 "Change weak password failed"

    cracklib-unpacker /usr/share/cracklib/pw_dict |grep 'mugen12#\$'
    CHECK_RESULT $? 0 1 "Query default dictionary words failed"
    CHECK_RESULT "$(echo 'mugen12#$' | cracklib-check |awk '{print $NF}')" "OK" 0 "Default dictionary words check failed"
    echo 'mugen12#$' | passwd normal --stdin
    CHECK_RESULT $? 0 0 "Change strong password failed"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    sed -i 's/pam_pwquality.so enforce_for_root/pam_pwquality.so/g' /etc/pam.d/system-auth
    sed -i 's/pam_pwquality.so enforce_for_root/pam_pwquality.so/g' /etc/pam.d/password-auth
    userdel -rf normal
    LOG_INFO "End to restore the test environment."
}

main "$@"

