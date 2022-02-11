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
# @Desc      :   Group directory access permission settings
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh
function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    grep "testuser1:" /etc/passwd && userdel -rf testuser1
    grep "myproject:" /etc/group && groupdel myproject
    test -d /tmp/myproject || rm -rf /tmp/myproject
    useradd testuser1
    mkdir /tmp/myproject
    groupadd myproject
    chown root:myproject /tmp/myproject
    chmod 2775 /tmp/myproject
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    ls -ld /tmp/myproject | awk -F ' ' '{print$4}' | grep myproject
    CHECK_RESULT $?
    usermod -aG myproject testuser1
    CHECK_RESULT $?
    su - testuser1 -c "echo 'test' > /tmp/myproject/test"
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    userdel -rf testuser1
    groupdel myproject
    rm -rf /tmp/myproject
    LOG_INFO "End to restore the test environment."
}

main "$@"
