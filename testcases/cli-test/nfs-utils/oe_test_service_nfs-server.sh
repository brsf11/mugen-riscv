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
# @Desc      :   Test nfs-server.service restart
# #############################################

source "../common/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL nfs-utils
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    test_execution nfs-server.service
    systemctl start nfs-server.service
    sed -i 's\ExecStart=/usr/sbin/rpc.nfsd\ExecStart=/usr/sbin/rpc.nfsd -d\g' /usr/lib/systemd/system/nfs-server.service
    systemctl daemon-reload
    systemctl reload nfs-server.service
    CHECK_RESULT $? 0 0 "nfs-server.service reload failed"
    systemctl status nfs-server.service | grep "active (exited)"
    CHECK_RESULT $? 0 0 "nfs-server.service reload causes the service status to change"
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    sed -i 's\ExecStart=/usr/sbin/rpc.nfsd -d\ExecStart=/usr/sbin/rpc.nfsd\g' /usr/lib/systemd/system/nfs-server.service
    systemctl daemon-reload
    systemctl reload nfs-server.service
    systemctl stop nfs-server.service
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
