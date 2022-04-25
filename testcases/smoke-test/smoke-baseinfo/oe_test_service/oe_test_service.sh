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
# @Desc      :   Test basic service status
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh
function run_test() {
    LOG_INFO "Start to run test."
    systemctl | grep sys
    CHECK_RESULT $? 0 0 "Failed to display service list"
    systemctl status rsyslog | grep running
    CHECK_RESULT $? 0 0 "service status is not running"
    systemctl stop rsyslog
    CHECK_RESULT $? 0 0 "Failed to stop rsyslog service"
    systemctl status rsyslog | grep dead
    CHECK_RESULT $? 0 0 "Failed to stop rsyslog service"
    systemctl start rsyslog
    CHECK_RESULT $? 0 0 "Failed to start rsyslog service"
    systemctl restart rsyslog
    CHECK_RESULT $? 0 0 "Failed to start rsyslog service"
    systemctl disable rsyslog
    CHECK_RESULT $? 0 0 "Failed to start rsyslog service"
    systemctl enable rsyslog
    CHECK_RESULT $?0 0 "Failed to start rsyslog service"
    whitelist='kdump|lm_sensors|wait-online'
    systemctl -all --failed | grep -vE ${whitelist} | grep failed
    CHECK_RESULT $? 1 0 "There are failed services"
    [ $(journalctl -aeb | wc -l) -gt 0 ]
    CHECK_RESULT $? 0 0 "Failed command: journalctl"
    LOG_INFO "End to run test."
}

main "$@"
