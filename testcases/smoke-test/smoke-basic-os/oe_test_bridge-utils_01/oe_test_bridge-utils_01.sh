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
# @Date      :   2022/07/05
# @License   :   Mulan PSL v2
# @Desc      :   Test the basic functions of brctl
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL "bridge-utils net-tools"
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    brctl addbr br0
    CHECK_RESULT $? 0 0 "br0 setting failed"
    ifconfig br0 192.168.1.21/24
    CHECK_RESULT $? 0 0 "ip setting failed"
    ip a s | grep br0 | grep UP
    CHECK_RESULT $? 0 0 "br0 setting failed"
    ip a s | grep -A 5 br0 | grep "192.168.1.21/24"
    CHECK_RESULT $? 0 0 "ip setting failed"
    systemctl restart NetworkManager
    CHECK_RESULT $? 0 0 "ip setting failed"
    ip a s | grep br0 | grep UP
    CHECK_RESULT $? 0 0 "br0 setting failed"
    ip a s | grep -A 5 br0 | grep "192.168.1.21/24"
    CHECK_RESULT $? 0 0 "ip setting failed"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    ifconfig br0 down
    brctl delbr br0
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}

main "$@"
