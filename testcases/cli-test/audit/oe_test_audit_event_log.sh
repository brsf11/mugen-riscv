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
# @Desc      :   Test event logging service auditd
# #############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"
function pre_test() {
    LOG_INFO "Start environmental preparation."
    rm -rf /var/log/audit/audit.log*
    auditctl -D
    service auditd restart
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start executing testcase."
    auditctl -w /etc/ssh/sshd_config -p warx -k sshd_config
    CHECK_RESULT $? 0 0 "For '/etc/ssh/sshd_config' file setting auditctl rules failed"
    grep "sshd_config" /var/log/audit/audit.log
    CHECK_RESULT $? 0 0 "Failed to find 'sshd_config' from '/var/log/audit/audit.log' file"
    LOG_INFO "Finish testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    auditctl -D
    service auditd restart
    LOG_INFO "Finish environment cleanup!"
}
main "$@"
