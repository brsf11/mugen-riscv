#!/usr/bin/bash

# Copyright (c) 2023. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.
####################################
#@Author    	:   dingjiao
#@Contact   	:   15829797643@163.com
#@Date      	:   2022-07-06
#@License   	:   Mulan PSL v2
#@Desc      	:   Enable/Disable Ipv6 in conf file
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function run_test() {
    LOG_INFO "Start to run test."
    echo -e "net.ipv6.conf.all.disable_ipv6=1 \nnet.ipv6.conf.default.disable_ipv6=1" >>/etc/sysctl.conf
    CHECK_RESULT $? 0 0 "Set disable ipv6: failed!"
    sysctl -p | grep -E "net.ipv6.conf.all.disable_ipv6 = 1|net.ipv6.conf.default.disable_ipv6 = 1"
    CHECK_RESULT $? 0 0 "Check disable ipv6: failed!"
    ip a | grep "inet6"
    CHECK_RESULT $? 1 0 "Check all ipv6: failed!"
    sed -i "s/disable_ipv6=1/disable_ipv6=0/g" /etc/sysctl.conf
    CHECK_RESULT $? 0 0 "Enable all ipv6: failed!"
    sysctl -p | grep -E "net.ipv6.conf.all.disable_ipv6 = 0|net.ipv6.conf.default.disable_ipv6 = 0"
    CHECK_RESULT $? 0 0 "Set enable ipv6: failed!"
    ip a | grep "inet6"
    CHECK_RESULT $? 0 0 "Check all ipv6 is enable: failed!"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    sed -i '/disable_ipv6=0/d' /etc/sysctl.conf
    sed -i '/disable_ipv6=1/d' /etc/sysctl.conf
    LOG_INFO "End to restore the test environment."
}

main "$@"
