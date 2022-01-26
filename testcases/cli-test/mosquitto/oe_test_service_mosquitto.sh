#!/usr/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.
####################################
#@Author        :   wenjun
#@Contact       :   1009065695@qq.com
#@Date          :   20212-01-26
#@License       :   Mulan PSL v2
#@Desc          :   Test mosquitto.service restart
#####################################
source "../common/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL mosquitto
    service=mosquitto.service 
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start testing..."
    test_execution "${service}"
    systemctl start "${service}"
    sed -i 's\ExecStart=/usr/sbin/mosquitto -c /etc/mosquitto/mosquitto.conf\ExecStart=/usr/sbin/mosquitto -d\g' /usr/lib/systemd/system/${service} 
    systemctl daemon-reload 
    systemctl reload "${service}"
    CHECK_RESULT $? 0 0 "${service} reload failed"
    systemctl status ${service} | grep "Active: active"
    CHECK_RESULT $? 0 0 "${service} reload causes the service status to change"
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    systemctl stop "${service}"
    sed -i 's\ExecStart=/usr/sbin/mosquitto -d\ExecStart=/usr/sbin/mosquitto -c /etc/mosquitto/mosquitto.conf\g' /usr/lib/systemd/system/${service}
    systemctl daemon-reload
    systemctl reload "${service}"
    systemctl stop "${service}"
    DNF_REMOVE
    LOG_INFO "Finish restoring the test environment."
}

main "$@"

