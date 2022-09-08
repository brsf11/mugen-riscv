#!/usr/bin/bash

# Copyright (c) 2022 Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   Classicriver_jia
# @Contact   :   classicriver_jia@foxmail.com
# @Date      :   2020.4.27
# @License   :   Mulan PSL v2
# @Desc      :   SYSCTL modifies kernel parameters
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function run_test() {
    LOG_INFO "Start to run test."

    if [ ! -e /proc/sys/net/ipv6 ]; then
        LOG_WARN "No /proc/sys/net/ipv6 test not run."
        LOG_INFO "End to run test."
        exit 0
    fi

    CHECK_RESULT "$(sysctl -a | grep -ioE 'dev|kernel|net' | sort -u | wc -l)" 3 0 "run sysctl -a | grep -ioE 'dev|kernel|net' fail"
    sysctl net.ipv6.conf.lo.disable_ipv6=1
    CHECK_RESULT $? 0 0 "run sysctl enable fail"
    CHECK_RESULT "$(sysctl -a | grep net.ipv6.conf.lo.disable_ipv6 | awk '{print$3}')" 1 0 "check net.ipv6.conf.lo.disable_ipv6 enable fail"
    sysctl -w net.ipv6.conf.lo.disable_ipv6=0
    CHECK_RESULT $? 0 0 "run sysctl disable fail"
    CHECK_RESULT "$(sysctl -a | grep net.ipv6.conf.lo.disable_ipv6 | awk '{print$3}')" 0 0 "check net.ipv6.conf.lo.disable_ipv6 disable fail"

    LOG_INFO "End to run test."
}

main $@
