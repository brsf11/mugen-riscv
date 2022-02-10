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
# @Desc      :   Service management common command test -sudo
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh
function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    grep "test:" /etc/passwd && userdel -rf test
    useradd test
    echo ${NODE1_PASSWORD} | passwd test --stdin
    cp /etc/sudoers /etc/sudoers.bak
    echo "test  ALL=(ALL) NOPASSWD:ALL" >>/etc/sudoers
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    sudo -l | grep "commands on" | grep "User root"
    CHECK_RESULT $?
    su - test -c "sudo -l --stdin | grep 'commands on' | grep 'User test'"
    CHECK_RESULT $?
    sudo --help | grep -i "usage"
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    userdel -rf test
    mv /etc/sudoers.bak /etc/sudoers
    LOG_INFO "End to restore the test environment."
}

main "$@"
