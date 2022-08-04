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
# @Author    :   xuchunlin
# @Contact   :   xcl_job@163.com
# @Date      :   2020.05-09
# @License   :   Mulan PSL v2
# @Desc      :   Command test-ip rule
# ############################################
source ${OET_PATH}/libs/locallibs/common_lib.sh
function config_params() {
    LOG_INFO "Start loading data!"
    test_eth1=$(ls /sys/class/net/ | grep -Ewv 'lo.*|docker.*|bond.*|vlan.*|virbr.*|br.*' | grep -v $(ip route | grep ${NODE1_IPV4} | awk '{print$3}') | sed -n 1p)
    LOG_INFO "Loading data is complete!"
}
function run_test() {
    LOG_INFO "Start executing testcase!"
    ip addr add 192.168.2.100/24 dev ${test_eth1}
    ip addr add 2001:222::2/64 dev ${test_eth1}
    CHECK_RESULT $?
    ip -6 rule add from 2001:222::2/64 table 1 pref 100
    CHECK_RESULT $?
    ip -6 rule list | grep "2001:222::2/64"
    CHECK_RESULT $?
    ip -6 rule del from 2001:222::2/64
    CHECK_RESULT $?
    ip -6 rule list | grep "2001:222::2/64"
    CHECK_RESULT $? 0 1
    LOG_INFO "End of testcase execution!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    nmcli con delete ${test_eth1}
    LOG_INFO "Finish environment cleanup."
}

main $@
