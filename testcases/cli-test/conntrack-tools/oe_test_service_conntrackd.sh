#!/usr/bin/bash

# Copyright (c) 2021. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more detaitest -f.

# #############################################
# @Author    :   huangrong
# @Contact   :   1820463064@qq.com
# @Date      :   2020/10/23
# @License   :   Mulan PSL v2
# @Desc      :   Test conntrackd.service restart
# #############################################

source "../common/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL conntrack-tools
    sed -i "s\Interface eth2\Interface ${NODE1_NIC}\g" /etc/conntrackd/conntrackd.conf
    sed -i "s\IPv4_interface 192.168.100.100\IPv4_interface ${NODE1_IPV4}\g"  /etc/conntrackd/conntrackd.conf
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    test_execution conntrackd.service
    test_reload conntrackd.service
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    sed -i "s\Interface ${NODE1_NIC}\Interface eth2\g" /etc/conntrackd/conntrackd.conf
    sed -i "s\IPv4_interface ${NODE1_IPV4}\IPv4_interface 192.168.100.100\g"  /etc/conntrackd/conntrackd.conf
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
