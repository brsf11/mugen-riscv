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
# @Desc      :   IP configuration static address
# ############################################
source ${OET_PATH}/libs/locallibs/common_lib.sh
function config_params() {
    LOG_INFO "Start loading data!"
    test_eth1=$(ls /sys/class/net/ | grep -Ewv 'lo.*|docker.*|bond.*|vlan.*|virbr.*|br.*' | grep -v $(ip route | grep ${NODE1_IPV4} | awk '{print$3}') | sed -n 1p)
    LOG_INFO "Loading data is complete!"
}
function run_test() {
    LOG_INFO "Start executing testcase!"
    ip address add 192.168.0.10/24 dev ${test_eth1}
    CHECK_RESULT $?
    ip addr show dev ${test_eth1} | grep "192.168.0.10"
    CHECK_RESULT $?
    LOG_INFO "End of testcase execution!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    nmcli con delete ${test_eth1}
    LOG_INFO "Finish environment cleanup."
}

main $@
