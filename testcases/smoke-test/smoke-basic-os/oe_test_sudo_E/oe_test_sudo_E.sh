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
# @Desc      :   Test sudo -E
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    echo 'echo "export PATH=/tmp:\$PATH"' >/tmp/test.sh
    cp -f /etc/sudoers /etc/sudoers.bak
    chmod +w /etc/sudoers
    useradd testuser
    echo -e "testuser ALL=(ALL) NOPASSWD:ALL" >>/etc/sudoers
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    su -c "sudo -E sh /tmp/test.sh" testuser | grep "/tmp"
    CHECK_RESULT $? 0 0 "Failed to execute sudo"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    mv -f /etc/sudoers.bak /etc/sudoers
    userdel -rf testuser
    rm -rf /tmp/test.sh
    LOG_INFO "End to restore the test environment."
}

main "$@"
