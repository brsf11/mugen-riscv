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
# @Desc      :   Test lxc.service restart
# #############################################

source "../common/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL "lxc-libs lxc-devel busybox"
    systemctl start lxc.service
    lxc-create -t busybox -n myhost
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    test_execution lxc.service
    systemctl start lxc.service
    sed -i 's\StandardOutput=syslog\StandardOutput=rsyslog\g' /usr/lib/systemd/system/lxc.service
    systemctl daemon-reload
    systemctl reload lxc.service
    CHECK_RESULT $? 0 0 "lxc.service reload failed"
    systemctl status lxc.service | grep "Active: active"
    CHECK_RESULT $? 0 0 "lxc.service reload causes the service status to change"
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    lxc-destroy -n myhost
    sed -i 's\StandardOutput=rsyslog\StandardOutput=syslog\g' /usr/lib/systemd/system/lxc.service
    systemctl daemon-reload
    systemctl reload lxc.service
    systemctl stop lxc.service
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
