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
# @Author    :   liujingjing
# @Contact   :   liujingjing25812@163.com
# @Date      :   2022/06/15
# @License   :   Mulan PSL v2
# @Desc      :   Test sudo -U
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    OLD_LANG=$LANG
    export LANG=en_US.UTF-8
    DNF_INSTALL sssd
    echo 'echo "export PATH=/tmp:\$PATH"' >/tmp/test.sh
    cp -f /etc/sudoers /etc/sudoers.bak
    chmod +w /etc/sudoers
    useradd -m testuser1
    useradd -m testuser2
    echo "testuser1 ALL=(ALL) NOPASSWD:ALL" >>/etc/sudoers
    echo "testuser2 ALL=(ALL) NOPASSWD:ALL" >>/etc/sudoers
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    su -c "sudo -l -U testuser2" testuser1 | grep "Matching Defaults entries for testuser2"
    CHECK_RESULT $? 0 0 "Failed to execute sudo"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    mv -f /etc/sudoers.bak /etc/sudoers
    userdel -rf testuser1
    userdel -rf testuser2
    DNF_REMOVE
    export LANG=${OLD_LANG}
    LOG_INFO "End to restore the test environment."
}

main "$@"
