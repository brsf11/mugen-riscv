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
# @Desc      :   Test firewalld and iptables
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

check_iptables() {
    case $1 in
    mangle)
        iptables -t $1 -L | grep -A 20 PREROUTING | grep -A 10 INPUT | grep -A 10 FORWARD | grep -A 10 OUTPUT | grep -A 10 POSTROUTING || return 1
        ip6tables -t $1 -L | grep -A 20 PREROUTING | grep -A 10 INPUT | grep -A 10 FORWARD | grep -A 10 OUTPUT | grep -A 10 POSTROUTING || return 1
        ;;
    nat)
        iptables -t $1 -L | grep -A 20 PREROUTING | grep -A 10 INPUT | grep -A 10 OUTPUT | grep -A 10 POSTROUTING || return 1
        ip6tables -t $1 -L | grep -A 20 PREROUTING | grep -A 10 INPUT | grep -A 10 OUTPUT | grep -A 10 POSTROUTING || return 1
        ;;
    filter)
        iptables -t $1 -L | grep -A 20 INPUT | grep -A 10 FORWARD | grep -A 10 OUTPUT || return 1
        ip6tables -t $1 -L | grep -A 20 INPUT | grep -A 10 FORWARD | grep -A 10 OUTPUT || return 1
        ;;
    raw)
        iptables -t $1 -L | grep -A 20 PREROUTING | grep -A 10 OUTPUT || return 1
        ip6tables -t $1 -L | grep -A 20 PREROUTING | grep -A 10 OUTPUT || return 1
        ;;
    esac
    return 0
}

check_status() {
    check_iptables mangle || return 1
    check_iptables nat || return 1
    check_iptables filter || return 1
    check_iptables raw || return 1
    return 0
}

function run_test() {
    LOG_INFO "Start to run test."
    if systemctl status firewalld | grep running; then
        check_status
        CHECK_RESULT $? 0 0 "Iptables execution failed"
        systemctl stop firewalld
        CHECK_RESULT $? 0 0 "Failed to stop cockpit service"
        systemctl status firewalld | grep dead
        CHECK_RESULT $? 0 0 "Failed to stop cockpit service"
        check_status
        CHECK_RESULT $? 0 0 "Iptables execution failed"
        systemctl restart firewalld
        CHECK_RESULT $? 0 0 "Failed to restart cockpit service"
        systemctl status firewalld | grep running
        CHECK_RESULT $? 0 0 "Failed to restart cockpit service"
        check_status
        CHECK_RESULT $? 0 0 "Iptables execution failed"
    else
        check_status
        CHECK_RESULT $? 0 0 "Iptables execution failed"
        systemctl start firewalld
        CHECK_RESULT $? 0 0 "Failed to start cockpit service"
        systemctl status firewalld | grep running
        CHECK_RESULT $? 0 0 "Failed to start cockpit service"
        check_status
        CHECK_RESULT $? 0 0 "Iptables execution failed"
    fi
    LOG_INFO "End to run test."
}

main "$@"
