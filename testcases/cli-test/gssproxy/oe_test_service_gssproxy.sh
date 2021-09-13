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
# @Desc      :   Test gssproxy.service restart
# #############################################

source "../common/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL gssproxy
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    test_execution gssproxy.service
    systemctl start gssproxy.service
    sed -i 's\/usr/sbin/gssproxy -D\/usr/sbin/gssproxy -D --debug-level=1\g' /usr/lib/systemd/system/gssproxy.service
    systemctl daemon-reload
    systemctl reload gssproxy.service
    CHECK_RESULT $? 0 0 "gssproxy.service reload failed"
    systemctl status gssproxy.service | grep "Active: active"
    CHECK_RESULT $? 0 0 "gssproxy.service reload causes the service status to change"
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    sed -i 's\/usr/sbin/gssproxy -D --debug-level=1\/usr/sbin/gssproxy -D\g' /usr/lib/systemd/system/gssproxy.service
    systemctl daemon-reload
    systemctl reload gssproxy.service
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
