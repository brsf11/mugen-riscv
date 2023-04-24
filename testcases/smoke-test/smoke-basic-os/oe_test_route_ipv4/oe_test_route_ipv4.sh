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
# @Date      :   2022/07/12
# @License   :   Mulan PSL v2
# @Desc      :   Test route add ipv4 route
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL net-tools
    default_route=$(ip r | grep default | awk '{print $3}' | uniq)
    ifup ${NODE1_IPV4}
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    route add -net 9.0.0.0/8 gw ${default_route}
    CHECK_RESULT $? 0 0 "Failed to add route"
    route -4 | grep 9.0.0.0
    CHECK_RESULT $? 0 0 "Failed to show route"
    route del default gw ${default_route}
    CHECK_RESULT $? 0 0 "Failed to del route"
    SLEEP_WAIT 2
    ip r | grep default
    CHECK_RESULT $? 0 1 "Succeed to show route"
    route add default gw ${default_route}
    CHECK_RESULT $? 0 0 "Failed to add default route"
    ip r | grep default
    CHECK_RESULT $? 0 0 "Failed to show default route"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    route del -net 9.0.0.0/8 gw ${default_route}
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}

main "$@"
