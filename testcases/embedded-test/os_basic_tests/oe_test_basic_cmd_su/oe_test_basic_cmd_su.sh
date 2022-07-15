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
# @Desc      :   Service Management Common Command Test -su
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."

    grep "testuser:" /etc/passwd && userdel -rf testuser
    groupdel testuser

    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."

    useradd testuser
    echo $NODE1_PASSWORD | passwd testuser --stdin
    su - testuser -c "whoami | grep testuser"
    CHECK_RESULT $? 0 0 "check su -c user name testuser fail"

    su - root -c "whoami | grep root"
    CHECK_RESULT $? 0 0 "check su -c user name root fail"
    su - root -c "ls /root"
    CHECK_RESULT $? 0 0 "check ls /root fail"

    su --help 2>&1 | grep "Usage"
    CHECK_RESULT $? 0 0 "check su help fail"

    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."

    userdel -r testuser

    LOG_INFO "End to restore the test environment."
}

main "$@"
