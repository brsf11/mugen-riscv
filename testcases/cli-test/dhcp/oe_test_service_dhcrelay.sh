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
# @Desc      :   Test dhcrelay.service restart
# #############################################

source "../common/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    cp /lib/systemd/system/dhcrelay.service /etc/systemd/system/
    ip addr add 192.168.0.1 dev "${NODE1_NIC}"
    sed -i 's\dhcrelay -d --no-pid\dhcrelay -d --no-pid 192.168.0.1 \g' /etc/systemd/system/dhcrelay.service
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    test_execution dhcrelay.service
    test_reload dhcrelay.service
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    systemctl stop dhcrelay.service
    rm -rf /etc/systemd/system/dhcrelay.service
    ip addr del 192.168.0.1 dev "${NODE1_NIC}"
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
