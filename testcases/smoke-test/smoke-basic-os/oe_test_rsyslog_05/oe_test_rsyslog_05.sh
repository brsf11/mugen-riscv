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
# @Date      :   2022/06/27
# @License   :   Mulan PSL v2
# @Desc      :   Test the basic functions of rsyslog
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function run_test() {
    LOG_INFO "Start to run test."
    flag=1
    while ((flag < 20)); do
        systemctl stop rsyslog
        CHECK_RESULT $? 0 0 "Service not stoped"
        SLEEP_WAIT 2
        systemctl start rsyslog
        CHECK_RESULT $? 0 0 "Service not start"
        SLEEP_WAIT 2
        systemctl restart rsyslog
        CHECK_RESULT $? 0 0 "Service not restart"
        test -s /run/log/imjournal.state
        CHECK_RESULT $? 0 0 "Failed to find imjournal.state"
        SLEEP_WAIT 2
        main_pid=$(systemctl status rsyslog | grep "Main PID" | awk '{print $3}')
        grep rsyslog /var/log/messages | grep $main_pid
        CHECK_RESULT $? 0 0 "Failed to find main_pid"
        let flag+=1
    done
    LOG_INFO "End to run test."
}

main "$@"
