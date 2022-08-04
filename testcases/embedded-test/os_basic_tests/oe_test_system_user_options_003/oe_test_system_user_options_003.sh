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
# @Date      :   2020-04-28
# @License   :   Mulan PSL v2
# @Desc      :   Modify user home directory
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh
function pre_test() {
    LOG_INFO "Start to prepare the test environment."

    grep "testuser:" /etc/passwd && userdel -rf testuser
    grep "testuser:" /etc/group && groupdel testuser
    test -d /home/new_test && rm -rf /home/new_test
    useradd testuser
    mkdir /home/new_test -p
    touch /home/testuser/testfile.txt

    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."

    grep testuser /etc/passwd | awk -F: '{print $6}' | grep "/home/testuser"
    CHECK_RESULT $? 0 0 "check testuser passed fail"
    usermod -d /home/new_test testuser
    CHECK_RESULT $? 0 0 "run usermod -d fail"
    grep testuser /etc/passwd | awk -F: '{print $6}' | grep "/home/new_test"
    CHECK_RESULT $? 0 0 "check mod grep new_test fail"
    find /home/new_test/testfile.txt
    CHECK_RESULT $? 1 0 "check testfile.txt not find fail"
    usermod -d /home/testuser testuser
    CHECK_RESULT $? 0 0 "run usermod -d testuser fail"
    grep testuser /etc/passwd | awk -F: '{print $6}' | grep "/home/testuser"
    CHECK_RESULT $? 0 0 "check mod grep testuser fail"
    rm -rf /home/new_test
    CHECK_RESULT $? 0 0 "run rm fail"
    usermod -d /home/new_test -m testuser
    CHECK_RESULT $? 0 0 "run usermod -d -m testuser fail"
    grep testuser /etc/passwd | awk -F: '{print $6}' | grep "/home/new_test"
    CHECK_RESULT $? 0 0 "check grep /home/new_test fail"
    test -f /home/new_test/testfile.txt
    CHECK_RESULT $? 0 0 "check testfile.txt fail"

    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."

    userdel -r testuser
    rm -rf /home/new_test/

    LOG_INFO "End to restore the test environment."
}

main "$@"
