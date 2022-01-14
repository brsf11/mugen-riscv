#!/usr/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
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
# @Desc      :   Test systemd-update-done.service restart
# #############################################

source "../common/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    service=systemd-update-done.service
    log_time=$(date '+%Y-%m-%d %T')
    test -f /etc/.updated && mv /etc/.updated /etc/.updated_bak
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    systemctl restart "${service}"
    CHECK_RESULT $? 0 0 "${service} restart failed"
    SLEEP_WAIT 5
    systemctl status "${service}" | grep "Active: active"
    CHECK_RESULT $? 0 0 "${service} restart failed"
    systemctl stop "${service}"
    CHECK_RESULT $? 0 0 "${service} stop failed"
    SLEEP_WAIT 5
    systemctl status "${service}" | grep "Active: inactive"
    CHECK_RESULT $? 0 0 "${service} stop failed"
    test -f /etc/.updated && mv /etc/.updated /etc/.updated_bak
    systemctl start "${service}"
    CHECK_RESULT $? 0 0 "${service} start failed"
    systemctl status "${service}" | grep "Active: active"
    CHECK_RESULT $? 0 0 "${service} start failed"
    test_enabled "${service}"
    journalctl --since "${log_time}" -u "${service}" | grep -i "fail\|error" | grep -v -i "DEBUG\|INFO\|WARNING"
    test_reload "${service}"
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "Start environment cleanup."
    test -f /etc/.updated_bak && mv /etc/.updated_bak /etc/.updated
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
