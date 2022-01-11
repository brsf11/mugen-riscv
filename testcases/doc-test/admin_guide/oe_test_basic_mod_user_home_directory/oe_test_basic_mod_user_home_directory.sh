#!/usr/bin/bash

# Copyright (c) 2021. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   xuchunlin
# @Contact   :   xcl_job@163.com
# @Date      :   2020-04-28
# @License   :   Mulan PSL v2
# @Desc      :   Modify user home directory
# ############################################
source ${OET_PATH}/libs/locallibs/common_lib.sh
function pre_test() {
    LOG_INFO "Start environment preparation."
    grep -w testuser /etc/passwd && userdel -r testuser
    grep -w testuser /etc/group && groupdel -r testuser
    LOG_INFO "Environmental preparation is over."
}

function run_test() {
    LOG_INFO "Start executing testcase!"
    useradd testuser
    test -d /home/new_test || mkdir /home/new_test -p
    CHECK_RESULT $?
    touch /home/new_test/testfile.txt
    CHECK_RESULT $?
    grep testuser /etc/passwd | awk -F: '{print $6}' | grep "/home/testuser"
    CHECK_RESULT $?
    usermod -d /home/new_test testuser
    CHECK_RESULT $?
    grep testuser /etc/passwd | awk -F: '{print $6}' | grep "/home/new_test"
    CHECK_RESULT $?
    usermod -d /home/new_test -m testuser
    CHECK_RESULT $?
    test -f /home/new_test/testfile.txt
    CHECK_RESULT $?
    LOG_INFO "End of testcase execution!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    userdel -r testuser
    rm -rf /home/new_test/ /home/testuser/
    LOG_INFO "Finish environment cleanup."
}

main $@
