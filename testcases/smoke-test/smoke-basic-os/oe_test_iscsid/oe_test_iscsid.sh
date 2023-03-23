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
# @Date      :   2022/06/09
# @License   :   Mulan PSL v2
# @Desc      :   Test the basic functions of open-iscsi
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL open-iscsi
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    flag=1
    while ((flag < 20)); do
        systemctl start iscsid
        CHECK_RESULT $? 0 0 "Failed to start iscsid"
        SLEEP_WAIT 3
        systemctl status iscsid | grep running
        CHECK_RESULT $? 0 0 "Service status not start"
        systemctl stop iscsid
        CHECK_RESULT $? 0 0 "Failed to stop iscsid"
        SLEEP_WAIT 3
        systemctl status iscsid | grep dead
        CHECK_RESULT $? 0 0 "Service status not stop"
        let flag+=1
    done
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}

main "$@"
