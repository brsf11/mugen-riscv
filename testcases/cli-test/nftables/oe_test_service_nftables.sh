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
# @Desc      :   Test nftables.service restart
# #############################################

source "../common/common_lib.sh"

function run_test() {
    LOG_INFO "Start testing..."
    test_execution nftables.service
    systemctl start nftables.service
    sed -i 's\ExecStart=/sbin/nft -f /etc/sysconfig/nftables.conf\ExecStart=/sbin/nft -c list tables\g' /usr/lib/systemd/system/nftables.service
    systemctl daemon-reload
    systemctl reload nftables.service
    CHECK_RESULT $? 0 0 "nftables.service reload failed"
    systemctl status nftables.service | grep "active (exited)"
    CHECK_RESULT $? 0 0 "nftables.service reload causes the service status to change"
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    sed -i 's\ExecStart=/sbin/nft -c list tables\ExecStart=/sbin/nft -f /etc/sysconfig/nftables.conf\g' /usr/lib/systemd/system/nftables.service
    systemctl daemon-reload
    systemctl reload nftables.service
    systemctl stop nftables.service
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
