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
# @Desc      :   Test the basic functions of dnsmasq
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL "dnsmasq bind-utils"
    cp /etc/dnsmasq.conf /etc/dnsmasq.conf.bak
    sed -i 's/#port=5353/port=53/' /etc/dnsmasq.conf
    echo "address=/lvs-test.com/127.0.0.1
address=/lvs-test.com/::1" >>/etc/dnsmasq.d/lvs.test.conf
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    systemctl restart dnsmasq
    CHECK_RESULT $? 0 0 "Service startup failed"
    SLEEP_WAIT 2
    dig lvs-test.com AAAA +short @127.0.0.1 | grep "::1"
    CHECK_RESULT $? 0 0 "Failed to execute dig"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    systemctl stop dnsmasq
    mv -f /etc/dnsmasq.conf.bak /etc/dnsmasq.conf
    rm -rf /etc/dnsmasq.d/lvs.test.conf
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}

main "$@"
