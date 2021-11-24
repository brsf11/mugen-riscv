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
# @Desc      :   Test ptp4l.service restart
# #############################################

source "../common/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    eth_name=$(ip route | grep "${NODE1_IPV4}" | awk '{print $3}')
    if [ "$(ethtool -T ${eth_name} | grep 'PTP Hardware Clock' | awk '{print $4}')" == none ]; then
        LOG_INFO "The environment does not support testing"
        exit 1
    else
        DNF_INSTALL linuxptp
        sed -i "s\-f /etc/ptp4l.conf -i eth0\-f /etc/ptp4l.conf -i ${eth_name}\g" /etc/sysconfig/ptp4l
    fi
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    test_execution ptp4l.service
    test_reload ptp4l.service
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    sed -i "s\-f /etc/ptp4l.conf -i ${eth_name}\-f /etc/ptp4l.conf -i eth0\g" /etc/sysconfig/ptp4l
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
