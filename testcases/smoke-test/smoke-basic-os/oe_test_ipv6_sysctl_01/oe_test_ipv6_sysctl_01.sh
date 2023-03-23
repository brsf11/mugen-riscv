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
#@Desc      	:   Enable/Disable Ipv6
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function run_test() {
    LOG_INFO "Start to run test."
    grep 0 /proc/sys/net/ipv6/conf/default/disable_ipv6
    CHECK_RESULT $? 0 0 "Check default disable ipv6 is 0: failed!"
    grep 0 /proc/sys/net/ipv6/conf/all/disable_ipv6
    CHECK_RESULT $? 0 0 "Check all disable_ipv6 is 0: failed!"
    sysctl -w net.ipv6.conf.all.disable_ipv6=1
    CHECK_RESULT $? 0 0 "Disable all ipv6: failed!"
    sysctl -w net.ipv6.conf.default.disable_ipv6=1
    CHECK_RESULT $? 0 0 "Disable default ipv6: failed!"
    grep 1 /proc/sys/net/ipv6/conf/default/disable_ipv6
    CHECK_RESULT $? 0 0 "Check default disable ipv6 is 1: failed!"
    grep 1 /proc/sys/net/ipv6/conf/all/disable_ipv6
    CHECK_RESULT $? 0 0 "Check all disable_ipv6 is 1: failed!"
    ip a | grep "inet6"
    CHECK_RESULT $? 1 0 "Get inet6: failed!"
    sysctl -w net.ipv6.conf.all.disable_ipv6=0
    CHECK_RESULT $? 0 0 "Set net.ipv6.conf.all.disable_ipv6=0: failed!"
    sysctl -w net.ipv6.conf.default.disable_ipv6=0
    CHECK_RESULT $? 0 0 "net.ipv6.conf.default.disable_ipv6=0: failed!"
    grep 0 /proc/sys/net/ipv6/conf/default/disable_ipv6
    CHECK_RESULT $? 0 0 "Check default disable ipv6 is 0: failed!"
    grep 0 /proc/sys/net/ipv6/conf/all/disable_ipv6
    CHECK_RESULT $? 0 0 "Check all disable ipv6 is 0: failed!"
    ip a | grep "inet6"
    CHECK_RESULT $? 0 0 "Enable all ipv6: failed!"
    LOG_INFO "End to run test."
}

main "$@"
