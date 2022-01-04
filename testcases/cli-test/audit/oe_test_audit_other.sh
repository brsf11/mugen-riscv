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
# @Author    :   huyahui
# @Contact   :   huyahui8@163.com
# @Date      :   2022/01/04
# @License   :   Mulan PSL v2
# @Desc      :   Other operating auditd testing services
# #############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"
function run_test() {
    LOG_INFO "Start executing testcase."
    service auditd start
    CHECK_RESULT $? 0 0 "Failed to start auditd service"
    service auditd stop
    CHECK_RESULT $? 0 0 "Failed to stop auditd service"
    service auditd restart
    CHECK_RESULT $? 0 0 "Failed to restart auditd service"
    service auditd reload
    CHECK_RESULT $? 0 0 "Failed to reload auditd service"
    service auditd rotate
    CHECK_RESULT $? 0 0 "Failed to rotate auditd service"
    service auditd resume
    CHECK_RESULT $? 0 0 "Failed to resume auditd service"
    service auditd condrestart
    CHECK_RESULT $? 0 0 "Failed to condrestart auditd service"
    systemctl status auditd | grep running
    CHECK_RESULT $? 0 0 "Failed to systemctl auditd services with running status"
    LOG_INFO "Finish testcase execution."
}
main "$@"
