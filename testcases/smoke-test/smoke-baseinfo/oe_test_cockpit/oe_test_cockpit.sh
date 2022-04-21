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
# @Date      :   2022/04/19
# @License   :   Mulan PSL v2
# @Desc      :   Test cockpit
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL cockpit
    LOG_INFO "End to prepare the test environment."
}
function run_test() {
    LOG_INFO "Start to run test."
    systemctl stop cockpit
    CHECK_RESULT $? 0 0 "Failed to stop cockpit service"
    systemctl status cockpit | grep dead
    CHECK_RESULT $? 0 0 "Failed to stop cockpit service"
    systemctl start cockpit
    CHECK_RESULT $? 0 0 "Failed to start cockpit service"
    systemctl status cockpit | grep running
    CHECK_RESULT $? 0 0 "Failed to start cockpit service"
    systemctl restart cockpit
    CHECK_RESULT $? 0 0 "Failed to restart cockpit service"
    systemctl status cockpit | grep running
    CHECK_RESULT $? 0 0 "Failed to restart cockpit service"
    systemctl disable cockpit
    CHECK_RESULT $? 0 0 "Failed to disbale cockpit service"
    curl https://localhost:9090/cockpit/login --user root:${NODE1_PASSWORD} -k | grep csrf-token
    CHECK_RESULT $? 0 0 "Cockpit service function failed"
    LOG_INFO "End to run test."
}
function post_test() {
    LOG_INFO "Start to restore the test environment."
    systemctl stop cockpit
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}

main "$@"
