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
# @Date      :   2022/07/07
# @License   :   Mulan PSL v2
# @Desc      :   IP add IPv6 rule
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function run_test() {
    LOG_INFO "Start to run test."
    ip rule add from 10.46.177.97 lookup 104 table 2 pref 1001
    CHECK_RESULT $? 0 0 "Failed to add ipv4"
    ip rule show | grep "1001:" | grep "from 10.46.177.97 lookup 2"
    CHECK_RESULT $? 0 0 "Failed to show ipv4"
    ip rule add from 10.46.177.97 lookup 104 table 2 pref 1001 2>&1 | grep "File exists"
    CHECK_RESULT $? 0 0 "IPV4 does not exist"
    ip -6 rule add from fe80::366a:c2ff:fe24:34ca/64 lookup 104 pref 1500
    CHECK_RESULT $? 0 0 "Failed to add ipv6"
    ip -6 rule show | grep "1500:" | grep "from fe80::366a:c2ff:fe24:34ca/64 lookup 104"
    CHECK_RESULT $? 0 0 "Failed to show ipv6"
    ip -6 rule add from fe80::366a:c2ff:fe24:34ca/64 lookup 104 pref 1500 2>&1 | grep "File exists"
    CHECK_RESULT $? 0 0 "IPV6 does not exist"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    ip -6 rule del from fe80::366a:c2ff:fe24:34ca/64 lookup 104 pref 1500
    ip rule del from 10.46.177.97 lookup 104 table 2 pref 1001
    LOG_INFO "End to restore the test environment."
}

main "$@"
