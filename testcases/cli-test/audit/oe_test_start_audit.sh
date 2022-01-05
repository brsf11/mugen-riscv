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
# @Desc      :   Start auditd, set the boot to start
# #############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function run_test() {
    LOG_INFO "Start executing testcase."
    systemctl start auditd
    CHECK_RESULT $? 0 0 "Failed to start auditd service"
    chkconfig auditd | grep enable
    CHECK_RESULT $? 0 0 "Failed to chkconfig auditd service with status enable"
    systemctl disable auditd
    chkconfig auditd | grep disable
    CHECK_RESULT $? 0 0 "Failed to chkconfig auditd service with status disable"
    systemctl enable auditd
    chkconfig auditd | grep enable
    CHECK_RESULT $? 0 0 "Failed to chkconfig auditd service with status enable"
    LOG_INFO "Finish testcase execution."
}
main "$@"
