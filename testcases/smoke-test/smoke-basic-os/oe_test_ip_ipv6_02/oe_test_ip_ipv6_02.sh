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
# @Date      :   2022/07/08
# @License   :   Mulan PSL v2
# @Desc      :   IP add IPv6 address in multiple configuration formats
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function run_test() {
    LOG_INFO "Start to run test."
    ip -6 addr add 4::4/64 dev ${NODE1_NIC}
    CHECK_RESULT $? 0 0 "Failed to add ipv6 4::4"
    ip -6 address show dev ${NODE1_NIC} | grep "4::4/64"
    CHECK_RESULT $? 0 0 "Failed to show ipv6 4::4"
    ip -6 addr add ::7/64 dev ${NODE1_NIC}
    CHECK_RESULT $? 0 0 "Failed to add ipv6 ::7"
    ip -6 address show dev ${NODE1_NIC} | grep "::7/64"
    CHECK_RESULT $? 0 0 "Failed to show ipv6 ::7"
    ip -6 addr add 1111:1111:1111:1111:1111:1111:1111:1111/64 dev ${NODE1_NIC}
    CHECK_RESULT $? 0 0 "Failed to add ipv6 1111:"
    ip -6 address show dev ${NODE1_NIC} | grep "1111:1111:1111:1111:1111:1111:1111:1111/64"
    CHECK_RESULT $? 0 0 "Failed to show ipv6 1111:"
    ip -6 addr add 2001:da8:8000:d010:0:5efe:3.3.3.3/64 dev ${NODE1_NIC}
    CHECK_RESULT $? 0 0 "Failed to add ipv6 2001:"
    ip -6 address show dev ${NODE1_NIC} | grep "2001:da8:8000:d010:0:5efe:303:303/64"
    CHECK_RESULT $? 0 0 "Failed to show ipv6 2001:"
    ip -6 addr add 9000:0000:0000:0000:0000:0000:0000:0009/64 dev ${NODE1_NIC}
    CHECK_RESULT $? 0 0 "Failed to add ipv6 9000:"
    ip -6 address show dev ${NODE1_NIC} | grep "9000::9/64"
    CHECK_RESULT $? 0 0 "Failed to show ipv6 9000:"
    ip -6 addr add 2000::/3 dev ${NODE1_NIC}
    CHECK_RESULT $? 0 0 "Failed to add ipv6 2000::"
    ip -6 address show dev ${NODE1_NIC} | grep "2000::/3"
    CHECK_RESULT $? 0 0 "Failed to show ipv6 2000::"
    ip -6 addr add fec0::/10 dev ${NODE1_NIC}
    CHECK_RESULT $? 0 0 "Failed to add ipv6 fec0::"
    ip -6 address show dev ${NODE1_NIC} | grep "fec0::/10"
    CHECK_RESULT $? 0 0 "Failed to show ipv6 fec0::"
    ip -6 addr add fe80::/10 dev ${NODE1_NIC}
    CHECK_RESULT $? 0 0 "Failed to add ipv6 fe80::"
    ip -6 address show dev ${NODE1_NIC} | grep "fe80::/10"
    CHECK_RESULT $? 0 0 "Failed to show ipv6 fe80::"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    ip -6 addr del 4::4/64 dev ${NODE1_NIC}
    ip -6 addr del ::7/64 dev ${NODE1_NIC}
    ip -6 addr del 1111:1111:1111:1111:1111:1111:1111:1111/64 dev ${NODE1_NIC}
    ip -6 addr del 2001:da8:8000:d010:0:5efe:3.3.3.3/64 dev ${NODE1_NIC}
    ip -6 addr del 9000:0000:0000:0000:0000:0000:0000:0009/64 dev ${NODE1_NIC}
    ip -6 addr del 2000::/3 dev ${NODE1_NIC}
    ip -6 addr del fec0::/10 dev ${NODE1_NIC}
    ip -6 addr del fe80::/10 dev ${NODE1_NIC}
    LOG_INFO "End to restore the test environment."
}

main "$@"
