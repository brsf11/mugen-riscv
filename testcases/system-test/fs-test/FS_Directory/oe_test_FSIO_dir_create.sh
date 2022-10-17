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
#@Author    	:   @meitingli
#@Contact   	:   bubble_mt@outlook.com
#@Date      	:   2020-11-19
#@License   	:   Mulan PSL v2
#@Desc      	:   Take the test mkdir
#####################################

source ../common_lib/fsio_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the database config."
    cur_date=$(date +%Y%m%d%H%M%S)
    testuserA="testuserA"$cur_date
    useradd $testuserA
    echo $testuserA | passwd --stdin $testuserA
    testuserB="testuserB"$cur_date
    useradd $testuserB
    echo $testuserB | passwd --stdin $testuserB
    usermod $testuserB -g $testuserA
    testuserC="testuserC"$cur_date
    useradd $testuserC
    echo $testuserC | passwd --stdin $testuserC
    chmod 770 /home/$testuserA
    LOG_INFO "Finish to prepare the database config."
}

function run_test() {
    LOG_INFO "Start to run test."
    su $testuserA -c "mkdir /home/$testuserA/test1 /home/$testuserA/test2"
    CHECK_RESULT $? 0 0 "User A mkdir failed."
    su $testuserB -c "ls /home/$testuserA >/dev/null"
    CHECK_RESULT $? 0 0 "User B ls dir failed."
    su $testuserB -c "mkdir -p /home/$testuserA/test3/test4"
    CHECK_RESULT $? 0 0 "User B mkdir failed."
    su $testuserC -c "ls /home/$testuserA &>1 | grep 'Permission denied' >/dev/null"
    CHECK_RESULT $? 1 0 "User C ls dir succeed."
    su $testuserC -c "mkdir /home/$testuserA/test5 &>1 | grep 'Permission denied' >/dev/null"
    CHECK_RESULT $? 1 0 "User C mkdir succeed."
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    userdel -r $testuserA
    userdel -r $testuserB
    userdel -r $testuserC
    groupdel $testuserA
    groupdel $testuserB
    LOG_INFO "End to restore the test environment."
}

main "$@"

