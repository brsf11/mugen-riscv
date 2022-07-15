#!/usr/bin/bash

# Copyright (c) 2021 Huawei Technologies Co.,Ltd.ALL rights reserved.
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
# @Date      :   2020-04-09
# @License   :   Mulan PSL v2
# @Desc      :   Add User test
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."

    grep "testuser:" /etc/passwd && userdel -rf testuser
    grep "testuser1:" /etc/passwd && userdel -rf testuser1
    grep "testuser2:" /etc/passwd && userdel -rf testuser2
    grep "testuser3:" /etc/passwd && userdel -rf testuser3
    grep "test:" /etc/group && groupdel test

    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."

    useradd testuser
    passwd testuser <<EOF
$NODE1_PASSWORD
$NODE1_PASSWORD
EOF

    CHECK_RESULT $? 0 0 "set user passwd fail"
    grep testuser /etc/passwd
    CHECK_RESULT $? 0 0  "check testuser passwd fail"

    useradd -e 2020-10-30 testuser1
    CHECK_RESULT $? 0 0 "run useradd -e fail"
    chage -l testuser1 | grep 2020 | grep Oct | grep 30
    CHECK_RESULT $? 0 0 "check testuser1 info fail"

    chage -M 4 testuser1
    CHECK_RESULT $? 0 0 "check chage -M fail"
    chage -l testuser1 | grep Maximum | grep 4
    CHECK_RESULT $? 0 0 "check testuser1 info after chage -M fail"
    useradd --help 2>&1 | grep "Usage"
    CHECK_RESULT $? 0 0 "check useradd help fail"
    echo testuser1:Administrator12#$ | chpasswd
    CHECK_RESULT $? 0 0 "run chpassed fail"

    test -d /home/testuser2 || mkdir /home/testuser2
    useradd testuser2 2>&1 | grep 'already exists'
    CHECK_RESULT $? 0 0 "check useradd testuser2 fail"

    groupadd test
    gid=$(grep "test:" /etc/group | awk -F':' '{print $3}')
    useradd -g "${gid}" -m testuser3
    CHECK_RESULT $? 0 0 "change testuser3 group fail"

    test $(grep testuser3 /etc/passwd | awk -F ':' '{print $4}') -eq "${gid}"
    CHECK_RESULT $? 0 0 "check grep testuser3 /etc/passwd fail"
    test -d /home/testuser3
    CHECK_RESULT $? 0 0 "check /home/testuser3 fail"
    userdel -rf testuser3
    CHECK_RESULT $? 0 0 "check userdel fail"
    test -d /home/testuser3
    CHECK_RESULT $? 1 0 "check testuser3 dir fail"
    grep testuser3 /etc/passwd
    CHECK_RESULT $? 1 0 "check testuser3 passwd fail"

    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."

    userdel -rf testuser
    userdel -rf testuser1
    userdel -rf testuser2
    groupdel test

    LOG_INFO "End to restore the test environment."
}

main $@
