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
# @Author    :   doraemon2020
# @Contact   :   xcl_job@163.com
# @Date      :   2020-04-09
# @License   :   Mulan PSL v2
# @Desc      :   account_expiration time
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    grep -w testuser /etc/passwd || useradd testuser
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    grep "testuser" /etc/passwd
    CHECK_RESULT $?
    sudo chage -l testuser | grep "Account expires" | grep "never"
    CHECK_RESULT $?
    sudo chage -E 2023-03-01 testuser
    CHECK_RESULT $?
    sudo chage -l testuser | grep "Account expires" | grep "Mar 01, 2023"
    CHECK_RESULT $?
    chage -M 4 testuser
    CHECK_RESULT $?
    usermod -e 04/01/2023 testuser
    CHECK_RESULT $?
    expire_date=$(date -d"+4 day" "+%b %d, %Y") 
    sudo chage -l testuser | grep "Password expires" | grep "$expire_date"   
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to clean the test environment."
    userdel -rf testuser
    LOG_INFO "Start to clean the test environment."
}


main "$@"
