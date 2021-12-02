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
# @Desc      :   Test nagios.service restart
# #############################################

source "../common/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL "nagios nagios-plugins-ping"
    sed -i 's\cfg_dir=/etc/nagios/conf.d\#cfg_dir=/etc/nagios/conf.d\g' /etc/nagios/nagios.cfg
    service=nagios.service
    log_time=$(date '+%Y-%m-%d %T')
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    test_restart "${service}"
    test_enabled "${service}"
    journalctl --since "${log_time}" -u "${service}" | grep -i "fail\|error" | grep -v "Total Errors:   0"
    CHECK_RESULT $? 0 1 "There is an error message for the log of ${service}"
    systemctl start "${service}"
    sed -i 's\ExecStartPre=/usr/sbin/nagios\ExecStartPre=/usr/sbin/nagios -s\g' /usr/lib/systemd/system/nagios.service
    systemctl daemon-reload
    systemctl reload "${service}"
    CHECK_RESULT $? 0 0 "${service} reload failed"
    systemctl status "${service}" | grep "Active: active"
    CHECK_RESULT $? 0 0 "${service} reload causes the service status to change"
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    sed -i 's\ExecStartPre=/usr/sbin/nagios -s\ExecStartPre=/usr/sbin/nagios\g' /usr/lib/systemd/system/nagios.service
    systemctl daemon-reload
    systemctl reload "${service}"
    systemctl stop "${service}"
    sed -i 's\#cfg_dir=/etc/nagios/conf.d\cfg_dir=/etc/nagios/conf.d\g' /etc/nagios/nagios.cfg
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
