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
# @Date      :   2020.05-08
# @License   :   Mulan PSL v2
# @Desc      :   Nmcli configure static IP connection
# ############################################
source ${OET_PATH}/libs/locallibs/common_lib.sh
function config_params() {
    LOG_INFO "Start loading data!"
    con_name='test_con'
    LOG_INFO "Loading data is complete!"
}

function run_test() {
    LOG_INFO "Start executing testcase!"
    nmcli connection add type ethernet con-name ${con_name} ifname ${NODE1_NIC} ip4 192.0.2.100/24 gw4 192.0.2.1 ip6 2001:db8::100/64 gw6 2001:db8::1 | grep successfully
    CHECK_RESULT $?
    nmcli con mod ${con_name} ipv4.dns "192.0.2.253 192.0.2.252"
    CHECK_RESULT $?
    nmcli con show ${con_name} | grep "ipv4.dns" | grep "192.0.2.253,192.0.2.252"
    CHECK_RESULT $?
    nmcli con mod ${con_name} ipv6.dns "2001:db8::fffc 2001:db8::fffd"
    CHECK_RESULT $?
    nmcli con show ${con_name} | grep "ipv6.dns" | grep "2001:db8::fffc,2001:db8::fffd"
    CHECK_RESULT $?
    nmcli con up ${con_name} ifname ${NODE1_NIC}
    CHECK_RESULT $?
    nmcli device status | grep "${con_name}" | grep "connected"
    CHECK_RESULT $?
    nmcli -p con show ${con_name} | grep "Connection profile details"
    CHECK_RESULT $?
    LOG_INFO "End of testcase execution!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    nmcli con delete ${con_name}
    LOG_INFO "Finish environment cleanup."
}

main $@
