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
# @Desc      :   Test radvd.service restart
# #############################################

source "../common/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL radvd
    eth_name=$(ip route | grep "${NODE1_IPV4}" | awk '{print $3}')
    cp /etc/radvd.conf /etc/radvd.bak
    echo "interface ${eth_name}
{
        AdvSendAdvert on;
        MinRtrAdvInterval 3;
        MaxRtrAdvInterval 10;
        prefix 2001:db8:0:f101::1/64
        {
                AdvOnLink on;
                AdvAutonomous on;
                AdvRouterAddr on;
        };

};" >>/etc/radvd.conf
    echo 1 >/proc/sys/net/ipv6/conf/all/forwarding
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    test_execution radvd.service
    systemctl start radvd.service
    sed -i 's\ExecStart=/usr/sbin/radvd\ExecStart=/usr/sbin/radvd -m\g' /usr/lib/systemd/system/radvd.service
    systemctl daemon-reload
    systemctl reload radvd.service
    CHECK_RESULT $? 0 0 "radvd.service reload failed"
    systemctl status radvd.service | grep "Active: active"
    CHECK_RESULT $? 0 0 "radvd.service reload causes the service status to change"
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    sed -i 's\ExecStart=/usr/sbin/radvd -m\ExecStart=/usr/sbin/radvd\g' /usr/lib/systemd/system/radvd.service
    systemctl daemon-reload
    systemctl reload radvd.service
    systemctl stop radvd.service
    mv -f /etc/radvd.bak /etc/radvd.conf
    echo 0 >/proc/sys/net/ipv6/conf/all/forwarding
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
