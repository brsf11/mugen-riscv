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
    LOG_INFO "Start executing testcase."
    CHECK_RESULT "$(sysctl -a | grep -ioE 'dev|kernel|net' | sort -u | wc -l)" 3
    sysctl net.ipv6.conf.lo.disable_ipv6=1
    CHECK_RESULT $?
    CHECK_RESULT "$(sysctl -a | grep net.ipv6.conf.lo.disable_ipv6 | awk '{print$3}')" 1
    sysctl -w net.ipv6.conf.lo.disable_ipv6=0
    CHECK_RESULT $?
    CHECK_RESULT "$(sysctl -a | grep net.ipv6.conf.lo.disable_ipv6 | awk '{print$3}')" 0
    LOG_INFO "End of testcase execution."
}

main $@
