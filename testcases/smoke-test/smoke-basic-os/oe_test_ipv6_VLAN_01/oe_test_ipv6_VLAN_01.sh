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
# @Desc      :   Test add ipv6 vlan
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function run_test() {
    LOG_INFO "Start to run test."
    ip link add dev vlan.1 link ${NODE1_NIC} type vlan id 1
    CHECK_RESULT $? 0 0 "Failed to add VLAN"
    ip a | grep "vlan.1@${NODE1_NIC}"
    CHECK_RESULT $? 0 0 "Failed to show VLAN"
    ip link del dev vlan.1
    CHECK_RESULT $? 0 0 "Failed to delete VLAN"
    ip a | grep "vlan.1@${NODE1_NIC}"
    CHECK_RESULT $? 0 1 "Succeed to show VLAN"
    LOG_INFO "End to run test."
}

main "$@"
