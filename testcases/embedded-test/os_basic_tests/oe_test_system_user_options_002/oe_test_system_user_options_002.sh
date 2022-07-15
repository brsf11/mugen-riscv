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
# @Author    :   xuchunlin
# @Contact   :   xcl_job@163.com
# @Date      :   2020-04-09
# @License   :   Mulan PSL v2
# @Desc      :   Modify User test
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."

    grep -w testuser1 /etc/passwd && userdel testuser1
    grep -w testgroup1 /etc/group && groupdel testgroup1
    test -d /tmp/myproj || rm -rf /tmp/myproj
    useradd -u 555 testuser
    groupmod -g 555 testuser
    groupadd -g 72 testgroup1
    useradd testuser1
    mkdir /tmp/myproj
    groupadd myproj
    chown root:myproj /tmp/myproj
    chmod 2775 /tmp/myproj

    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."

    usermod -u 666 testuser
    grep -w testuser /etc/passwd | awk -F : '{print$3}' | grep 666
    CHECK_RESULT $? 0 0 "check testuser mod fail"

    usermod -g 72 testuser
    CHECK_RESULT $? 0 0 "run usermod -g fail"
    grep testuser /etc/passwd | awk -F : '{print$4}' | grep 72
    CHECK_RESULT $? 0 0 "check testuser mod fail"

    ls -ld /tmp/myproj | awk '{print$4}' | grep myproj
    CHECK_RESULT $? 0 0 "check myproj info fail"
    usermod -aG myproj testuser1
    CHECK_RESULT $? 0 0 "run usermod -aG fail"

    su - testuser1 -c "echo 'test' > /tmp/myproj/test"
    CHECK_RESULT $? 0 0 "run testuser1 -c fail"
    usermod --help 2>&1 | grep Usage
    CHECK_RESULT $? 0 0 "check usermod help fail"

    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."

    userdel -rf testuser
    groupdel testuser
    groupdel testgroup1
    userdel -rf testuser1
    groupdel myproj
    rm -rf /tmp/myproj

    LOG_INFO "End to restore the test environment."
}

main $@
