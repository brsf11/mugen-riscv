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
# @Date      :   2022/07/06
# @License   :   Mulan PSL v2
# @Desc      :   Test the basic functions of dhclient
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL net-tools
    cp /etc/resolv.conf /etc/resolv.conf.bak
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    if ps -aux | grep -w "dhclient" | grep -vE "grep|sh"; then
        netstat -aupx | grep dhclient | awk '{print $NF}' | uniq | wc -l | grep 1
        CHECK_RESULT $? 0 0 "There are multiple ports"
        echo "" >/etc/resolv.conf
        systemctl restart NetworkManager
        SLEEP_WAIT 3
        grep "nameserver" /etc/resolv.conf
        CHECK_RESULT $? 0 0 "Different files"
        netstat -aupx | grep dhclient | awk '{print $NF}' | uniq | wc -l | grep 1
        CHECK_RESULT $? 0 0 "Not just one ports"
    fi
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    mv -f /etc/resolv.conf.bak /etc/resolv.conf
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}

main "$@"
