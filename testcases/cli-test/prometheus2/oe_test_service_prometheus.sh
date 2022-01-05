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
# @Desc      :   Test prometheus.service restart
# #############################################

source "../common/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL prometheus2
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    test_execution prometheus.service
    systemctl start prometheus.service
    sed -i 's\ExecStart = /usr/sbin/prometheus\ExecStart = /usr/sbin/prometheus --log.level=debug\g' /usr/lib/systemd/system/prometheus.service
    systemctl daemon-reload
    systemctl reload prometheus.service
    CHECK_RESULT $? 0 0 "prometheus.service reload failed"
    systemctl status prometheus.service | grep "Active: active"
    CHECK_RESULT $? 0 0 "prometheus.service reload causes the service status to change"
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    sed -i 's\ExecStart = /usr/sbin/prometheus --log.level=debug\ExecStart = /usr/sbin/prometheus\g' /usr/lib/systemd/system/prometheus.service
    systemctl daemon-reload
    systemctl reload prometheus.service
    systemctl stop prometheus.service
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
